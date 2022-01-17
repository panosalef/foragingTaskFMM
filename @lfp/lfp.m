classdef lfp < handle
    %%
    properties
        channelId
        electrodeId
        electrodeType
        electrodeConfig
        brainArea
        trials
        iti
        block
        stats
        stationary
        mobile
        eyesfixed
        eyesfree
        
    end
    %%
    methods
        %% class constructor
        function this = lfp(channelId,electrodeId,electrodeType)
            this.channelId = channelId;
            this.electrodeId = electrodeId;
            this.electrodeType = electrodeType;
        end
    end
end
