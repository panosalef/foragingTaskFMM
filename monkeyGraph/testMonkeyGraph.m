close all,
clear
clc
% monkHandle = plotMonkeyHead(0,0,0,1);
axis([-10 10 -10 10])

xMonk = -9:.1:9;
yMonk = -9:.1:9;
yawMonk = 1:(360/numel(-9:.1:9)):360;
rMonk = 8;

% figure
tailLength = 27;
for i = 1:numel(xMonk)
monkHandle = plotMonkeyHead(xMonk(i),yMonk(i),yawMonk(i),rMonk);hold on
p = plotMonkTail(xMonk(max(i-tailLength,tailLength+1):i),yMonk(max(i-tailLength,tailLength+1):i),...
    rMonk,yawMonk(max(i-tailLength,tailLength+1):i));
axis([-10 10 -10 10])
pause(.02)
delete([monkHandle p])
end