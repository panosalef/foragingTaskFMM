function plotUnfoldedArena

rho = 1860; h = 2100; %side and height of arena in mm
theta = 0:60:360;
xHex = cosd(theta)*rho;
yHex = sind(theta)*rho;

x1Wall = 0; y1Wall = 0;
x2Wall = 0; y2Wall = h ;
x3Wall = rho; y3Wall = h;
x4Wall = rho; y4Wall = 0 ;

xWall = [x1Wall x2Wall x3Wall x4Wall x1Wall];
yWall = [y1Wall y2Wall y3Wall y4Wall y1Wall];

wallFlip = -1.5*rho;
for i=1:6
plot3(xWall + wallFlip +(i-1)*rho,yWall,zeros(1,numel(xWall)),'LineWidth',2,'Color','k'),hold on
end

xBox = [ rho/2 - 304 rho/2 - 304 rho/2 + 304 rho/2 + 304 rho/2 - 304];
yBox = [0 608 608 0 0]; 

for i = 1:2:6
plot3(xBox + wallFlip +(i-1)*rho,yBox,zeros(1,numel(xBox)),'LineWidth',2,'Color','k'),hold on
end

plot3(xHex+3*rho,yHex + h + rho*sqrt(3)./2 + 100 ,zeros(1,numel(xHex)),'LineWidth',2,'Color','k'),hold on % ceil
plot3(xHex,yHex + h + rho*sqrt(3)./2 + 100,zeros(1,numel(xHex)),'LineWidth',2,'Color','k'),hold on % floor

end