function position1dArena = getArena1dPosition(X,Y,rangeX,rangeY,nX,nY)
position1dArena = NaN(1,numel(X));

x = linspace(rangeX(1),rangeX(2),nX);
y = linspace(rangeY(1),rangeY(2),nY);

dx = diff(x); dx = dx(1);
dy = diff(y); dy = dy(1);

gridPosition = 1;
for i = 1:length(x)
    for j = 1:length(y)
        
        x_pre = x(i) - dx/2; x_post = x(i) + dx/2;
        y_pre = y(j) - dy/2; y_post = y(j) + dy/2;
        match = (X > x_pre & X < x_post) & (Y > y_pre & Y < y_post);
        position1dArena(match) = gridPosition ;
        gridPosition = gridPosition + 1;
    end
end


end