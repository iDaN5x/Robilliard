function controlRobot(obj1, command, speed)

state = {{'stop'},...
    {'auto_pilot'},...
    {'forward', 'backward', 'right', 'left'},...
    {'rotate_right', 'rotate_left','stick_up', 'stick_down',...
            'stick_inc_angle', 'stick_dec_angle'}};
        
switch(command)
    case state{1}
        word = 0;
        index = 1;
    
    case state{2}
        word = 64;
        index = 2;
    
    case state{3}
        word = 128;
        index = 3;
        
    case state{4}
        word = 192;
        index = 4;
        
    otherwise
        error(sprintf('ERROR: %s is not a legal command.', command));     
end

[~,temp] = ismember(command,state{index});
word = word + temp + 16 * speed;

fwrite(obj1, word, 'uint8');

end


    
        