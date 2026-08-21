classdef behavior < handle
    %BEHAVIOR  Behavioural data of one session.
    %   Properties (filled by addTrials -> importBehavior):
    %     trials  struct array, one per push-to-push trial (events, params, continuous)
    %     iti     continuous variables during inter-trial intervals
    %     block   continuous, unsegmented block time series (50 Hz)
    %     stats   per-block summary statistics
    %
    %   See also importBehavior, session.
    properties
        %         comments
        trials
        iti
        block
        stats
    end
    %%
    methods
        %% class constructor
        %         function this = behavior(comments)
        %             this.comments = comments;
        %         end

        
        
    end
end