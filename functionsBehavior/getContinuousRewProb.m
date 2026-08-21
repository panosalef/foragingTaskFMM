function continuousRewProb = getContinuousRewProb(timeVector,tPush,boxRewardRate)
%GETCONTINUOUSREWPROB  Probability that a box is armed at each time, given its
%   exponential reward rate and the push times that reset it: 1 - exp(-rate * t_since_push).
% Compute continuous probability of reward availability
timeVectorOut = timeVector;
counter = 0;
for i = 1:numel(tPush)
    tIdx = find(timeVector >= tPush(i),1);
    timeVectorOut(tIdx:end) = timeVectorOut(tIdx:end) - tPush(i) + min(1,(i-1))*tPush(max((i-1),1));
    counter = counter + 1;
end
continuousRewProb = 1-exp(-(boxRewardRate)*timeVectorOut);
end


