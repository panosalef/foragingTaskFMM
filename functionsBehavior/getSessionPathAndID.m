function [sessionPath,sessionID] = getSessionPathAndID(monkeyName,datesList,sessionStage)

%% Generate session ID based on naming convention
dateString = arrayfun(@(x) num2str(x,'%02d'),datesList,'UniformOutput',false);

% dateString = strcat(yyyy,mm,dd);
sessionID = strcat(monkeyName,'_',dateString);

%% Generate Path
if ismac
    path1 = '/Volumes/server2/Monkeys/';
    path2 = strcat('/FMM/Data/',sessionStage,'/');
    sessionPath = strcat(path1,monkeyName,path2,sessionID);
end


if ispc
    path1 = 'Y:\Monkeys\';
    path2 = strcat('\FMM\Data\',sessionStage,'\');
    sessionPath = strcat(path1,monkeyName,path2,sessionID);
end




end

