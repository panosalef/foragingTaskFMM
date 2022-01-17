% clear,clc
% path = 'Y:\Monkeys\Marco\FMM\Data\Recordings\Marco_20220104\Neural Recordings';
% function getViconNlxLag(prs) % for the future
function viconNlxLag = getViconNlxLag(neuralRawPath,viconPath)

[TimeStamps, EventIDs, TTLs, Extras, EventStrings, Header2] = ...
    Nlx2MatEV([neuralRawPath,'\','Events.nev'], [1 1 1 1 1],1,1,1);

tRec = TimeStamps(1):1000:TimeStamps(end);
ttlPulse = TTLs(2:end-1);
tPulse = TimeStamps(2:end-1);
tUp = tPulse(ttlPulse == 4);
tDown = tPulse(ttlPulse == 0);

randomPulseNlx = zeros(1,numel(tRec));
for i = 1:numel(tUp)
    randomPulseNlx(tUp(i) <= tRec & tDown(i)>= tRec) = 1;
end

%%%% Check inside the Vicon folder for number if blocks and load them one by one
viconDir = what(viconPath);
for i = 1:numel(viconDir.mat)
load([viconPath,'\',viconDir.mat{i}],'analog');
randomPulseVicon = zeros(1,numel(analog.randomPulse));
randomPulseVicon(analog.randomPulse > 2.5) = 1;

[c,lags] = xcorr(randomPulseNlx,randomPulseVicon);
[ ~,sortIdx] = max(c);
viconNlxLag(i) = lags(sortIdx)./1e3;    %in sec
end
end
