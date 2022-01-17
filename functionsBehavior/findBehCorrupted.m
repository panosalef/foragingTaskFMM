function  corruptionIdx = findBehCorrupted(trialPaths)

% Find files
nSessions = numel(trialPaths);

% load files
for ss=1:nSessions
    
    
    for ff=1:numel(trialPaths{ss})% block = trial(Paths)
        fid = fopen(trialPaths{ss}{ff});
        
        if ~(fid>0)
            error('Could not find behavioral file');
        end
        
        while 1
            line = fgetl(fid);
            if line<0
                break
            end
            
            if contains(line,'tEnd')
                tEndTrial{ss}(ff,:) = sscanf(line,'tEnd: %f');
            end 
        end
        fclose(fid);
    end
    
corruptionIdx = cellfun(@(x) x~=0 ,tEndTrial ,'UniformOutput' ,false);
% corruptedFiles = cellfun(@(x,y) x(y) ,trialPaths,corruptionIdx,'UniformOutput' ,false);
% corruptedFiles = corruptedFiles{:};

    
end