function prs = expParams(monkeyName,sessionId)

%% session specific paramters
monkeyInfoFile;
monkeyInfo = monkeyInfo(strcmp(monkeyName,{monkeyInfo.monkeyName}) & strcmp(sessionId,{monkeyInfo.sessionId}));

prs.monkeyName = monkeyInfo.monkeyName;
prs.sessionId = monkeyInfo.sessionId;
prs.stage = monkeyInfo.stage;
prs.viconPath = ['Y:\Monkeys\',prs.monkeyName,'\FMM\Data\',prs.stage,'\',prs.monkeyName,'_',prs.sessionId,'\Vicon\'];
prs.behPath = ['Y:\Monkeys\',prs.monkeyName,'\FMM\Data\',prs.stage,'\',prs.monkeyName,'_',prs.sessionId,'\Matlab\'];
prs.eyeCalibPath = ['Y:\Monkeys\',prs.monkeyName,'\FMM\Data\',prs.stage,'\',prs.monkeyName,'_',prs.sessionId,'\Eye Calibration\'];
prs.neuralRawPath = ['Y:\Monkeys\',prs.monkeyName,'\FMM\Data\',prs.stage,'\',prs.monkeyName,'_',prs.sessionId,'\Neural Recordings\'];
prs.sortedPath = [prs.neuralRawPath,'\Sorted'];
prs.electrodeTypeList = monkeyInfo.electrodeTypeList;
prs.electrodeConfig = monkeyInfo.electrodeConfig;
prs.brainAreas = monkeyInfo.brainAreas;
prs.channelsPerArea = monkeyInfo.channelsPerArea;

%% Foraging Task Parameters
prs.goodTrialPushThreshold = 20; % Minimum Number of pushes to consider a trial good
prs.arenaRho = 1860;
prs.arenaH = 2100;
prs.nxArena1d = 50; %number of "pixels" for arena discetization of x side

%% Acquizition Parameters
prs.srNlx = 3e+4;
prs.srBehavior = 50;
prs.srLfp = 500; % Target sr of continuous LFPs after downsample

%% LFP parameters
% lfp
prs.lfpFiltOrder = 4;
prs.lfpMinFreq = 0.5; % min frequency (Hz)
prs.lfpMaxFreq = 75; % max frequency (Hz)
prs.spectrumTapers = [1 1]; % [time-bandwidth-product number-of-tapers]
prs.spectrumTrialAve = 1; % 1 = trial-average
prs.spectrumMovingWin = [1.5 1.5]; % [window-size step-size] to compute frequency spectrum (s)
prs.minStationary = 0.5; % mimimum duration of stationary period for LFP analysis (s)
prs.minMobile = 0.5; % mimimum duration of mobile period for LFP analysis (s)
prs.lfpTheta = [6 12]; prs.lfpThetaPeak = 8.5;
prs.lfpBeta = [12 20]; prs.lfpBetaPeak = 18.5;
prs.staWindow = [-1 1]; % time-window of STA
prs.durationNanPad = 1; % nans to pad to end of trial before concatenating (s)
prs.phaseSlidingWindow = 0.05:0.05:2; % time-lags for computing time-varying spike phase (s)
prs.numPhaseBins = 25; % divide phase into these many bins

end