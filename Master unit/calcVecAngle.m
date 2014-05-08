function [angle] = calcVecAngle (vec1, vec2)
% ============================= About =================================
% This function calculates either the angle between two vectors,
% or the angle of a single vector, dependes on the number of argument
% given.
% =====================================================================

if (nargin==1)
    angle=atand(vec1(2)/vec1(1));
    
elseif (nargin==2)
    cosA = (dot(vec1,vec2)) / ((calcDistance(vec1)) * (calcDistance(vec2)));
    angle = acosd(cosA);
    
else
    error('ERROR: too many input arguments in function findVecAngle');
    
end
end