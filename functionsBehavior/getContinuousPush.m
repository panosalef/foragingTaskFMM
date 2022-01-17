function continuousPush = getContinuousPush(timeVector,tPush)
% Compute continuous probability of reward availability
vectorOut = zeros(1,numel(timeVector));

for i = 1:numel(tPush)
    tIdx(i) = find(timeVector >= tPush(i),1);    
end

vectorOut(tIdx) = 1;
continuousPush = vectorOut;

end
