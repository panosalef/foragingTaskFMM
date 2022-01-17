function  [sua,mua] = getUnitsPhy(prs)
spkTimes = readNPY([prs.sortedPath,'\','spike_times.npy']);
clusterIds = readNPY([prs.sortedPath,'\','spike_clusters.npy']);
clusterInfo = tdfread([prs.sortedPath,'\','cluster_info.tsv']);

load([prs.sortedPath,'\','waveForms.mat']);
load([prs.sortedPath,'\','QualityMetr.mat']);

electrodeId = mapChannel2Electrode(prs.electrodeConfig);%%%% prs spot


suaIdx = find(strtrim(string(clusterInfo.group))=='good');
if ~isempty(suaIdx)
    
    for i = 1:numel(suaIdx)
        
        sua(i).spkTimes = spkTimes(clusterIds == clusterInfo.id(suaIdx(i)))';
        sua(i).clusterId = clusterInfo.id(suaIdx(i));
        sua(i).channelId = clusterInfo.ch(suaIdx(i))+1;
        sua(i).electrodeId = electrodeId(sua(i).channelId);
        sua(i).electrodeType = getElectrodeType(prs.electrodeTypeList,prs.channelsPerArea,sua(i).channelId);
        sua(i).brainArea = getBrainArea(prs.brainAreas,prs.channelsPerArea,sua(i).channelId);
        sua(i).electrodeConfig = prs.electrodeConfig;
        sua(i).spkWf = waveFormsMean(suaIdx(i),:);
        sua(i).uQ = uQ(suaIdx(i)); sua(i).cR = cR(suaIdx(i)); sua(i).isiV = isiV(suaIdx(i));
        
    end
    
else
    
    sua.spkTimes = [];
    sua.clusterId = [];
    sua.channelId = [];
    sua.electrodeId = [];
    sua.electrodeType = [];
    sua.brainArea = [];
    sua.electrodeConfig = [];
    sua.spkWf = [];
    sua.uQ = []; sua.cR = []; sua.isiV = [];
    
    
end

muaIdx = find(strtrim(string(clusterInfo.group))=='mua');

if ~isempty(muaIdx)
    
    for i = 1:numel(muaIdx)
        
        mua(i).spkTimes = spkTimes(clusterIds == clusterInfo.id(muaIdx(i)))';
        mua(i).clusterId = clusterInfo.id(muaIdx(i));
        mua(i).channelId = clusterInfo.ch(muaIdx(i))+1;
        mua(i).electrodeId = electrodeId(mua(i).channelId);
        mua(i).electrodeType = getElectrodeType(prs.electrodeTypeList,prs.channelsPerArea,mua(i).channelId);
        mua(i).brainArea = getBrainArea(prs.brainAreas,prs.channelsPerArea,mua(i).channelId);
        mua(i).electrodeConfig = prs.electrodeConfig;
        mua(i).spkWf = waveFormsMean(muaIdx(i),:);
        mua(i).uQ = uQ(muaIdx(i)); mua(i).cR = cR(muaIdx(i)); mua(i).isiV = isiV(muaIdx(i));
        
    end
    
else
    
    mua.spkTimes = [];
    mua.clusterId = [];
    mua.channelId = [];
    mua.electrodeId = [];
    mua.brainArea = [];
    mua.electrodeType = [];
    mua.electrodeConfig = [];
    mua.spkWf = [];
    mua.uQ = []; mua.cR = []; mua.isiV = [];
    
end




