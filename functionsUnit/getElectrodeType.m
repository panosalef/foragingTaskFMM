function electrodeType = getElectrodeType(electrodeTypeList,channelsPerArea,channelId)
%GETELECTRODETYPE  Electrode type of a channel from the per-area channel counts.
electrodeTypeIdx = find((cumsum(channelsPerArea) - channelId) >= 0 ,1);
electrodeType = electrodeTypeList{electrodeTypeIdx};
end