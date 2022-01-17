classdef unit < handle
    %%
    properties
        clusterId
        channelId
        electrodeId
        electrodeType
        electrodeConfig
        brainArea
        spkWf
        spkWidth
        type
        trials
        iti
        block
        stats
    end
    %%
    methods
        %% class constructor
        function this = unit(unittype,unit,sr,viconNlxLag)
            this.clusterId = unit.clusterId;
            this.channelId = unit.channelId;
            this.electrodeId = unit.electrodeId;
            this.electrodeType = unit.electrodeType;
            this.brainArea = unit.brainArea;
            this.electrodeConfig = unit.electrodeConfig;
            this.spkWf = unit.spkWf; %mean spike-waveform;
            this.spkWidth = computeSpikeWidth(unit.spkWf,sr);
            this.type = unittype;
            this.block.spkTimes = double(unit.spkTimes)./sr - viconNlxLag; % in sec
        end
        
    end
end