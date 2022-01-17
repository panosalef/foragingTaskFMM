function  [hexVertices,hexParams] = arena3d(booleanPlot,boooleanBoxes)

rho = 1860; h = 2100; %side and height of arena in mm
theta = 0:60:360;
x = cosd(theta)*rho;
y = sind(theta)*rho;

if booleanPlot
    hold on,
    plot3(x ,y,zeros(1,numel(x)),'LineWidth',2,'Color','k'),hold on
    plot3(x ,y,zeros(1,numel(x))+h,'LineWidth',2,'Color','k')
    for pp = 1:6 ;line([x(pp) x(pp)],[y(pp) y(pp)],[0 h],'Linewidth',2,'Color','k'),end % vertical Lines
end

squareX = [-304 -304 304 304 -304] ;
squareY = sqrt(3)*1860/2*ones(1,5) ;
% squareZ = [608 1216 1216 608 608];
squareZ = [0 608 608 0 0];
square = [squareX' squareY' squareZ'];

for angle = [60 180 300]
    
    R = rotz(angle);
    squareTemp = square*R;
    if booleanPlot && boooleanBoxes
        hold on,
        plot3(squareTemp(:,1),squareTemp(:,2),squareTemp(:,3),'LineWidth',2,'Color',[255 128 0]./256)
    end
    
end
%reorder arena vertice(x,y,z) so the that first element in the array corresponds to vertice 1 according to convention 
xOut = x([5 6 1 2 3 4]);
yOut = y([5 6 1 2 3 4]);

hexVertices.floor = [xOut ; yOut ; zeros(1,6)];
hexVertices.ceil = [xOut ; yOut ; h*ones(1,6)];
hexParams.rho = rho;
hexParams.h = h;

if booleanPlot
    hold off
    rotate3d on
end

end


