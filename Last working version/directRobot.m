function directRobot(source_capture, conn, obj1, target_line, target_pos, vec_line)

    function [h,s,v] = func1()
        trigger(source_capture);
        frame = getdata(source_capture);
        [h,s,v] = getHSV(frame); 
    end

    function [object_pos] = func2(conn, h,s,v, color, radius)
       object_pos = findItems (conn, h,s,v, color, radius);
        if (size(object_pos, 2) ~= 1)
            error('ERROR: The robot was not detected proprely.');
        end
    end

    function [dist_robot_line] = func3(MAX_DISTANCE)
        dist_robot_line = Inf;
        while (dist_robot_line > MAX_DISTANCE)
            [ht,st,vt] = func1();
            rob_pos = func2(conn, ht,st,vt, 'yellow', 2.55);
            dist_robot_line = calcDistance(rob_pos, target_line, 'point_to_line');
        end
    end



controlRobot(obj1,'forward',1);
disp('forward');
dist_robot_line = func3(10);

controlRobot(obj1,'stop',1);
pause(0.5);

controlRobot(obj1,'rotate_right',1);
disp('rotate_right');
alpha = Inf;
while(alpha > 10)
    [h,s,v] = func1();
    robot_pos = func2(conn, h,s,v, 'yellow', 2.55);
    stick_pos = func2(conn, h,s,v, 'green', 2.55);
    
    vec_robot_stick = buildVector(robot_pos, stick_pos);
    alpha = calcVecAngle(vec_robot_stick, vec_line);
end


controlRobot(obj1,'stop',1);
pause(0.5);


controlRobot(obj1,'forward',1);
%controlRobot(obj1,'moveForwardSlowly',1);
disp('forward till pos');
dist_robot_target = Inf;
while(dist_robot_target > 10)
    [h,s,v] = func1();
    robot_pos = func2(conn, h,s,v, 'yellow', 2.55);
    dist_robot_target = calcDistance(robot_pos, target_pos, 'point_to_point');
end

controlRobot(obj1,'stop',1);
disp('arrived!');
end

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
