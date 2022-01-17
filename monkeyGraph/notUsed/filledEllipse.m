function h = filledEllipse(xMonk,yMonk,r,a,b,yaw,color)
hold on
th = 0:pi/50:2*pi;
xunit = r * cos(th) + xMonk;
yunit = r * sin(th) + yMonk;


Xc = xMonk;  % X cener of rotation
Yc = yMonk;  % Y center of rotation

% Shift X/Y to the rotation center
Xshift = xunit - Xc;        
Yshift = yunit - Yc;

% Rotate the coordinates
Xsrot =  Xshift*cosd(yaw) + Yshift*sind(yaw);
Ysrot = -Xshift*sind(yaw) + Yshift*cosd(yaw);

Xrot = Xsrot + Xc;
Yrot = Ysrot + Yc;



h =fill(Xrot(1,:)./a,Yrot(1,:)./b,color);


hold off
end