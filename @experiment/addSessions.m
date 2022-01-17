%% function to add sessions
function addSessions(this,monkeyName,sessionId,content) % e.g. content = {'behavior','lfps','units','population'}
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
