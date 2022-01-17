%% add behaviour
function this = addBehavior(this,prs)
%     cd(prs.filepath_behv);
this.behaviors = behavior;
this.behaviors.addTrials(prs);
%     this.behaviours.AnalyseBehaviour(prs);
%     this.behaviours.UseDatatype('single');
end