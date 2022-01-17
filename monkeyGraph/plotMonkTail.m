function monkTail = plotMonkTail(xMonk,yMonk,rHead,yawMonk)

thetaTail = 180;
thetaTail = thetaTail + yawMonk;


xTail = rHead*cosd(thetaTail)+ xMonk;
yTail= rHead*sind(thetaTail)+ yMonk;

monkTail = plot(xTail,yTail,'.k') ;




end