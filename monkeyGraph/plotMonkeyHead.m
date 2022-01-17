function monkHandle = plotMonkeyHead(xMonk,yMonk,yawMonk,rMonk)

monkColor1 = [101,67,33]./256 ;
monkColor2 = [229, 211, 179]./256 ;

thetaEar = 0:120:240;
thetaEar = thetaEar + yawMonk;
xEar = rMonk*cosd(thetaEar)+ xMonk;
yEar = rMonk*sind(thetaEar)+ yMonk;

thetaEye = [-30 30];
thetaEye = thetaEye + yawMonk;
xEye = rMonk*cosd(thetaEye)+ xMonk;
yEye = rMonk*sind(thetaEye)+ yMonk;

thetaMouth = 0;
thetaMouth = thetaMouth + yawMonk; 
xMouth = rMonk./1.2*cosd(thetaMouth)+ xMonk;
yMouth = rMonk./1.2*sind(thetaMouth)+ yMonk;


% monkMouth  = filledEllipse_v3(xMonk,yMonk,rMonk./1.5,rMonk,.85,yawMonk,monkColor2);
% monkMouth = filledEllipse(xMonk,yMonk+rMonk,rMonk./1.5,1.8,1,yawMonk,monkColor2);
monkMouth = filledCircle(xMouth,yMouth,rMonk./2,monkColor2);
monkEar1 = filledCircle(xEar(2),yEar(2),rMonk*.3,monkColor2); 
monkEar2 = filledCircle(xEar(3),yEar(3),rMonk*.3,monkColor2);
monkEye1 = filledCircle(xEye(1),yEye(1),rMonk./7,'k');
monkEye2 = filledCircle(xEye(2),yEye(2),rMonk./7,'k');
monkHead = filledCircle(xMonk,yMonk,rMonk,monkColor1);



monkHandle = [monkMouth,monkEar1,monkEar2,monkEye1,monkEye2,monkHead];
% hold on

end