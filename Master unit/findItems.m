function [items_pos, Radius] = findItems (conn, h,s,v, color, radius)

% ============================= About =================================
% This function finds defined items (by arguments) in an image (HSV
% formated), and returns an array containing the position of the item
% (in a pos struct format), and the exact radius of the item(s).
%
% The function arguments are:
% ^ conn (a database connection to the color database).
% ^ h,s,v (HSV values of the image to search in).
% ^ color (the color of the item to be found as a string starting
%   with a non-capital letter).
% ^ raduis (the estimated radius of the object).
%
% This function is taking a usage of the function detectColor.
%
% =====================================================================

temp = pi * radius^2;
max_area_of_objects = round(temp);
binImage = detectColor(conn, h,s,v, color);

binImage = bwareaopen(binImage, max_area_of_objects);
temp = regionprops(binImage, 'centroid');

for i=1:size(temp, 1)
    items_pos(i).x = temp(i).Centroid(1);
    items_pos(i).y = temp(i).Centroid(2);    
end

[~,temp] = max(max(binImage,[],2));
Radius = items_pos(1).y - temp;

end