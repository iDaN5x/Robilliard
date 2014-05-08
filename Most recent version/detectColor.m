function [binImage] = detectColor(conn, h,s,v, color)

% ============================= About =================================
% This function detects a specific provided color in an image
% (HSV formated), and returns a binary image that represent the
% presence of the color in the original image.
%
% The color HSV values are fetched from an MySQL server.
%
% The function arguments are:
% ^ conn (a database connection to the color database).
% ^ h,s,v (HSV values of the image to examine).
% ^ color (the color name as a string, starting with a non-capital
%   letter).
%
% =====================================================================

sql = sprintf('select h_min, min(s_min), min(v_min), h_max, max(s_max), max(v_max) from %s',...
    color);

data = cell2mat(fetch(conn, sql));
hsv_min = data(1:3);
hsv_max = data(4:6);

if (strcmp(color, 'red'))
    binImage = (h < hsv_max(1) | h > hsv_min(1)) & (s > hsv_min(2)) & ...
        (s < hsv_max(2)) & (v > hsv_min(3)) & (v < hsv_max(3));
    
elseif (strcmp(color, 'white'))
    binImage = (s < hsv_max(2)) & (v > hsv_min(3));
    
elseif (strcmp(color, 'black'))
    binImage = (v < hsv_max(3));
    
else % Any other color.
    binImage = (h > hsv_min(1)) & (h < hsv_max(1)) & (s > hsv_min(2)) & ...
         (v > hsv_min(3));
end
end