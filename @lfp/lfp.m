classdef lfp < handle
    %LFP  One LFP channel of a session.
    %   Built by session/addLfps: the raw Neuralynx channel is band-pass
    %   filtered, downsampled to prs.srLfp and aligned to the behaviour clock;
    %   addTrials cuts it into trials, ITIs and the whole block.
    %
    %   See also readNlxChannel, addTrials2Lfp, session.
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
