function addSessions(this,monkeyName,sessionId,content)
%ADDSESSIONS  Import one session into the experiment.
%   e.addSessions(monkeyName, sessionId, content) builds a session object,
%   always imports behaviour, and optionally neural data:
%     content  cellstr with any of 'lfps', 'units', 'population'
%              e.g. {'behv','lfps'} or {'units','population'}
%   sessionId may be numeric (yyyymmdd) or char. Re-adding an existing
%   session asks before overwriting it.
%
%   See also experiment, expParams, session/addBehavior, session/addUnits,
%   session/addLfps.
sessionId = num2str(sessionId);
islfps = any(strcmp(content,'lfps')); isunits = any(strcmp(content,'units')); ispop = any(strcmp(content,'population'));
allsessions = this.sessions; oldInstance = find(strcmp(monkeyName,{allsessions.monkeyName}) & strcmp(sessionId,{allsessions.sessionId}));
if ~isempty(oldInstance)
    ovwrt = logical(input('This session was already analysed once. Press 1 to overwrite, 0 to quit \n'));
    if ovwrt, newInstance = oldInstance; % overwrite old instance
    else, return;
    end
else
    nSessions = numel(this.sessions);
    newInstance = nSessions + 1; % create new instance
end
prs = expParams(monkeyName,sessionId);
this.sessions(newInstance) = session(monkeyName,sessionId);
this.sessions(newInstance).addBehavior(prs);
if islfps % load and analyse LFPs
    this.sessions(newInstance).addLfps(prs);
%     this.sessions(newInstance).analyseLfps(prs);
end
if isunits % load and analyse neurons
    this.sessions(newInstance).addUnits(prs);
    %     this.sessions(newInstance).analyseUnits(prs);
end
if ispop && isunits, this.sessions(newInstance).addPopulation('units',prs);
elseif ispop && islfps, this.sessions(newInstance).addPopulation('lfps',prs);
end
end
