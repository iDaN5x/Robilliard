function [distance] = calcDistance (item1, item2, mode)

% ============================= About =================================
% This function calculates and returns the distance between two items.
%
% The function has 4 available modes:
% ^ vector_abs (calculate the absolute value of a vector).
%   In this case the variable *item1* will contain a vector.
%
% ^ point_to_point (calculate the distance between 2 points).
%   In this case the items' variables will contain 2 pos structs.
%
% ^ point_to_line (calculate the distance between a point to a line).
%   In this case the variable *item2* will contain the (a,b,c) 
%   values of a line.
%
% ^ line_to_line (calculates the distance between two parallel lines).
%   In this case both the first and the second items, contain the 
%   (a,b,c) values of the two lines.
%
% The mode the function will run dependes on the variable *mode*
% provided, or on the number of arguments provided to the function.
%
% =====================================================================

% Calculate the absolute value of a vector.
if (nargin==1 || strcmp(mode, 'vector_abs'))
    distance = sqrt(item1(1)^2 + item1(2)^2);

% Calculate the distance of two points from each other.
elseif (nargin==2 || strcmp(mode, 'point_to_point'))
    distance = sqrt((item1.x-item2.x)^2 + (item1.y-item2.y)^2);
    
% Calculate the shortest distance of a point from a line.
elseif (nargin==3 && strcmp(mode, 'point_to_line'))
    a=item2(1); b=item2(2); c=item2(3); clear('item2');
    distance = abs(a*item1.x + b*item1.y + c) / sqrt(a^2 + b^2);
    
% Calculate the shortest distance between two parallel lines.
elseif (nargin==3 && strcmp(mode, 'line_to_line'))
    a1=item1(1); b1=1item1(2); c1=item1(3); clear('item1');
    a2=item2(1); b2=item2(2); c2=item2(3); clear('item2');
    
    distance = abs(c2-c1) / sqrt(a1^2 + b1^2);

% Un-legitimate mode, or un-legitimate argument combination.
else
    error('ERROR: not an allowed mode of calcDistance.');
    
end
end
