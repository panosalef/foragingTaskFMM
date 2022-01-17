%   importBehavior(monkeyName,sessionID,stage)
%   [block,trials,iti]=
function  [block,trials,iti,stats] = importBehavior(prs)
%% %%%%%%%%%%%%%Add prs as input

%% things to be added
% check push times from vicon and beh
% preprocess eye movements
% detect saccades
% improve Readbehfiles
% finish food dispenser part

% clear,clc
% monkeyName = 'Marco';
% sessionID = 20211109;
% stage = 'Training';
%% Server Path Stuff
%% Load all .beh files from /Matlab directory
trialPaths = getTrialPaths(prs.behPath,'*.beh');
corruptionIdx = findBehCorrupted({trialPaths});
goodTrialPaths = cellfun(@(x,y) x(y) ,{trialPaths},corruptionIdx,'UniformOutput' ,false);
behData = readBehFiles(goodTrialPaths);
fprintf('%i corrupted .beh file(s) detected \n',sum(~corruptionIdx{:}));

%% Load Vicon .mat files
viconDir = what(prs.viconPath);
for b = 1:numel(viconDir.mat)
    load(strcat(prs.viconPath,viconDir.mat{b}),...
        'analog','markers','subject','trialName','endFrame','cameraFrameRate','deviceRate');
    %% Get info from trialName of vicon file
    trialNameParts = split(trialName,'_');
    viconMonkeyName = trialNameParts{1} ;
    viconDate = trialNameParts{2};
    viconBlockIdx = str2double(trialNameParts{3}(2));
    neuralFineID = str2double(trialNameParts{3}(1));
    
    %% Check that Vicon File & input info match
    if ~(b == viconBlockIdx)
        error('Block Indices do not match');
    end
    
    if ~strcmp(viconMonkeyName,prs.monkeyName)
        warning('Vicon file name and input name do not match');
    end
    
    if ~strcmp(viconDate,prs.sessionId)
        warning('Vicon Date and input date do not match');
    end
    
    if ~strcmp(subject{:},prs.monkeyName)
        warning('Vicon Subject and input name do not match');
    end
    
    %% Identify Session Type
    if any(strcmp(fields(analog),'trialPulse'))
        sessionType = 'Foraging Task';
    elseif any(strcmp(fields(analog),'dispenser1'))
        sessionType = 'No Task';
    else
        error('No Session Type Identified')
    end
    
    %% Write Session info
    %     behavior.info.monkey = subject{:};
    %     behavior.info.date = sessionIDstr{:};
    %     behavior.info.task = sessionType;
    
    %% Down Sample here and compute New Dt
    sr = 50; % New sampling rate in Hz
    dt = 1/sr;
    endFrame = round(endFrame./(cameraFrameRate./sr)); % redfine imported endFrame based on new sr
    
    % Markers
    markerNames = fields(markers);
    for i = 1:numel(markerNames)
        markers.(markerNames{i}) = downsample(markers.(markerNames{i})',cameraFrameRate./sr)';
    end
    
    % Analog channels
    % analogNames = fields(analog);
    analogNames = {'eyeH','eyeV','eyeD'}; % don't downsample random & trial Pulses
    for i = 1:numel(analogNames)
        analog.(analogNames{i}) = downsample(analog.(analogNames{i})',deviceRate./sr)';
    end
    
    % Remeplace deviceRate cameraFrameRate in code acordingly
    %% Compute Total Time %redefine here based on new fr %define
    %     tSessionDevice =(1:endFrame*10)./sr; % end frame is multiplies by 10 because it's optical frame
    %     tSessionMarkers =(1:endFrame)./sr;
    tSession = (1:endFrame)./sr;
    
    %% Load eye Calibration if not replace with NaN
    eyeCalibDir =  what(prs.eyeCalibPath);
    if isempty(eyeCalibDir)
        warning('Eye Calibratin File Not Found')
        bx = NaN(6,1);
        by = NaN(6,1);
    else
        load(strcat(eyeCalibDir.path,'\',eyeCalibDir.mat{:}),'bx','by');
    end
    
    %% Get Eye Position
    eyexy = [ones(length(analog.eyeH),1) analog.eyeH' analog.eyeV' analog.eyeH'.^2 analog.eyeV'.^2 (analog.eyeH.*analog.eyeV)'];
    eyeH(1,:) = eyexy * bx;
    eyeV(1,:) = eyexy * by;
    
    % Remove eye positions beyond -40/40 deg
    eyeH(abs(eyeH) > 40 | abs(eyeV) > 40) = NaN ;
    eyeV(abs(eyeH) > 40 | abs(eyeV) > 40) = NaN ;
    
    %% Preprocess eye
    %     eyeH = fillmissing(eyeH,'pchip',2);
    %     eyeV = fillmissing(eyeV,'pchip',2);
    
    
    
    %% Find Saccades
    %% smooth? probably
    %% saccade detection
    
    %% Get .beh Data, per Block
    blockSchedules = behData.schedules(behData.blockNumber == b,:); %rows are trials, columns are boxes[1 2 3]
    blockKappa = behData.kappa(behData.blockNumber == b,:);
    
    %% Find trial start/end time
    [trialPulseAmp,trialPulseUpIdx] = findpeaks(diff(analog.trialPulse),'Threshold',3); % change name from BlockPulse to trialPulse
    [~,trialPulseDownIdx] = findpeaks(-diff(analog.trialPulse),'Threshold',3); % change name from BlockPulse to trialPulse
    
    %Check Pulse Amplitude
    if any(trialPulseAmp < 4.5)
        warning("Trial Pulse Amplitude too low.")
    end
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Check Pulse Duration % Fix this after changing sr and avoid hardcoded vars
    if any(~ismember(unique(trialPulseDownIdx-trialPulseUpIdx),[10 50 51])) % pulse durations are 10ms(Start) and 50ms(End)
        warning("Non-Standard pulse duration found.")
    end
    
    % Discard additional erroneous trialPulses/start = 1, end = 2
    trialPulseID = (trialPulseDownIdx-trialPulseUpIdx);
    trialPulseID(trialPulseID > 5 & trialPulseID <15) = 1;  %%%%%
    trialPulseID(trialPulseID > 45 & trialPulseID <55) = 2; %%%%%
    startPulseIdx = trialPulseUpIdx(trialPulseID == 1);
    endPulseIdx = trialPulseUpIdx(trialPulseID == 2);
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:numel(startPulseIdx)
        if trialPulseID(find(trialPulseUpIdx > startPulseIdx(i),1))== 2
            validStartPulseIdx(i) = true ;
        else
            validStartPulseIdx(i) = false ;
        end
    end
    
    fprintf('%i corrupted startPulse detected in analog data \n',sum(~validStartPulseIdx));
    % Eliminate Corrupted
    if sum(~validStartPulseIdx)
        startPulseIdx = startPulseIdx(validStartPulseIdx);
        fprintf('Corrupted startPulse(s) successfully eliminated \n');
    end
    
    tStartVicon = startPulseIdx./deviceRate;
    tStartBeh = behData.tStartTrial(behData.blockNumber == b,:);
    
    tEndVicon = endPulseIdx./deviceRate;
    tEndBeh = behData.tEndTrial(behData.blockNumber == b,:);
    
    %% Get Random Pulse times
    [~,tRandomPulse] = findpeaks(diff(analog.randomPulse),deviceRate,'Threshold',3);
    behavior.params.randomPulse.continuous = analog.randomPulse;
    behavior.params.randomPulse.times = tRandomPulse ;
    behavior.params.randomPulse.sRate = deviceRate ;
    
    
    %% Append neural file IDs
    NeuralFileIdList(b) = neuralFineID;
    
    %% NaN-pad and Interpolate marker data
    %     markerNames = fields(markers);
    for i = 1:numel(markerNames)
        for j = 1:3
            markers.(markerNames{i})(j,markers.(markerNames{i})(j,:) == 0) = NaN ;
        end
        %         markers.(markerNames{i}) = fillmissing(markers.(markerNames{i}),'pchip',2);
    end
    
    
    %% Interpolate Missing markers
    occlusionIdxLogical = [markers.front(4,:) ; markers.back(4,:) ; markers.left(4,:) ; markers.right(4,:)];
    occlusionIdxDouble = sum(occlusionIdxLogical,1);
    
    % Fix Front missing Marker
    frontMissIdx = find((occlusionIdxDouble == 3 & occlusionIdxLogical(1,:) == 0)==1);
    
    supVecFront = cross(markers.back(1:3,frontMissIdx) - markers.left(1:3,frontMissIdx),...
        markers.right(1:3,frontMissIdx)- markers.left(1:3,frontMissIdx),1);
    supVecFront = supVecFront./sqrt(sum(supVecFront.^2,1));
    supVecFront = supVecFront + markers.left(1:3,frontMissIdx);
    
    markerFrontTemp = cross(supVecFront - markers.left(1:3,frontMissIdx),markers.back(1:3,frontMissIdx)- markers.left(1:3,frontMissIdx));
    markerFrontTemp = markerFrontTemp./sqrt(sum(markerFrontTemp.^2,1));
    markerFrontTemp = markerFrontTemp * 65.45*sind(90./2); % un- hardcode radius
    markerFrontTemp = markers.left(1:3,frontMissIdx) + markerFrontTemp;
    
    markers.front(1:3,frontMissIdx) = markerFrontTemp;
    
    % Fix Back missing Marker
    backMissIdx = find((occlusionIdxDouble == 3 & occlusionIdxLogical(2,:) == 0)==1);
    
    supVecBack = cross(markers.front(1:3,backMissIdx) - markers.left(1:3,backMissIdx),markers.right(1:3,backMissIdx)- markers.left(1:3,backMissIdx),1);
    supVecBack = supVecBack./sqrt(sum(supVecBack.^2,1));
    supVecBack = supVecBack + markers.left(1:3,backMissIdx);
    
    markerBackTemp = cross(supVecBack - markers.left(1:3,backMissIdx),markers.front(1:3,backMissIdx)- markers.left(1:3,backMissIdx));
    markerBackTemp = markerBackTemp./sqrt(sum(markerBackTemp.^2,1));
    markerBackTemp = markerBackTemp * 65.45*sind(90./2); % un- hardcode radius
    markerBackTemp = markers.left(1:3,backMissIdx) + markerBackTemp;
    
    % work on the case that a right marker was confused for back
    
    markers.back(1:3,backMissIdx) = markerBackTemp;
    
    
    
    % Fix Left missing Marker
    leftMissIdx = find((occlusionIdxDouble == 3 & occlusionIdxLogical(3,:) == 0)==1);
    centroidTemp = (markers.front(1:3,leftMissIdx) + markers.back(1:3,leftMissIdx))./2;
    supVecLeft = cross(markers.back(1:3,leftMissIdx) - centroidTemp,markers.right(1:3,leftMissIdx)- centroidTemp,1);
    supVecLeft = -supVecLeft./sqrt(sum(supVecLeft.^2,1));
    supVecLeft = supVecLeft + centroidTemp;
    
    markerLeftTemp = cross(supVecLeft - centroidTemp,markers.back(1:3,leftMissIdx)- centroidTemp);
    markerLeftTemp = markerLeftTemp./sqrt(sum(markerLeftTemp.^2,1));
    markerLeftTemp = markerLeftTemp * 65.45./2; % un- hardcode radius
    markerLeftTemp = centroidTemp + markerLeftTemp;
    
    markers.left(1:3,leftMissIdx) = markerLeftTemp;
    
    
    % ignore Right Missing markers
    %
    
    %% Remove Confused Markers
    % dont remove but correct(for later)
    confusionThres = 12;
    dFB = sqrt(sum((markers.front(1:3,:) - markers.back(1:3,:)).^2,1));
    dLR = sqrt(sum((markers.left(1:3,:) - markers.right(1:3,:)).^2,1));
    dFR = sqrt(sum((markers.front(1:3,:) - markers.right(1:3,:)).^2,1));
    dFL = sqrt(sum((markers.front(1:3,:) - markers.left(1:3,:)).^2,1));
    
    if str2num(prs.sessionId) >= 20211206
        confusionIdx =  dFB > 65.45+confusionThres | dFB < 65.45-confusionThres|...
            dLR > 65.45*sind(160/2)+confusionThres | dLR < 65.45*sind(160/2)-confusionThres |...
            dFR > 65.45*sind(110/2)+confusionThres | dFR < 65.45*sind(110/2)-confusionThres |...
            dFL > 65.45*sind(90/2)+confusionThres | dFL < 65.45*sind(90/2)-confusionThres;
        
    elseif str2num(prs.sessionId) < 20211206
        confusionIdx =  dFB > 65.45+confusionThres | dFB < 65.45-confusionThres|...
            dLR > 65.45*sind(135/2)+confusionThres | dLR < 65.45*sind(135/2)-confusionThres |...
            dFR > 65.45*sind(135/2)+confusionThres | dFR < 65.45*sind(135/2)-confusionThres |...
            dFL > 65.45*sind(90/2)+confusionThres | dFL < 65.45*sind(90/2)-confusionThres;
        
    end
    
    markers.front(1:3,confusionIdx) = NaN;
    markers.back(1:3,confusionIdx) = NaN;
    markers.left(1:3,confusionIdx) = NaN;
    markers.right(1:3,confusionIdx) = NaN;
    
    
    %% compute centroid
    markers.centroid = (markers.front(1:3,:) + markers.back(1:3,:))./2;
    
    %% relocate markers to AP0
    normalVector = cross(markers.front(1:3,:) - markers.centroid, markers.left(1:3,:) - markers.centroid);
    unitVector = normalVector./sqrt(sum(normalVector.^2,1));
    prs.dAP0 = 108; % vertical distance from AP0//
    dVector = -unitVector*prs.dAP0; % change direction of cross and dAP)
    
    markersAP0.front = markers.front(1:3,:) + dVector;
    markersAP0.back = markers.back(1:3,:) + dVector;
    markersAP0.left = markers.left(1:3,:) + dVector;
    markersAP0.centroid = markers.centroid + dVector;
    
    %% Head Related Variables
    % AP0 position
    position = markersAP0.centroid;
    nanPadIdx = nanTracker(position(1,:),sr,1);
    position = fillmissing(markersAP0.centroid,'pchip',2); % replace letter with Kalman filter
    position(:,nanPadIdx) = NaN;
    
    position1d = getArena1dPosition(position(1,:),position(2,:),[-prs.arenaRho prs.arenaRho],[-prs.arenaRho prs.arenaRho],prs.nxArena1d,prs.nxArena1d); 
    
    
    % head direction
    headDirAziEarth = atan2d((markersAP0.front(2,:) - markersAP0.centroid(2,:)),(markersAP0.front(1,:) - markersAP0.centroid(1,:)));
    %     headDirEarth.interp = fillmissing(headDirEarth.raw,'pchip',2);
    
    % translation speed
    transSpeed = [NaN sqrt(sum(diff(markersAP0.centroid,1,2).^2,1))]; %Divide with dt?
    transSpeedSm = medfilt1(transSpeed,5);
    
    % movement Direction to earth
    moveDirEarth = [NaN atan2d(diff(markersAP0.centroid(2,:),1,2),diff(markersAP0.centroid(1,:),1,2))];
    
    % hx, hy, and hz define the head reference frame
    % hx: back to front; hy: right to left; hz: upward
    % d1(x,y,z),d2(back2front,right2left,upward), d3(time)
    hx = markersAP0.front - markersAP0.centroid;    hx = hx./sqrt(sum(hx.^2,1));
    hy = markersAP0.left - markersAP0.centroid;     hy = hy./sqrt(sum(hy.^2,1));
    hz = cross(hx,hy);                              hz = hz./sqrt(sum(hz.^2,1));
    
    % rotation matrix from arena to head coodinate
    % d1(x,y,z),d2(back2front,right2left,upward), d3(time)
    arena2headR = nan(3,3,size(position,2));
    arena2headR(:,1,:) = hx;    % back2front
    arena2headR(:,2,:) = hy;    % right2left
    arena2headR(:,3,:) = hz;    % upward
    
    % gravity vector in head reference frame
    gravityHead  = -hz;
    
    %% Eye related variables %%Needs to be refined%%%%%%%%%%%%%%%%% raw coding here
    % eye orientation vector in head coordinates
    eyeVecHead = [cosd(eyeH); sind(eyeH); tand(eyeV)];
    eyeVecArena = squeeze(pagemtimes(arena2headR,reshape((eyeVecHead),[3 1 size(arena2headR,3)]))); %% improve
    eyePos = [52.7 19.1 0]'; % add in params scripts in the future
    eyeDist = squeeze(pagemtimes(arena2headR,eyePos));
    eyeCenter = position + eyeDist;
    
    %% loop to compute variables (arenaIntersection & YawPitchRoll)
    % Initialize variables computed in the loop
    yprVel = NaN(3,size(hx,2));  % yaw pitch roll velocity
    headDirAziTilt = NaN(3,size(hx,2)); % tilted azimuth angle
    headArenaInt = NaN(3,size(hx,2)); % head ori. & arena intersection
    
    for i=1:size(hx,2)
        headDirAziTilt(i) = JL_R2Az([hx(:,i) hy(:,i) hz(:,i)]);
        if i<=1 || sum(isnan([hx(:,i);hy(:,i);hz(:,i)])) || sum(isnan([hx(:,i-1);hy(:,i-1);hz(:,i-1)]))
            yprVel(:,i) = [NaN;NaN;NaN];
        else
            yprVel(:,i) = (-JL_R2yapirod([hx(:,i) hy(:,i) hz(:,i)]\[hx(:,i-1) hy(:,i-1) hz(:,i-1)])*cameraFrameRate)';%% error
        end
        
        if  sum(isnan(hx(:,i)))
            headArenaInt(:,i) = nan(3,1);
            eyeArenaInt(:,i) = nan(3,1);
        else
            headArenaInt(:,i) = getArenaInt(markersAP0.front(:,i),markersAP0.centroid(:,i));
            eyeArenaInt(:,i) = getArenaInt(eyeVecArena(:,i)+eyeCenter(:,i),eyeCenter(:,i));
        end
        
    end
    headArenaIntUnfolded = getArenaUnfolded(headArenaInt);
    eyeArenaIntUnfolded =  getArenaUnfolded(eyeArenaInt);
    
    eyeArenaInt1d = getArena1dPosition(eyeArenaInt(1,:),eyeArenaInt(2,:),[-prs.arenaRho prs.arenaRho],[-prs.arenaRho prs.arenaRho],prs.nxArena1d,prs.nxArena1d);
    
    % Compute egocentric boundary1
    % Same way it was computed in Mao 2021, As if arena is circular
    u = position(1:2,:);
    v = markersAP0.front(1:2,:) - markersAP0.centroid(1:2,:);
    thetaEgoB1 = -atan2d(u(1,:).*v(2,:)-u(2,:).*v(1,:), u(1,:).*v(1,:)+u(2,:).*v(2,:));
    dCevian = getHexCevian(atan2d(position(2,:),position(1,:)));
    rEgoB1 = dCevian - sqrt(sum(position(1:2,:).^2,1));
    [xEgoB1,yEgoB1] = pol2cart(thetaEgoB1/180*pi, dCevian);
    % Compute egocentric boundary2
    % Arena is Hexagonal
    [rEgoB2,thetaEgoB2] = getHexEgoBoundary(u,v);
    [xEgoB2,yEgoB2] = pol2cart(thetaEgoB2/180*pi, rEgoB2);
    
    circEgoBxy = [xEgoB1 ; yEgoB1];
    circEgoBpolar = [thetaEgoB1 ; rEgoB1];
    
    hexEgoBxy = [xEgoB2 ; yEgoB2];
    hexEgoBpolar = [thetaEgoB2 ; rEgoB2];
    
    
    
    %     centroid2 = centroid + dVector; %test
    
    %% If Block IS the Foraging Task
    if strcmp(sessionType,'Foraging Task')
        %% Get Pushes/Reward Times from beh file
        tPushBehBlock = behData.pushesTime(behData.blockNumber == b,:);
        tRewardBehBlock = behData.rewardsTime(behData.blockNumber == b,:);
        
        %% Compare Pushes Number from Vicon and Beh
        totalPushesBeh = sum(sum(cellfun(@numel,behData.pushesTime(behData.blockNumber == b,:))));
        totalRewardsBeh = sum(sum(cellfun(@numel,behData.rewardsTime(behData.blockNumber == b,:))));
        
        %% Chunk behavior into Trials
        for t = 1:numel(tStartVicon)
            %% events
            behavior(b).trials(t).events.tStart = tStartVicon(t);
            behavior(b).trials(t).events.tEnd = tEndVicon(t);
            behavior(b).trials(t).events.tRandomPulse = tRandomPulse(tRandomPulse >= tStartVicon(t) & tRandomPulse  <= tEndVicon(t));
            behavior(b).trials(t).events.tStartBeh = tStartBeh(t);
            behavior(b).trials(t).events.tEndBeh = tEndBeh(t);
            
            behavior(b).trials(t).events.tPush.box1 = tPushBehBlock{t,1} - tStartBeh(t);
            behavior(b).trials(t).events.tPush.box2 = tPushBehBlock{t,2} - tStartBeh(t);
            behavior(b).trials(t).events.tPush.box3 = tPushBehBlock{t,3} - tStartBeh(t);
            
            [tPushSorted,sortPushIdx] = sort([behavior(b).trials(t).events.tPush.box1...
                behavior(b).trials(t).events.tPush.box2...
                behavior(b).trials(t).events.tPush.box3]);
            
            pushId = [ones(1,numel(behavior(b).trials(t).events.tPush.box1))...
                2*ones(1,numel(behavior(b).trials(t).events.tPush.box2))...
                3*ones(1,numel(behavior(b).trials(t).events.tPush.box3))];
            
            behavior(b).trials(t).events.tPush.all = tPushSorted;
            behavior(b).trials(t).events.tPush.id = pushId(sortPushIdx);
            
            behavior(b).trials(t).events.tReward.box1 = tPushBehBlock{t,1} - tStartBeh(t);
            behavior(b).trials(t).events.tReward.box2 = tPushBehBlock{t,1} - tStartBeh(t);
            behavior(b).trials(t).events.tReward.box3 = tPushBehBlock{t,1} - tStartBeh(t);
            
            [tRewardSorted,sortRewardIdx] = sort([behavior(b).trials(t).events.tReward.box1...
                behavior(b).trials(t).events.tReward.box2...
                behavior(b).trials(t).events.tReward.box3]);
            
            rewardId = [ones(1,numel(behavior(b).trials(t).events.tReward.box1))...
                2*ones(1,numel(behavior(b).trials(t).events.tReward.box2))...
                3*ones(1,numel(behavior(b).trials(t).events.tReward.box3))];
            
            behavior(b).trials(t).events.tReward.all = tRewardSorted;
            behavior(b).trials(t).events.tReward.id = rewardId(sortRewardIdx);
            
            
            
            behavior(b).trials(t).events.pushLogical.box1 = ...
                ismember(behavior(b).trials(t).events.tPush.box1,behavior(b).trials(t).events.tReward.box1);
            behavior(b).trials(t).events.pushLogical.box2 = ...
                ismember(behavior(b).trials(t).events.tPush.box2,behavior(b).trials(t).events.tReward.box2);
            behavior(b).trials(t).events.pushLogical.box3 = ...
                ismember(behavior(b).trials(t).events.tPush.box3,behavior(b).trials(t).events.tReward.box3);
            
            allPushLogical = [behavior(b).trials(t).events.pushLogical.box1...
                behavior(b).trials(t).events.pushLogical.box2...
                behavior(b).trials(t).events.pushLogical.box3];
            
            behavior(b).trials(t).events.pushLogical.all = allPushLogical(sortPushIdx);
            behavior(b).trials(t).events.pushLogical.id = pushId(sortPushIdx);
            
            
            
            %% Parameters
            behavior(b).trials(t).params.boxIdx = [1 2 3];
            behavior(b).trials(t).params.kappa = blockKappa(t,:);
            behavior(b).trials(t).params.schedules = blockSchedules(t,:);
            behavior(b).trials(t).params.rewardRates = 1 ./ behavior(b).trials(t).params.schedules;
            behavior(b).trials(t).params.rewardRateFraction = (behavior(b).trials(t).params.rewardRates) ./ sum(behavior(b).trials(t).params.rewardRates);
            %             behavior(b).trials(t).params.markerNames = fields(markers);
            
            %% continuous
            behavior(b).trials(t).continuous.t = tSession(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t)) - behavior(b).trials(t).events.tStart;
            behavior(b).trials(t).continuous.position = position(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.position1d = position1d(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.positionScheduleAlign = getScheduleAlignedPosition(behavior(b).trials(t).continuous.position(1:2,:),behavior(b).trials(t).params.schedules);
            behavior(b).trials(t).continuous.transSpeed = transSpeed(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.transSpeedSm = transSpeedSm(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.headDirAziTilt = headDirAziTilt(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.headDirAziEarth = headDirAziEarth(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.moveDirEarth = moveDirEarth(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.tilt = gravityHead(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.yprVel = yprVel(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.headArenaInt = headArenaInt(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.headArenaInt2d = headArenaIntUnfolded(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.circEgoBxy = circEgoBxy(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.circEgoBpolar = circEgoBpolar(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.hexEgoBxy = hexEgoBxy(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.hexEgoBpolar = hexEgoBpolar(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.eyeH = eyeH(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.eyeV = eyeV(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.eyeD = analog.eyeD(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.eyeArenaInt = eyeArenaInt(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.eyeArenaInt1d = eyeArenaInt1d(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            behavior(b).trials(t).continuous.eyeArenaInt2d = eyeArenaIntUnfolded(:,tSession >= tStartVicon(t) & tSession  <= tEndVicon(t));
            
            %% continuous variables of intertrial intervel
            behavior(b).iti(t).continuous.t = tSession(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)])); %logical switch
            behavior(b).iti(t).continuous.position = position(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.transSpeed = transSpeed(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.transSpeedSm = transSpeedSm(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.headDirAziTilt = headDirAziTilt(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.headDirAziEarth = headDirAziEarth(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.moveDirEarth = moveDirEarth(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.tilt = gravityHead(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.yprVel = yprVel(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.headArenaInt = headArenaInt(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.headArenaInt2d = headArenaIntUnfolded(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.circEgoBxy = circEgoBxy(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.circEgoBpolar = circEgoBpolar(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.hexEgoBxy = hexEgoBxy(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.hexEgoBpolar = hexEgoBpolar(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.eyeH = eyeH(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.eyeV = eyeV(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.eyeD = analog.eyeD(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.eyeArenaInt = eyeArenaInt(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            behavior(b).iti(t).continuous.eyeArenaInt2d = eyeArenaIntUnfolded(:,tSession >= tEndVicon(t) & tSession <= ...
                sum([(t+1)<numel(tStartVicon) (t+1)>numel(tStartVicon)].*[tStartVicon(min(t+1,numel(tStartVicon))) tSession(end)]));
            
            
            %% Times series with pushes
            %             behavior(b).trials(t).continuous.tPush.box1 = getContinuousPush(behavior(b).trials(t).continuous.tDevice-behavior(b).trials(t).continuous.tDevice(1),...
            %                 behavior(b).trials(t).events.tPush.box1);
            %             behavior(b).trials(t).continuous.tPush.box2 = getContinuousPush(behavior(b).trials(t).continuous.tDevice-behavior(b).trials(t).continuous.tDevice(1),...
            %                 behavior(b).trials(t).events.tPush.box2);
            %             behavior(b).trials(t).continuous.tPush.box3 = getContinuousPush(behavior(b).trials(t).continuous.tDevice-behavior(b).trials(t).continuous.tDevice(1),...
            %                 behavior(b).trials(t).events.tPush.box3);
            
            %% Reward Probability
            behavior(b).trials(t).continuous.rewardProb.box1 = getContinuousRewProb(behavior(b).trials(t).continuous.t-behavior(b).trials(t).continuous.t(1),...
                behavior(b).trials(t).events.tPush.box1,behavior(b).trials(t).params.rewardRates(1));
            behavior(b).trials(t).continuous.rewardProb.box2 = getContinuousRewProb(behavior(b).trials(t).continuous.t-behavior(b).trials(t).continuous.t(1),...
                behavior(b).trials(t).events.tPush.box2,behavior(b).trials(t).params.rewardRates(2));
            behavior(b).trials(t).continuous.rewardProb.box3 = getContinuousRewProb(behavior(b).trials(t).continuous.t-behavior(b).trials(t).continuous.t(1),...
                behavior(b).trials(t).events.tPush.box3,behavior(b).trials(t).params.rewardRates(3));
            
            
            
            
            %% Statistics
            behavior(b).stats.boxIdx{t} = [1 2 3];
            behavior(b).stats.pushTotal(t) = numel([behavior(b).trials(t).events.tPush.box1 behavior(b).trials(t).events.tPush.box2 behavior(b).trials(t).events.tPush.box3]) ;
            behavior(b).stats.rewardTotal(t) = numel([behavior(b).trials(t).events.tReward.box1 behavior(b).trials(t).events.tReward.box2 behavior(b).trials(t).events.tReward.box3]);
            behavior(b).stats.pushPerBox{t} = [numel(behavior(b).trials(t).events.tPush.box1) numel(behavior(b).trials(t).events.tPush.box2) numel(behavior(b).trials(t).events.tPush.box3)];
            behavior(b).stats.rewardPerBox{t} = [numel(behavior(b).trials(t).events.tReward.box1) numel(behavior(b).trials(t).events.tReward.box2) numel(behavior(b).trials(t).events.tReward.box3)];
            behavior(b).stats.pushFraction{t} = (behavior(b).stats.pushPerBox{t}) ./ sum(behavior(b).stats.pushPerBox{t});
            behavior(b).stats.rewardFraction{t} = (behavior(b).stats.rewardPerBox{t}) ./ sum(behavior(b).stats.rewardPerBox{t});
            behavior(b).stats.meanVelocity(t) = nanmean(behavior(b).trials(t).continuous.transSpeedSm);
            behavior(b).stats.distance(t) = nansum(sqrt(sum(diff(behavior(b).trials(t).continuous.position,1,2).^2,1)));
            behavior(b).stats.trialNumber(t) = t; 
            behavior(b).stats.goodTrialIdx(t) = behavior(b).stats.pushTotal(t) > prs.goodTrialPushThreshold;
            
            
            
        end
        
        %% Unsegmented continuous data
        behavior(b).block.t = tSession;
        behavior(b).block.position = position;
        behavior(b).block.position1d = position1d;
        behavior(b).block.transSpeed = transSpeed;
        behavior(b).block.transSpeedSm = transSpeedSm;
        behavior(b).block.headDirAziTilt = headDirAziTilt;
        behavior(b).block.headDirAziEarth = headDirAziEarth;
        behavior(b).block.moveDirEarth = moveDirEarth;
        behavior(b).block.tilt = gravityHead;
        behavior(b).block.yprVel = yprVel;
        behavior(b).block.headArenaInt = headArenaInt;
        behavior(b).block.headArenaInt2d = headArenaIntUnfolded;
        behavior(b).block.circEgoBxy = circEgoBxy;
        behavior(b).block.circEgoBpolar = circEgoBpolar;
        behavior(b).block.hexEgoBxy = hexEgoBxy;
        behavior(b).block.hexEgoBpolar = hexEgoBpolar;
        behavior(b).block.eyeH = eyeH;
        behavior(b).block.eyeV = eyeV;
        behavior(b).block.eyeD = analog.eyeD;
        behavior(b).block.eyeArenaInt = eyeArenaInt;
        behavior(b).block.eyeArenaInt1d = eyeArenaInt1d;
        behavior(b).block.eyeArenaInt2d = eyeArenaIntUnfolded;
        
        
        %% Reshape for output
        block = [behavior.block];
        trials = [behavior.trials];
        stats = [behavior.stats];
        iti = [behavior.iti];
        
        
        %% If the behavior is No task
    elseif strcmp(sessionType,'No Task')
        
        %% Events
        %stuff for No-Task here
        behavior(b).trials(t).events.dispenser1 = indpeaks(diff(analog.dispenser1),sr,'Threshold',3);
        behavior(b).trials(t).events.dispenser2 = indpeaks(diff(analog.dispenser2),sr,'Threshold',3);
        behavior(b).trials(t).events.dispenser3 = indpeaks(diff(analog.dispenser3),sr,'Threshold',3);
        behavior(b).trials(t).events.randomPulse = tRandomPulse;
        
        %% continuous
        for j = 1:numel(fields(markers))
            behavior(b).trials(t).continuous.markers.(behavior(b).trials(t).params.markerNames{j}) =...
                markers.(behavior(b).trials(t).params.markerNames{j});
        end
        
        %% Needs to be fixed %%
        behavior(b).trials(t).continuous.tSession = tSession;
        behavior(b).trials(t).continuous.position = [];
        behavior(b).trials(t).continuous.eyeH = eyeH;
        behavior(b).trials(t).continuous.eyeV = eyeV;
        behavior(b).trials(t).continuous.eyeD = analog.eyeD;
        
    end
end

%% function ends here
end
