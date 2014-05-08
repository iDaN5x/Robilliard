function [new_image] = isMoving(source_capture, MAX_DIFF)

% ============================= About =================================
% This function waits for a static frame sequence in a video source
% (from the camera), and when this condition occurs, it returns the
% last frame captured (RGB formated).
%
% This function has two arguments:
% ^ source_capture (the camera's object, setuped).
% ^ MAX_DIFF (the max number of pixels allowed to be changed between
%   two frames).
%
% =====================================================================

text = sprintf('\nWaiting for a static image...');
disp(text);

trigger(source_capture);
old_image = getdata(source_capture);

while(1)
    trigger(source_capture);
    new_image = getdata(source_capture);
    
    diff_image=imabsdiff(old_image,new_image);
    
    R = diff_image(:,:,1);
    G = diff_image(:,:,2);
    B = diff_image(:,:,3);
    
    bin_image = (R>100 | G>100 | B>100);
    
    if (sum(sum(bin_image))<MAX_DIFF)
        break;
    end
    
    old_image = new_image;
    
end

disp('The image is now static.');

end