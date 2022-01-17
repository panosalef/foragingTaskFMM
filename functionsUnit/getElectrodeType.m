function electrodeType = getElectrodeType(electrodeTypeList,channelsPerArea,channelId)
electrodeTypeIdx = find((cumsum(channelsPerArea) - channelId) >= 0 ,1);
electrodeType = electrodeTypeList{electrodeTypeIdx};
end