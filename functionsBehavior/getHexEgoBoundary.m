function [rEgoB,thetaEgoB] = getHexEgoBoundary(position,headDirVec)

theta = 0:360;
r = getHexCevian(theta);
[x,y] = pol2cart(theta/180*pi, r);
xyArena(1,:) = x;
xyArena(2,:) = y;

for i =  1:size(position,2)
    if logical(sum(~isnan(position(:,i)))) && logical(sum(~isnan(headDirVec(:,i))))
     [d,idx]= min(sqrt(sum((xyArena - position(:,i)).^2,1)));
     rEgoB(i) = d;
     egoBVec(:,i) = xyArena(:,idx) - position(:,i);
    else
        rEgoB(i) = NaN;
        egoBVec(:,i) = NaN(2,1);
    end
    
end
u = egoBVec;
v = headDirVec ;
thetaEgoB = -atan2d(u(1,:).*v(2,:)-u(2,:).*v(1,:), u(1,:).*v(1,:)+u(2,:).*v(2,:));

end
