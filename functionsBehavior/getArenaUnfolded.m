function  arena2dPos = getArenaUnfolded(input)

[hexVertices,hexParams] = arena3d(0,0);
arena2dPos = nan(size(input));
wallFlip = 0;%hexParams.rho./2 ; %move wall relative to ceiling & floor

%% Constrains for each plane(walls & ceiling)

tol = 1 ;
constrain1 = hexVertices.floor(1,1) - tol <= input(1,:) & hexVertices.floor(1,2) + tol >= input(1,:) & ...
    hexVertices.floor(2,1) - tol <= input(2,:) & hexVertices.floor(2,2) + tol >= input(2,:) &...
    input(3,:) > tol & input(3,:) < hexParams.h - tol ;

constrain2 =  hexVertices.floor(1,2) - tol <= input(1,:) & hexVertices.floor(1,3) + tol >= input(1,:) & ...
    hexVertices.floor(2,2) - tol <= input(2,:) & hexVertices.floor(2,3) + tol >= input(2,:) &...
    input(3,:) > tol & input(3,:) < hexParams.h - tol  ;

constrain3 = hexVertices.floor(1,3) + tol >= input(1,:) & hexVertices.floor(1,4) - tol <= input(1,:) & ...
    hexVertices.floor(2,3) - tol <= input(2,:) & hexVertices.floor(2,4) + tol >= input(2,:) &...
    input(3,:) > tol & input(3,:) < hexParams.h - tol ;

constrain4 = hexVertices.floor(1,5) - tol <= input(1,:) & hexVertices.floor(1,4) + tol >= input(1,:) & ...
    hexVertices.floor(2,4) - tol <= input(2,:) & hexVertices.floor(2,5) + tol >= input(2,:) &...
    input(3,:) > tol & input(3,:) < hexParams.h - tol ;
 
constrain5 = hexVertices.floor(1,6) - tol <= input(1,:) & hexVertices.floor(1,5) + tol >= input(1,:) & ...
    hexVertices.floor(2,6) - tol <= input(2,:) & hexVertices.floor(2,5) + tol >= input(2,:) &...
    input(3,:) > tol & input(3,:) < hexParams.h - tol ;

constrain6 = hexVertices.floor(1,6) - tol <= input(1,:) & hexVertices.floor(1,1) + tol >= input(1,:) & ...
    hexVertices.floor(2,1) - tol <= input(2,:) & hexVertices.floor(2,6) + tol >= input(2,:) &...
    input(3,:) > tol & input(3,:) < hexParams.h - tol ;

constrain7 = input(3,:) <= tol; %floor
constrain8 = input(3,:) >= hexParams.h-tol ; %ceiling

%% 
arena2dPos(1,constrain1) = -input(1,constrain1) -hexParams.rho - wallFlip;
arena2dPos(2,constrain1) = input(3,constrain1);

arena2dPos(1,constrain2) = sqrt(sum([input(1,constrain2)-hexVertices.floor(1,3);...
    input(2,constrain2) - hexVertices.floor(2,3)].^2,1)) - hexParams.rho/2 - wallFlip;
arena2dPos(2,constrain2) = input(3,constrain2);

arena2dPos(1,constrain3) = sqrt(sum([input(1,constrain3)-hexVertices.floor(1,4);...
    input(2,constrain3) - hexVertices.floor(2,4)].^2,1)) + hexParams.rho/2 - wallFlip;
arena2dPos(2,constrain3) = input(3,constrain3);

arena2dPos(1,constrain4) = input(1,constrain4) + 2*hexParams.rho - wallFlip;
arena2dPos(2,constrain4) = input(3,constrain4);

arena2dPos(1,constrain5) = sqrt(sum([input(1,constrain5)-hexVertices.floor(1,6);...
    input(2,constrain5) - hexVertices.floor(2,6)].^2,1)) + 2.5*hexParams.rho - wallFlip;
arena2dPos(2,constrain5) = input(3,constrain5);

arena2dPos(1,constrain6) = sqrt(sum([input(1,constrain6)-hexVertices.floor(1,1);...
    input(2,constrain6) - hexVertices.floor(2,1)].^2,1)) + 3.5*hexParams.rho - wallFlip;
arena2dPos(2,constrain6) = input(3,constrain6);

arena2dPos(1,constrain7) = input(1,constrain7);
arena2dPos(2,constrain7) = input(2,constrain7) + hexParams.h + hexParams.rho*sqrt(3)./2 + 100;

arena2dPos(1,constrain8) = input(1,constrain8)+3*hexParams.rho;
arena2dPos(2,constrain8) = input(2,constrain8) + hexParams.h + hexParams.rho*sqrt(3)./2 +100;

end
