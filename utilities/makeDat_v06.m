
%% makeDat_v06(filePath [,channels])
% Open a ns6 or plx file and make a dat file
% - filePath: full file path, must include folder (ex:
% 'C:/Users/user/Documents/MATLAB/data/file.plx'). For Neuralynx files,
% only the root of the file names should be provided followed by
% *.ncs (ex: 'path/root*.ncs')
% - channels: channel numbers vector, use default values if not provided

function makeDat_v06(inputFile, varargin)

% options
timeChunk = 100;
formatsList = {'.ns6','.plx','.ncs'};

[filePath,fileName,fileExt] = fileparts(inputFile);
fileFormat = find(strcmp(fileExt,formatsList));

if isempty(fileFormat) && ~isempty(dir([inputFile '*.ncs']))
    fileFormat = '.ncs';
end

if isempty(fileFormat)
    error('Wrong file extension');
end

switch fileFormat
    
    %% NS6 files
    case formatsList{1}
        fprintf('NS6 file detected\n');
        if nargin>1
            channelsList = varargin{2};
        else
            channelsList = 1:96;
            fprintf('No channels provided, using default.\n');
        end
        channelsStr = sprintf('c:%i%s',channelsList(1),sprintf(',%i',channelsList(2:end)));
        fprintf('Extracting channels: %s\n',channelsStr);
        
        fprintf('\nOpen neural info')
        info = openNEV(sprintf('%s.nev',fullfile(filePath,fileName)),'nomat','nosave');
        fileDuration = info.MetaTags.DataDuration/info.MetaTags.TimeRes;
        samplingFreq = info.MetaTags.TimeRes;
        fidMaster = fopen('master.dat','w');
        
        tt = 0;
        while 1
            tt = tt+1;
            fprintf('\nRewriting data..%i%%',ceil(100*tt/ceil(fileDuration/timeChunk)));
            sampleStart = (tt-1)*timeChunk*samplingFreq+1;
            sampleStop = min(tt*timeChunk*samplingFreq,info.MetaTags.DataDuration);
            data = openNSx(sprintf('%s.ns6',fullfile(filePath,fileName)),'read',channelsStr,sprintf('t:%f:%f',sampleStart,sampleStop),'sample');
            
            fwrite(fidMaster,data.Data(:),'int16');
            
            if (sampleStop>=fileDuration*samplingFreq)
                break;
            end
        end
        fclose(fidMaster);
        
        %% PLX files
    case formatsList{2}
        fprintf('PLX file detected\n');
        if nargin>1
            channelsList = varargin{2};
        else
            channelsList = 32:47;
            fprintf('No channels provided, using default.\n');
        end
        channelsStr = sprintf('%i%s',channelsList(1),sprintf(',%i',channelsList(2:end)));
        fprintf('Extracting channels: %s\n',channelsStr);
        
        samplingFreq = 20000;   % harcoding sampling freq because plx_information returns
        % max freq and not freq of AD data.
        
        % Get general information
        [~,~,~,~,~,~,~,~,~,SlowPeakV] = plx_information(sprintf('%s.plx',fullfile(filePath,fileName)));
        chunkSize = timeChunk*samplingFreq;
        
        % Extract it channel to a .chan file
        fid = NaN(length(channelsList),1);
        for cc=1:length(channelsList)
            fprintf('\nOpening channel %i/%i',cc,length(channelsList));
            [~,~,~,~,ad] = plx_ad_v(sprintf('%s.plx',fullfile(filePath,fileName)),channelsList(cc));
            fid(cc) = fopen(sprintf('temp%i.chan',cc),'w');
            fwrite(fid(cc),int16(ad*0.5*(2^16-1)/(SlowPeakV/1000)),'int16');
            fclose(fid(cc));
            npoints = size(ad,1);
            clear ad
        end
        
        % Read each channel chunck by chunk and write them side by side
        % in the master file
        fid = NaN(length(channelsList),1);
        for cc=1:length(channelsList)
            fid(cc) = fopen(sprintf('temp%i.chan',cc),'r');
        end
        
        fprintf('\n\n\nCreating master file');
        fidMaster = fopen('master.dat','w');
        for chunk=(1:ceil(npoints/chunkSize))
            fprintf('\nWriting chunks..%i/%i',chunk,ceil(npoints/chunkSize));
            temp = NaN(min(chunkSize,npoints-(chunk-1)*chunkSize),length(channelsList));
            for cc=1:length(channelsList)
                temp(:,cc) = fread(fid(cc),chunkSize,'int16');
            end
            for ss=1:min(chunkSize,npoints-(chunk-1)*chunkSize)
                fwrite(fidMaster,temp(ss,:),'int16');
            end
        end
        
        for cc=1:length(channelsList)
            fclose(fid(cc));
            delete(sprintf('temp%i.chan',cc));
        end
        fclose(fidMaster);
        
        %% NCS file
    case formatsList{3}
        fprintf('NCS file detected\n');
        path = fileparts(inputFile);
        cd(path);
        filesList = dir([inputFile,'*.ncs']);
        filesList = filesList(~ismember({filesList.name},{'.','..'}));
        fprintf('Found %i files\n',length(filesList));
        
        chanNumStr = arrayfun(@(x) split(x.name,{'CSC','.'}), filesList,'un',0);
        chanNumDouble = cellfun(@(x) str2double(x(2)),chanNumStr);
        [~,sortIdx] = sort(chanNumDouble);
        fileNamesSorted = {filesList(sortIdx).name};
        
        % Get general information %maybe do it with nev file
        [Timestamps, ~, ~, numberOfSamples] = Nlx2MatCSC(filesList(1).name,[1,1,1,1,0],0,1);
        
        timeChunk = 100000;
        nChunks = ceil(length(numberOfSamples)/timeChunk);
        
        % Write master file
        fprintf('\n\n\nCreating master file');
        fidMaster = fopen('master.dat','w');
        for chunk=(1:nChunks)
            fprintf('\nWriting chunks..%i/%i \n',chunk,nChunks);
            temp = NaN(length(filesList),512*timeChunk);
            for cc=1:length(fileNamesSorted)
                disp(fileNamesSorted{cc})
                tmp = Nlx2MatCSC(fileNamesSorted{cc},[0,0,0,0,1],0,4,[Timestamps((chunk-1)*timeChunk+1),Timestamps(min(chunk*timeChunk,length(Timestamps)))]);
                
                temp(cc,1:numel(tmp)) = reshape(tmp,1,numel(tmp));
            end
            temp = temp(1:size(temp,1),~isnan((temp(1,:))));
            fwrite(fidMaster,temp,'int16');
        end
        fclose(fidMaster);
end

end

