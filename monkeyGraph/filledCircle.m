function h = filledCircle(x,y,r,color)
%FILLEDCIRCLE  Filled circle patch at (x, y) with radius r.
hold on
th = 0:pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
% h = plot(xunit, yunit,);
h =fill(xunit,yunit,color,'LineStyle','none');
hold off
end