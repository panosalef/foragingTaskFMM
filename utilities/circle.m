function  [xunit,yunit] = circle(x,y,r)
%CIRCLE  x, y coordinates of a circle centred at (x, y) with radius r.

th = 0:pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;

end