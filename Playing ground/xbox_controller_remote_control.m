function main()
JOYSTICK_ID = 1;
joy = vrjoystick(JOYSTICK_ID);

global obj1;
openSerialBus();

joy_caps = caps(joy);
disp(joy_caps);

while(1)
	LB = button(joy, 5);
    RB = button(joy, 6);
	analog.x = axis(joy, 1);
	analog.y = axis(joy, 2);
	
	if (RB == 1)
        do = 6; %Rotate right..
        
    elseif (LB == 1)
        do = 5; %Rotate left.
	
    
	elseif (abs(analog.y) > abs(analog.x))
		if (analog.y > 0)
			do = 1; %Drive forward.
			
		else
			do = 2; %Drive backward.
			
		end
		
	elseif (abs(analog.y) < abs(analog.x))
		if (analog.x > 0)
			do = 3; %Drive right.
			
		else
			do = 4; %Drive left.
			
		end
		
	else
		do = 0; %stop.
	
	end
   
    pause(0.01);
    fwrite(obj1, do, 'uint8');
    
end
end

function openSerialBus()
% ============================================================
% This function opens the serial bus port to allow serial
% comunication using RS-232. The function is also setting up
% the connection.
% ============================================================

global obj1;
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


