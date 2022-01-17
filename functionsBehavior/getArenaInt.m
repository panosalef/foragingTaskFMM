function I = getArenaInt(front,centroid)


[hexVertices,hexParams] = arena3d(0,0);
plane1 = [hexVertices.floor(:,1:2) hexVertices.ceil(:,1)];
normal1 = cross(plane1(:,2)-plane1(:,1),plane1(:,3)-plane1(:,1));
plane2 = [hexVertices.floor(:,2:3) hexVertices.ceil(:,2)];
normal2 = cross(plane2(:,2)-plane2(:,1),plane2(:,3)-plane2(:,1));
plane3 = [hexVertices.floor(:,3:4) hexVertices.ceil(:,3)];
normal3 = cross(plane3(:,2)-plane3(:,1),plane3(:,3)-plane3(:,1));
plane4 = [hexVertices.floor(:,4:5) hexVertices.ceil(:,4)];
normal4 = cross(plane4(:,2)-plane4(:,1),plane4(:,3)-plane4(:,1));
plane5 = [hexVertices.floor(:,5:6) hexVertices.ceil(:,5)];
normal5 = cross(plane5(:,2)-plane5(:,1),plane5(:,3)-plane5(:,1));
plane6 = [hexVertices.floor(:,[6 1]) hexVertices.ceil(:,6)];
normal6 = cross(plane6(:,2)-plane6(:,1),plane6(:,3)-plane6(:,1));
plane7 = hexVertices.floor(:,1:3);  %floor
normal7 = cross(plane7(:,1)-plane7(:,2),plane7(:,3)-plane7(:,2));
plane8 = hexVertices.ceil(:,1:3);  %ceiling
normal8 = cross(plane8(:,3)-plane8(:,2),plane8(:,1)-plane8(:,2));

tol =1;% equality tolerance in mm, for floating number

%% test 2

% Plane 1
[I1,~]=plane_line_intersect(normal1,plane1(:,1),front,centroid);

constrain1 = hexVertices.floor(1,1) - tol <= I1(1) & hexVertices.floor(1,2) + tol >= I1(1) & ...
    hexVertices.floor(2,1) - tol <= I1(2) & hexVertices.floor(2,2) + tol >= I1(2) &...
    I1(3) > 0 & I1(3) < hexParams.h ;


% Plane 2
[I2,~]=plane_line_intersect(normal2,plane2(:,1),front,centroid);

constrain2 = hexVertices.floor(1,2) - tol <= I2(1) & hexVertices.floor(1,3) + tol >= I2(1) & ...
    hexVertices.floor(2,2) - tol <= I2(2) & hexVertices.floor(2,3) + tol >= I2(2) &...
    I2(3) > 0 & I2(3) < hexParams.h ;


% Plane 3
[I3,~]=plane_line_intersect(normal3,plane3(:,1),front,centroid);

constrain3 = hexVertices.floor(1,3) + tol >= I3(1) & hexVertices.floor(1,4) - tol <= I3(1) & ...
    hexVertices.floor(2,3) - tol <= I3(2) & hexVertices.floor(2,4) + tol >= I3(2) &...
    I3(3) > 0 & I3(3) < hexParams.h ;

% Plane 4
[I4,~]=plane_line_intersect(normal4,plane4(:,1),front,centroid);
constrain4 = hexVertices.floor(1,5) - tol <= I4(1) & hexVertices.floor(1,4) + tol >= I4(1) & ...
    hexVertices.floor(2,4) - tol <= I4(2) & hexVertices.floor(2,5) + tol >= I4(2) &...
    I4(3) > 0 & I4(3) < hexParams.h ;



% Plane 5
[I5,~]=plane_line_intersect(normal5,plane5(:,1),front,centroid);

constrain5 = hexVertices.floor(1,6) - tol <= I5(1) & hexVertices.floor(1,5) + tol >= I5(1) & ...
    hexVertices.floor(2,6) - tol <= I5(2) & hexVertices.floor(2,5) + tol >= I5(2) &...
    I5(3) > 0 & I5(3) < hexParams.h ;

% Plane 6
[I6,~]=plane_line_intersect(normal6,plane6(:,1),front,centroid);

constrain6 = hexVertices.floor(1,6) - tol <= I6(1) & hexVertices.floor(1,1) + tol >= I6(1) & ...
    hexVertices.floor(2,1) - tol <= I6(2) & hexVertices.floor(2,6) + tol >= I6(2) &...
    I6(3) > 0 & I6(3) < hexParams.h ;


% Plane 7
[I7,~]=plane_line_intersect(normal7,plane7(:,1),front,centroid);
% cevian length as a function of angle(combination of Stewart's theorem & Law of Sines)
theta7 = abs(atan2d(I7(2),I7(1)));
constrain7 = (sqrt(hexParams.rho.^2 - (hexParams.rho^2)*(sind(mod(theta7,60))./sind(120-mod(theta7,60))) + ...
    (hexParams.rho*(sind(mod(theta7,60))./sind(120-mod(theta7,60)))).^2) + tol)  >= norm([I7(1) I7(2)]);

% Plane 8
[I8,~] = plane_line_intersect(normal8,plane8(:,1),front,centroid);
% cevian length as a function of angle(combination of Stewart's theorem & Law of Sines)
theta8 = abs(atan2d(I8(2),I8(1)));
constrain8= (sqrt(hexParams.rho.^2 - (hexParams.rho^2)*(sind(mod(theta8,60))./sind(120-mod(theta8,60))) + ...
    (hexParams.rho*(sind(mod(theta8,60))./sind(120-mod(theta8,60)))).^2) + tol)  >= norm([I8(1) I8(2)]);



if constrain1 && dot(normal1,front - centroid) > 0
    I = I1;
    
elseif constrain2 && dot(normal2,front - centroid) > 0
    I = I2;
    
elseif constrain3 && dot(normal3,front - centroid) > 0
    I = I3;
    
elseif constrain4 && dot(normal4,front - centroid) > 0
    I = I4;
    
elseif constrain5 && dot(normal5,front - centroid) > 0
    I = I5;
    
elseif constrain6 && dot(normal6,front - centroid) > 0
    I = I6;
    
elseif constrain7 && dot(normal7,front - centroid) > 0
    I = I7;
    
elseif constrain8 && dot(normal8,front - centroid) > 0
    I = I8;
else
    %     I = zeros(3,1);
    I = nan(3,1);
    
end


end