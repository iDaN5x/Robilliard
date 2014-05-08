function [obj1] = openSerialBus()

% ============================= About =================================
% This function opens the serial bus port (COM1), to allow serial
% comunication between Matlab and other devices.
% The function conifgures the connection to the baud-rate of 115200,
% and then returns the serial connection object, ready to be used.
%
% =====================================================================

obj1 = instrfind('Type', 'serial', 'Port', 'COM1', 'Tag', '');

if isempty(obj1)
    obj1 = serial('COM1');
else
    fclose(obj1);
    obj1 = obj1(1);
end

fopen(obj1);
set(obj1, 'BaudRate', 115200);

end