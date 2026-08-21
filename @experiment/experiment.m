classdef experiment < handle
    %EXPERIMENT  Top-level container: one protocol, many sessions.
    %   e = experiment('foraging') creates an empty experiment. Use
    %   e.addSessions(monkeyName, sessionId, content) to import a session's
    %   behaviour and, optionally, its LFPs, single/multi units and population
    %   summaries. Sessions are stored in e.sessions (array of session).
    %
    %   Object graph:  experiment > session > {behavior, unit(s), lfp(s), population}
    %
    %   See also session, behavior, unit, lfp, population, experiment/addSessions.
    properties
        name                                                                % protocol
        sessions = session.empty();
    end
     
    %%
    methods
        %% class constructor
        function this = experiment(exp_name)
            this.name = exp_name;
        end
    end
end