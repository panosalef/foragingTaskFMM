clear,clc;
experiment = experiment('foraging');
experiment.addSessions('Marco',20220106,{'behv','lfps'});
units = obj2struct(experiment.sessions.units);
behaviors = obj2struct(experiment.sessions.behaviors);
lfps = obj2struct(experiment.sessions.lfps);