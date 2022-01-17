classdef session < handle
    %%
    properties
        monkeyName
        sessionId
        behaviors = behavior.empty();                                     % trial
        units = unit.empty();                                               % single/multiunit
        lfps = lfp.empty();                                                 % lfp
        populations = population.empty();                                   % population
    end
    %%
    methods
        %% class constructor
        function this = session(monkeyName,sessionId)
            this.monkeyName = monkeyName;
            this.sessionId = sessionId;
        end
    end
end