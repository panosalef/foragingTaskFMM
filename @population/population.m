classdef population < handle
    %POPULATION  Population-level summaries of a session (units or LFPs).
    %   Placeholder container filled by session/addPopulation.
    %
    %   See also session, unit, lfp.
    properties
        units
        singleunit
        multiunit
        lfps
    end
    
    %%
    methods
        %% class constructor
        function this = population()
            this.units = [];
            this.singleunit = [];
            this.multiunit = [];
            this.lfps =  [];
        end
    end
end