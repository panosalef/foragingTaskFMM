function monkTail = plotMonkTail(xMonk,yMonk,rHead,yawMonk)
%PLOTMONKTAIL  Dot marking the back of the head glyph (opposite the yaw direction).

thetaTail = 180;
thetaTail = thetaTail + yawMonk;


xTail = rHead*cosd(thetaTail)+ xMonk;
yTail= rHead*sind(thetaTail)+ yMonk;

monkTail = plot(xTail,yTail,'.k') ;




end