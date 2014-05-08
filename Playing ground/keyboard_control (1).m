%Made by Barak. copyrights.

% <================================>
% <=== Remote control for robot ===>
% <================================>

function keyboard_control()
%close all
clear all
clc

global COM1;
COM1 = openSerialBus();

s=figure('keypressfcn',@kpfcn, 'keyreleasefcn',@krfcn);
imshow('instru.png');
set(s, 'CloseRequestFcn',@closefcn);

end

function kpfcn(~,E)
global COM1;

switch E.Key
    case 'uparrow'
        controlRobot(COM1, 'forward', 2);
    case 'downarrow'
        controlRobot(COM1, 'backward', 2);
    case 'leftarrow'
        controlRobot(COM1, 'left', 2);
    case 'rightarrow'
        controlRobot(COM1, 'right', 2);
    case 'delete'
        controlRobot(COM1, 'rotate_left', 2);
    case 'pagedown'
        controlRobot(COM1, 'rotate_right', 2);
        
    case 'w'
        controlRobot(COM1, 'forward', 1);
    case 's'
        controlRobot(COM1, 'backward', 1);
    case 'a'
        controlRobot(COM1, 'left', 1);
    case 'd'
        controlRobot(COM1, 'right', 1);
    case 'q'
        controlRobot(COM1, 'rotate_left', 1);
    case 'e'
        controlRobot(COM1, 'rotate_right', 1);
        
    case 'numpad8'
        controlRobot(COM1, 'forward', 3);
    case 'numpad2'
        controlRobot(COM1, 'forward', 3);
    case 'numpad4'
        controlRobot(COM1, 'forward', 3);
    case 'numpad6'
        controlRobot(COM1, 'forward', 3);
    case 'numpad7'
        controlRobot(COM1, 'forward', 3);
    case 'numpad9'
        controlRobot(COM1, 'forward', 3);     
    case 'escape'
        closefcn();
    otherwise

end
end

function krfcn(~,~)
global COM1;
controlRobot(COM1, 'stop', 0);
end

function closefcn(~,~)
global COM1;

selection = questdlg('Quit the Program?',...
    'Quit...',...
    'Yes','No','Yes');
switch selection,
    case 'Yes',
        delete(gcf)
        fwrite(COM1, 0, 'uint8');
        fclose(COM1);
        
    case 'No'
        return
end
end
