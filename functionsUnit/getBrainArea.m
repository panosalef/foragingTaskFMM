function brainArea = getBrainArea(brainAreas,channelsPerArea,channelId)
brainAreaIdx = find((cumsum(channelsPerArea) - channelId) >= 0 ,1);
brainArea = brainAreas{brainAreaIdx};
end