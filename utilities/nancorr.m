

function [rho,pval] = nancorr(M)
%NANCORR  Pairwise correlation after dropping rows with any NaN.

    M(any(isnan(M),2),:) = [];
    [rho,pval] = corr(M);

end