function [trials,iti,block] = addTrials2Lfp(channel,trialsBeh,blockBeh,srLfp,viconNlxLag)

t = 1:1/srLfp:numel(channel);
t = t-viconNlxLag;

tStart = arrayfun(@(x) x.events.tStart,trialsBeh);
tEnd = arrayfun(@(x) x.events.tEnd,trialsBeh);
for i  = 1:numel(trialsBeh)
    
    trials(i).lfp = channel(t < tEnd(i) & tStart(i) < t);
    
    iti(i).lfp = channel(t >= tStart(i)  & t <= ...
                sum([(i+1)<numel(tStart) (i+1)>numel(tStart)].*...
                [tStart(min(i+1,numel(tStart))) blockBeh.t(end)]));
    
end

block = channel(t >= 0 & t <= blockBeh.t(end));
end

