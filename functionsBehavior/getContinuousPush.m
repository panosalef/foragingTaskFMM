function continuousPush = getContinuousPush(timeVector,tPush)
%GETCONTINUOUSPUSH  Binary push train on a time grid (1 at the sample of each push).
% Compute continuous probability of reward availability
vectorOut = zeros(1,numel(timeVector));

for i = 1:numel(tPush)
    tIdx(i) = find(timeVector >= tPush(i),1);    
end

vectorOut(tIdx) = 1;
continuousPush = vectorOut;

end
