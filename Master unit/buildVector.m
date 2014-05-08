function [vec] = buildVector (start_point, end_pos)

% ============================= About =================================
% This function is given two points (pos structs) and builds a vector 
% between them.
% =====================================================================

vec(1) = end_pos.x - start_point.x;
vec(2) = end_pos.y - start_point.y;
end