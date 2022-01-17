clear,clc
monkeyName = 'Marco';
sessionID = 20211213;
stage = 'Recordings';
[block,NeuralFileIdList] = importBehavior(monkeyName,sessionID,stage);

%%
markerOn = ~isnan(position.raw(1,:));
step = 4;
windowDur = 3000; % window duration, 3000 corresponds to 1 minute
patch = (1+((step-1)*windowDur)):step*windowDur;
% patch = 1100:1300;
figure,plot((1:numel(markerOn(patch)))*.02,markerOn(patch),'o'),ylim([-.5 1.5]);

%%
xMonk = position.interp(1,:);
yMonk = position.interp(2,:);
yawMonk = headDirEarth.interp ;
rMonk = 100;
tailLength = 100;

figure;
arena2d(1,1);
for i = 18000:18600%patch%numel(xMonk)
    monkHandle = plotMonkeyHead(xMonk(i),yMonk(i),yawMonk(i),rMonk);hold on
    p = plotMonkTail(xMonk(max(i-tailLength,tailLength+1):i),yMonk(max(i-tailLength,tailLength+1):i),...
        rMonk,yawMonk(max(i-tailLength,tailLength+1):i));
        fp = plot(headArenaInt(1,i),headArenaInt(2,i),'o','MarkerSize',5,'markerfacecolor','k');
    ep = plot(eyeArenaInt(1,i),eyeArenaInt(2,i),'o','MarkerSize',20,'markerfacecolor','r');
    axis([-2000 2000 -2000 2000])
    pause(.02)
    delete([monkHandle p ep fp])
end

%%



% yaw.raw2 = atan2d((markersAP0.front(1,:) - markersAP0.centroid(1,:)),(markersAP0.front(2,:) - markersAP0.centroid(2,:)));
yaw.raw2 (yaw.raw2  < 0) = yaw.raw2 (yaw.raw2  < 0) +360;
yaw.interp2 = fillmissing(yaw.raw2,'pchip',2);