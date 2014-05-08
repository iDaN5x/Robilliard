function [h,s,v] = getHSV(rgb_image)
% ========================================================
% This function converts the imported image from RGB
% format to HSV format, and then seperates the HSV
% values and returns them.
% ========================================================

hsv_image = rgb2hsv(rgb_image);
h = hsv_image(:,:,1);
s = hsv_image(:,:,2);
v = hsv_image(:,:,3);

end