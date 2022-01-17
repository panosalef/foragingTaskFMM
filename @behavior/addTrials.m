function this = addTrials(this,prs)
[blockOut,trialsOut,itiOut,statsOut] = importBehavior(prs);
this.trials = trialsOut;
this.block = blockOut;
this.iti = itiOut;
this.stats = statsOut;
end
