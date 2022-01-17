function trialPaths = getTrialPaths(dataPath,fileExtension)

initialDir = dir; % Loop over seleced sessions
cd(dataPath);
sessionDir = dir(fileExtension);

if isempty(sessionDir)
    fprintf('No files found in: %s \n',dataPath)
end
trialPaths = strcat(dataPath,{sessionDir.name});
cd(initialDir(1).folder);

end