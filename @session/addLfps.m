function addLfps(this,prs)

electrodeId = mapChannel2Electrode(prs.electrodeConfig);
[b,a] = butter(2,[prs.lfpMinFreq prs.lfpMaxFreq]/(prs.srNlx /2));
viconNlxLag = getViconNlxLag(prs.neuralRawPath,prs.viconPath);

for i = 1:sum(prs.channelsPerArea)
    channel = readNlxChannel(prs.neuralRawPath,i);
    channel = filtfilt(b,a,channel);
    N = round(prs.srNlx/prs.srLfp);
    channel = downsample(channel,N);
    
    this.lfps(end+1) = lfp(i,electrodeId(i),getElectrodeType(prs.electrodeTypeList,prs.channelsPerArea,i));
    this.lfps(end).brainArea = getBrainArea(prs.brainAreas,prs.channelsPerArea,i);
    this.lfps(end).addTrials(channel,this.behaviors.trials,this.behaviors.block,prs.srLfp,viconNlxLag);

    
end



% end