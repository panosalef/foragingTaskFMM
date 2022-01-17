function [occupancy,nanMask] = get2dOccup(X,Y,rangeX,rangeY,nX,nY,booleanSmooth)

x = linspace(rangeX(1),rangeX(2),nX);
y = linspace(rangeY(1),rangeY(2),nY);

dx = diff(x); dx = dx(1);
dy = diff(y); dy = dy(1);


for i = 1:length(x)
    for j = 1:length(y)
        
        x_pre = x(i) - dx/2; x_post = x(i) + dx/2;
        y_pre = y(j) - dy/2; y_post = y(j) + dy/2;
        match = (X > x_pre & X < x_post) & (Y > y_pre & Y < y_post);
        occupancy(j,i) = sum(match);
        
    end
end

nanMask = nan(size(occupancy));
nanMask(occupancy ~= 0) = 1;

if booleanSmooth
    
    [xx, yy] = meshgrid(x, y);
    % smooth error vectors
    prob_occupancy = sum(~isnan(nanMask(:)))/numel(nanMask(:));
    for i=1:length(x)
        for j=1:length(y)
            % construct weight profile
            sig_x = 40; sig_y = 40;
            g = exp(-(((xx-x(i)).^2)/(2*sig_x^2)+((yy-y(j)).^2)/(2*sig_x^2)));
            g = (g/sum(g(:)))/prob_occupancy;
            % apply weights
            sumOcc = g.*occupancy;
            occupSmooth(j,i) = nansum(sumOcc(:));
        end
    end
    
 occupancy = occupSmooth;   
end
end