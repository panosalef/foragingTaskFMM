function dCevian = getHexCevian(theta)
%GETHEXCEVIAN  Distance from the arena centre to the hexagonal wall at angle theta (deg).
% theta = abs(atan2d(y,x));

[~,hexParams] = arena3d(0,0);

dCevian = (sqrt(hexParams.rho.^2 - (hexParams.rho^2)*(sind(mod(theta,60))./sind(120-mod(theta,60))) + ...
    (hexParams.rho*(sind(mod(theta,60))./sind(120-mod(theta,60)))).^2));



end