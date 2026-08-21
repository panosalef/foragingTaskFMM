function outArg = getPlaneFromPoints(point1,point2,point3)
%GETPLANEFROMPOINTS  Plane [normal; d] through three points.

normal = cross(point1-point2,point1-point3);
d = dot(normal,point1);

outArg = [normal ; d];
end