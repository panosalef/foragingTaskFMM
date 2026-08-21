classdef unit < handle
    %UNIT  One sorted unit (single or multi-unit) of a session.
    %   Constructed from a Phy/Kilosort cluster (see getUnitsPhy): identity
    %   (cluster, channel, electrode, brain area), mean waveform and width,
    %   and spike times on the behaviour clock (Neuralynx time minus the
    %   Vicon-Neuralynx lag). addTrials then cuts spikes into trials and ITIs.
    %
    %   See also getUnitsPhy, getViconNlxLag, addTrials2Unit, session.
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