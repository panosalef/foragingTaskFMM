function channelOut = readNlxChannel(neuralRawPath,channelId)
%READNLXCHANNEL  Load one continuous Neuralynx channel (CSC<id>.ncs) as a row
%   vector of samples, via the Neuralynx MATLAB import tools in utilities/.
channelPath = [neuralRawPath,'CSC',num2str(channelId),'.ncs'];
channelOut = Nlx2MatCSC(channelPath,[0,0,0,0,1],0,1,0);
channelOut = channelOut(:)';
end

