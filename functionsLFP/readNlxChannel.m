function channelOut = readNlxChannel(neuralRawPath,channelId)
channelPath = [neuralRawPath,'CSC',num2str(channelId),'.ncs'];
channelOut = Nlx2MatCSC(channelPath,[0,0,0,0,1],0,1,0);
channelOut = channelOut(:)';
end

