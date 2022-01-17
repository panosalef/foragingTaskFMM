function h = filledEllipse_v3(monkX,monkY,mouthR,headR,eccentricity,yaw,color)
% color= [229, 211, 179]./256 ;
% x = 0;
% y = 0;
% r = 1;
% yaw = 45;

aStart = (1/2) * sqrt((monkX - monkX) ^ 2 + (2*mouthR) ^ 2);
bStart = aStart * sqrt(1-eccentricity^2);

S = 2*pi*asind(bStart./2*headR);
h = headR*cos(S./headR);
inteceptCorr = headR - h;

xEllipse = [monkX monkX 1];
yEllipse = [monkY + mouthR , monkY - mouthR,1] + headR - inteceptCorr;

% yEllipse = [monkY + mouthR , monkY - mouthR,1] + headR;

Xc = monkX;  % X cener of rotation
Yc = monkY;  % Y center of rotation

% Shift X/Y to the rotation center
Xshift = xEllipse - Xc;        
Yshift = yEllipse - Yc;

% Rotate the coordinates
Xsrot =  Xshift*cosd(yaw) + Yshift*sind(yaw);
Ysrot = -Xshift*sind(yaw) + Yshift*cosd(yaw);

Xrot = Xsrot + Xc;
Yrot = Ysrot + Yc;

x1 = Xrot(1);  x2 = Xrot(2);
y1 = Yrot(1);  y2 = Yrot(2);

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