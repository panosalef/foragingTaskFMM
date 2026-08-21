function brainArea = getBrainArea(brainAreas,channelsPerArea,channelId)
%GETBRAINAREA  Brain area of a channel from the per-area channel counts.
brainAreaIdx = find((cumsum(channelsPerArea) - channelId) >= 0 ,1);
brainArea = brainAreas{brainAreaIdx};
end