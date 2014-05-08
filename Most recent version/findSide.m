function [side, side_id] = findSide(check_point, upper_left_limit, buttom_right_limit)

%Direction -> anti-clockwise.

if (check_point.x < upper_left_limit.x)
    side = 'left';
    side_id = 1;
    
elseif (check_point.x > buttom_right_limit.x)
    side = 'right';
    side_id = 3;
    
elseif (check_point.y < upper_left_limit.y)
    side = 'up';
    side_id = 4;
    
elseif (check_point.y > buttom_right_limit.y)
    side = 'buttom';
    side_id = 2;
        
else
    side = 'in_frame';
    side_id = -1;
    
end    
end


%where he needs - where he is
%if - than +4

%up - left = 3  OK
%left - up = -3 + 4 = 1 OK
%right - up = -1 + 4 = 3 OK
%left - buttom = -1 + 4 = 3 OK
%left - right = -2 + 4 = 2 OK