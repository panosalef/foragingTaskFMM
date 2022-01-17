function h = filledEllipse_v2(x,y,mouthR,headR,eccentricity,yaw,color)
% color= [229, 211, 179]./256 ;
% x = 0;
% y = 0;
% r = 1;
% yaw = 45;

xRot = x + headR*sind(yaw);
yRot = y + headR*cosd(yaw);

x1 = xRot + mouthR*sind(yaw);
x2 = xRot - mouthR*sind(yaw);

y1 = yRot + mouthR*cosd(yaw);
y2 = yRot - mouthR*cosd(yaw);
% eccentricity = .85;
numPoints = 300; % Less for a coarser ellipse, more for a finer resolution.

% Make equations:
a = (1/2) * sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2);
b = a * sqrt(1-eccentricity^2);
t = linspace(0, 2 * pi, numPoints); % Absolute angle parameter
X = a * cos(t);
Y = b * sin(t);
% Compute angles relative to (x1, y1).
angles = atan2(y2 - y1, x2 - x1);
xOut = (x1 + x2) / 2 + X * cos(angles) - Y * sin(angles);
yOut = (y1 + y2) / 2 + X * sin(angles) + Y * cos(angles);

h =fill(xOut,yOut ,color);

end