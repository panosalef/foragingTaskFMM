function addTrials(this,channel,trialsBeh,blockBeh,srLfp,viconNlxLag)

[trialsOut,itiOut,blockOut] = addTrials2Lfp(channel,trialsBeh,blockBeh,srLfp,viconNlxLag);

this.block = blockOut;
this.trials = trialsOut;
this.iti = itiOut;
end

