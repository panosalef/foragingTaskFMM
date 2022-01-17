function idxOut = nanTracker(arrayIn,sr,timeWin)
% This function finds the indices of NaN sequencies longer than the
% timeWindow, sr is the sampling rate
startNan = [];endNan = [];
for i = 1:numel(arrayIn)
    if i == 1
        if isnan(arrayIn(i))
            startNan(end+1) = i;
        end
    else
        
        if isnan(arrayIn(i)) && ~isnan(arrayIn(i-1))
            startNan(end+1) = i;
        elseif ~isnan(arrayIn(i)) && isnan(arrayIn(i-1))
            endNan(end+1) = i-1;
        end 
    end
end

if numel(startNan) > numel(endNan)
endNan(end+1) = numel(arrayIn);
end

cleanIdx = (endNan-startNan)./sr < timeWin;
endNan(cleanIdx) = [];
startNan(cleanIdx) = [];

idxOut = [];
for i = 1:numel(startNan)
idxOut(end+1:end+numel(startNan(i):endNan(i))) = startNan(i):endNan(i);
end
idxOut = sort(idxOut );
end