function [source_capture] = setupCamera(CAMERA_ID)

% ============================= About =================================
% This function detects if a specified camera (by ID) is available
% to usage, and if so it connects to it and setups it to work in 
% real-time applications.
% 
% ^ First the funciton detects if the specified camera is connected
%   to the computer, and if so - it prints its name. 
% ^ Then the function checks if the camera is ready to be used, or
%   if it is already being used (by Matlab itself or another program).
% ^ If the camera is being used by Matlab, the function will close
%   the previous connection and then try to re-connect.
% ^ If the camera is being used by other program then the function
%   will print an error about it.
% ^ After a successful connection, the function prints a message and
%   configures the camera to work with real-time applications.
% ^ Atlast the function returns the camera object, ready to be used.
%
% =====================================================================

disp('Checking if the camera is ready:');

if (nargin == 0)
   CAMERA_ID = 1; 
end

try
    cam = imaqhwinfo('winvideo',CAMERA_ID);
    text = sprintf('%s detected! trying to connect...', cam.DeviceName);
    disp(text);
    
    try
        try
            source_capture = videoinput('winvideo', CAMERA_ID, 'RGB24_1920x1080');
            
        catch
            % Cleaning previous connection...
            temp = imaqfind;
            stop(temp(size(temp,2)));
            
            % Retrying to connect...
            source_capture = videoinput('winvideo', CAMERA_ID, 'RGB24_1920x1080');
        
        end
        
        disp('Connection established successfully!');
        
        set(source_capture, 'FramesPerTrigger', 1);
        set(source_capture, 'TriggerRepeat', Inf);
        triggerconfig(source_capture, 'manual');
        
    catch
        error('ERROR: The camera is being used by another program...');
        
    end
    
catch
    source_capture = {};
    error('ERROR: The camera is not connected.');
end
end