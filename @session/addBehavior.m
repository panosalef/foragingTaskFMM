function this = addBehavior(this,prs)
%ADDBEHAVIOR  Import the session's behaviour (see importBehavior).
%     cd(prs.filepath_behv);
this.behaviors = behavior;
this.behaviors.addTrials(prs);
%     this.behaviours.AnalyseBehaviour(prs);
%     this.behaviours.UseDatatype('single');
end