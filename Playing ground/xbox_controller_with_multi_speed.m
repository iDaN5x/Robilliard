function main()
JOYSTICK_ID = 1;
joy = vrjoystick(JOYSTICK_ID);

while(1)
    % Getting the axis status in reqular axis format (-1 to 1).
    axis_obj.x = axis(joy,1);
    axis_obj.y = axis(joy,2);
    
    axis_obj = getFixedAxisObj(axis_obj);
    control_word = buildControlWord (axis_obj);
    
    disp(control_word);
    
    
end
end

function [fixed_obj] = getFixedAxisObj (old_obj)
% The purpuse of this function is to change the axis values
% from the range -+1 to -+7 (int8 type).

fixed_obj.x = round(7 * old_obj.x);
fixed_obj.y = round(7 * old_obj.y);
end

function [axis_bin_word] = buildControlWord (axis_obj)

    function [new_value] = shortAxisValue (old_value)
        % Moving the most significent bit from bit-8 to bit -4,
        % while saving the values as should.
        
        if (old_value < 0)
            new_value = abs(old_value) * 2;
        else
            new_value = old_value;
        end
    end

    value1 = shortAxisValue(axis_obj.x);
    value2 = shortAxisValue(axis_obj.y);
    
    axis_bin_word = value1 + (value2 * 2^3);
end



