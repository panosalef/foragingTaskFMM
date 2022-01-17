

function [rho,pval] = nancorr(M)

    M(any(isnan(M),2),:) = [];
    [rho,pval] = corr(M);

end