function addTrials(this,spikeTimes,trialsBeh,blockBeh)
[trialsOut,itiOut] = addTrials2Unit(spikeTimes,trialsBeh,blockBeh);
this.trials = trialsOut;
this.iti = itiOut;
end
