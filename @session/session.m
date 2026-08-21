classdef session < handle
    %SESSION  One recording/training session of one animal.
    %   Holds the behaviour (one behavior object), the sorted units, the LFP
    %   channels and the population summaries of a session. Populated through
    %   addBehavior, addUnits, addLfps, addPopulation; normally called via
    %   experiment/addSessions rather than directly.
    %
    %   See also experiment, behavior, unit, lfp, population.
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