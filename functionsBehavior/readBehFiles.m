function  B = readBehFiles(blockPath)

% Find files
nSessions = numel(blockPath);

filesList = blockPath;

schedules = cell(nSessions,1); kappa = cell(nSessions,1);
rewards = cell(nSessions,1); rewardsTime = cell(nSessions,1);
pushes = cell(nSessions,1); pushesTime = cell(nSessions,1);
rewardRates = cell(nSessions,1);
allPushesTime = cell(nSessions,1);


pushesNum = NaN(nSessions,1);
rewardsNum = NaN(nSessions,1);
pushcorr = NaN(nSessions,1);
rewardcorr = NaN(nSessions,1);
pushesNumKappa = NaN(nSessions,2);
rewardsNumKappa = NaN(nSessions,2);
pushcorrKappa = NaN(nSessions,2);
rewardcorrKappa = NaN(nSessions,2);
allPushes = zeros(nSessions,1);
startFile = 0;

% load files
for ss=1:nSessions
    
    schedules{ss} = NaN(length(filesList{ss}),3);
    kappa{ss} = NaN(length(filesList{ss}),3);
    
    rewards{ss} = zeros(length(filesList{ss}),3);
    rewardsTime{ss} = cell(length(filesList{ss}),3);
    pushes{ss} = zeros(length(filesList{ss}),3);
    pushesTime{ss} = cell(length(filesList{ss}),3);
    rewardRates{ss} = zeros(length(filesList{ss}),3);
    allPushesTime{ss} = [];
    
    
    for ff=1:numel(blockPath{ss})% block = trial(Paths)
        fid = fopen(blockPath{ss}{ff});
        
        if ~(fid>0)
            error('Could not find behavioral file');
        end
        
        while 1
            
            
            line = fgetl(fid);
            if line<0
                break
            end
            
            if contains(line,'Schedules')
                schedules{ss}(ff,:) = sscanf(line,'Schedules: %f, %f, %f');
            elseif contains(line,'Block number')
                blockNumber{ss}(ff,:) = sscanf(line,'Block number: %i');
            elseif contains(line,'tStart')
                tStartTrial{ss}(ff,:) = sscanf(line,'tStart: %f');
            elseif contains(line,'tEnd')
                tEndTrial{ss}(ff,:) = sscanf(line,'tEnd: %f');
            elseif contains(line,'kappa')
                kappa{ss}(ff,:) = sscanf(line,'Stimulus kappa: %f');
            elseif length(line)>3 && strcmp(line(1:3),'Box') && ~contains(line,'scheduleV')
                if ~contains(line,'incorrect')
                    %                 if contains(line,'correct')
                    val = sscanf(line,'Box %d, time %f,  correct, next reward %f');
                    rewards{ss}(ff,val(1)) = rewards{ss}(ff,val(1))+1;
                    rewardsTime{ss}{ff,val(1)}(rewards{ss}(ff,val(1))) = val(2);
                else
                    val = sscanf(line,'Box %i, time %f,  incorrect, next reward %f');
                end
                
                pushes{ss}(ff,val(1)) = pushes{ss}(ff,val(1))+1;
                pushesTime{ss}{ff,val(1)}(pushes{ss}(ff,val(1))) = val(2);
                allPushes(ss) = allPushes(ss)+1;
                allPushesTime{ss}(allPushes(ss)) = val(2);
            end
            
        end
        
        rewardRates{ss}(ff,:) = 1./schedules{ss}(ff,:);
        
        fprintf('Block %i/%i: %i pushes, %i rewards\n',ff,length(filesList{ss}),sum(pushes{ss}(ff,:)),sum(rewards{ss}(ff,:)));
        
        fclose(fid);
        
        if isnan(kappa{ss}(ff))
            try
                load(sprintf('%s%s.mat',filePath,filesList{ss}(ff).name(1:end-4)),'boxKappa')
                kappa{ss}(ff,:) = boxKappa;
            catch
                kappa{ss}(ff,:) = 0;
                fprintf('Unable to load boxKappa\n');
            end
            
        end
        
    end
    
    fprintf('TOTAL: %i pushes, %i rewards\n',sum(pushes{ss}(:)),sum(rewards{ss}(:)));
    
    rrList = unique(rewardRates{ss});
    kappaList = unique(kappa{ss});
    averageRates = NaN(3,3);
    averagePushes = NaN(3,3);
    averageRewards = NaN(3,3);
    averageRatesKappa = NaN(3,3,2);
    averagePushesKappa = NaN(3,3,2);
    averageRewardsKappa = NaN(3,3,2);
    for rr=1:length(rrList)
        for bb=1:3
            averageRates(rr,bb) = rrList(rr)./sum(rrList);
            averagePushes(rr,bb) = sum(pushes{ss}(rewardRates{ss}(:,bb)==rrList(rr),bb))./sum(pushes{ss}(rewardRates{ss}(:,bb)==rrList(rr),:),'all');
            averageRewards(rr,bb) = sum(rewards{ss}(rewardRates{ss}(:,bb)==rrList(rr),bb))./sum(rewards{ss}(rewardRates{ss}(:,bb)==rrList(rr),:),'all');
            for kk=1:length(kappaList)
                filterBlocks = (rewardRates{ss}(:,bb)==rrList(rr)) & (kappa{ss}(:,bb)==kappaList(kk));
                averageRatesKappa(rr,bb,kk) = rrList(rr)./sum(rrList);
                averagePushesKappa(rr,bb,kk) = sum(pushes{ss}(filterBlocks,bb))./sum(pushes{ss}(filterBlocks,:),'all');
                averageRewardsKappa(rr,bb,kk) = sum(rewards{ss}(filterBlocks,bb))./sum(rewards{ss}(filterBlocks,:),'all');
            end
        end
    end
    
    
    s = rewardRates{ss}./sum(rewardRates{ss},2);
    p = pushes{ss}./sum(pushes{ss},2);
    r = rewards{ss}./sum(rewards{ss},2);
    pushesNum(ss) = sum(pushes{ss},'all');
    rewardsNum(ss) = sum(rewards{ss},'all');
    tmp = nancorr([s(:),p(:)]);
    pushcorr(ss) = tmp(1,2);
    tmp = nancorr([s(:),r(:)]);
    rewardcorr(ss) = tmp(1,2);
    
    for kk=1:length(kappaList)
        s = rewardRates{ss}.*(kappa{ss}==kappaList(kk))./sum(rewardRates{ss}.*(kappa{ss}==kappaList(kk)),2);
        p = pushes{ss}.*(kappa{ss}==kappaList(kk))./sum(pushes{ss}.*(kappa{ss}==kappaList(kk)),2);
        r = rewards{ss}.*(kappa{ss}==kappaList(kk))./sum(rewards{ss}.*(kappa{ss}==kappaList(kk)),2);
        pushesNumKappa(ss,kk) = sum(pushes{ss}.*(kappa{ss}==kappaList(kk)),'all');
        rewardsNumKappa(ss,kk) = sum(rewards{ss}.*(kappa{ss}==kappaList(kk)),'all');
        tmp = nancorr([s(:),p(:)]);
        pushcorrKappa(ss,kk) = tmp(1,2);
        tmp = nancorr([s(:),r(:)]);
        rewardcorrKappa(ss,kk) = tmp(1,2);
    end
    
    
    fprintf('\nCorrelation schedules/pushes: %2.2f\n',pushcorr(ss));
    fprintf('Correlation schedules/rewards: %2.2f\n',rewardcorr(ss));
    
    ipi1 = []; ipi2 = []; ipi3 = [];
    for ff=1:size(rewardsTime{ss},1)
        ipi1 = [ipi1,rewardsTime{ss}{ff,1}(2:end)-rewardsTime{ss}{ff,1}(1:end-1)];
        ipi2 = [ipi2,rewardsTime{ss}{ff,2}(2:end)-rewardsTime{ss}{ff,2}(1:end-1)];
        ipi3 = [ipi3,rewardsTime{ss}{ff,3}(2:end)-rewardsTime{ss}{ff,3}(1:end-1)];
    end
    histbins = 0:20:200;
    [nh1,nb] = hist(ipi1,histbins);
    nh2 = hist(ipi2,histbins);
    nh3 = hist(ipi3,histbins);
    startFile = startFile+length(filesList{ss});
end



filterStd = 30;
for ss=1:nSessions
    sessionLength(ss) = round(allPushesTime{ss}(end)-allPushesTime{ss}(1));
end
pPush = NaN(nSessions,max(sessionLength)+1);
for ss=1:nSessions
    pPush(ss,1:sessionLength(ss)+1) = 0;
    pPush(ss,round(allPushesTime{ss}-allPushesTime{ss}(1)+1)) = 1;
    pPush(ss,:) = conv(pPush(ss,:),normpdf(-3*filterStd:+3*filterStd,0,filterStd),'same');
end


B = struct('schedules',schedules,...
    'kappa',kappa,...
    'rewards',rewards,...
    'rewardsTime',rewardsTime,...
    'pushes',pushes,...
    'pushesTime',pushesTime,...
    'rewardRates',rewardRates,...
    'allPushesTime',allPushesTime,...
    'blockNumber',blockNumber,...
    'tStartTrial',tStartTrial,...
    'tEndTrial',tEndTrial...
    );
end
