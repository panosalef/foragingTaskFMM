%% sessionLoader.m  -  example: import one session into the object model
% Edit the animal, date and content list, then run. Requires the data share
% to be mounted (see fmmDataRoot) and this repository on the MATLAB path:
%   addpath(genpath(pwd))
clear, clc

experiment = experiment('foraging');
experiment.addSessions('Marco', 20220106, {'behv','lfps'});   % content: 'lfps' | 'units' | 'population'

% Plain structs are often handier than handle objects for downstream analysis
units     = obj2struct(experiment.sessions.units);
behaviors = obj2struct(experiment.sessions.behaviors);
lfps      = obj2struct(experiment.sessions.lfps);
