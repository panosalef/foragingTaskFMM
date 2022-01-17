function [trials,iti] = addTrials2Unit(spikeTimes,trialsBeh,blockBeh)

tStart = arrayfun(@(x) x.events.tStart,trialsBeh);
tEnd = arrayfun(@(x) x.events.tEnd,trialsBeh);
for i  = 1:numel(trialsBeh)
    
    trials(i).spkTimes = spikeTimes(spikeTimes < tEnd(i) & tStart(i) < spikeTimes);
    
    iti(i).spkTimes = spikeTimes(spikeTimes >= tStart(i)  & spikeTimes <= ...
                sum([(i+1)<numel(tStart) (i+1)>numel(tStart)].*...
                [tStart(min(i+1,numel(tStart))) blockBeh.t(end)]));
    
end
end

