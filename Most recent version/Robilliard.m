function Robilliard(src_img)
%% Setup
% Connect to database:
server_conn = connectToDatabase();

disp('Robilliard is up and running:');
disp('-----------------------------');

% Constant (global) values
global MAX_DEGREE;
global BALLS_RADIUS;
global source_capture;
global server;
global COM1;

MAX_DEGREE = 70;

if (nargin ~= 0)
    frame = src_img;
    
else
    % Setuping the camera.
    source_capture = setupCamera(1);
    start(source_capture);
    
    disp('Prepering the camera...');
    pause(10);
    disp('Done prepering the camera.');
    
    frame = isMoving(source_camera, 15);
    
end

server = server_conn;

% ================== Game loop starts here!!! ======================

%% >> Building the game Strategies.

% Detecting the magenta colored stickers.
[hf,sf,vf] = getHSV(frame);
crop_cords = findItems (server, hf,sf,vf, 'magenta', 2.5);
if (size(crop_cords, 2) ~= 2)
    error('ERROR: couldn`t detect stickers properly.');
end


% Croping out the table out of the frame.
width = abs(crop_cords(2).x - crop_cords(1).x);
height = abs(crop_cords(2).y - crop_cords(1).y);
table_image = imcrop(frame, [crop_cords(1).x, crop_cords(1).y, width, ...
    height]);


% Recalculating the HSV values (of the table image).
[h,s,v] = getHSV(table_image);


% Finding the location of the holes.
holes_pos = findItems (server, h,s,v, 'black', 2.5);
if (size(holes_pos, 2) ~= 6)
    error('ERROR: the holes were not detected properly.');
end


% Finding the locaion of the white ball.
[white_ball_pos, BALLS_RADIUS] = findItems (server, h,s,v, 'white', 2.5);
if (size(white_ball_pos, 2) ~= 1)
    error('ERROR: white ball was not detected properly.');
end


% Finding the location of the red balls
red_balls_pos = findItems (server, h,s,v, 'red', 2.5);
num_of_red_balls = size(red_balls_pos, 2);


% Display the number of red balls in the console.
message = sprintf('There are %d red balls.', num_of_red_balls);
disp(message);


% Getting the lists of available strategies from the building func.
[norm_list, alt_list] = buildStrategiesLists (white_ball_pos,...
    red_balls_pos, holes_pos, num_of_red_balls);


% Sorting out the strategies lists by value.
norm_list = sortStrategyList(norm_list);
alt_list = sortStrategyList(alt_list);


%% >> Drawing out the different strategies.
norm_handle = figure('Name', 'Normal Strategies');
imshow(table_image);

alt_handle = figure('Name', 'Alternative Strategies');
imshow(table_image);

drawStrategiesList(norm_list, norm_handle);
drawStrategiesList(alt_list, alt_handle);

%% >> Directing Robot

%Calculate the arm's length.
[robot_pos, ~, arm_length] = getRobot(hf,sf,vf);

while(1)
    try
        temp = size(norm_list(1).plan,2)-1;
        white_target_pos = norm_list(1).plan(temp);
        
    catch
        error('ERROR: Strategy list is empty.');
    end
    
    hit_white_pos = calcHitPoint(white_ball_pos, white_target_pos, 2*BALLS_RADIUS);%The position where the stick needs to arrive.
    target_pos = calcHitPoint(hit_white_pos,white_target_pos, arm_length); %The position where the robot(himself) needs to arrive.
    
    hit_white_pos = normalizePos(hit_white_pos, crop_cords(1));
    target_pos = normalizePos(target_pos, crop_cords(1));
    
    [target_side, target_side_id] = findSide(target_pos, crop_cords(1), crop_cords(2));
    if (strcmp(target_side, 'in_frame'))
        norm_list(1) = [];
        continue;
    end
    
    break;
end

[~, robot_side_id] = findSide(robot_pos, crop_cords(1), crop_cords(2));

num_sides = target_side_id - robot_side_id;
if (num_sides < 0)
    num_sides = num_sides + 4;
end

% Opening the serial-bus port (RS-232).
COM1 = openSerialBus();

%Report to the robot how many sides he needs to go.
controlRobot(num_sides, 3);

waitForRobotReport();

vec_line = buildVector(target_pos, hit_white_pos);
target_line = buildLine(target_pos, hit_white_pos);

directRobot(target_line, target_pos, vec_line);

controlRobot('hit', 0);

% ================== Game loop will end here!!! ======================

% Closing the camera connection.
stop(source_capture);

end


function [fixed_pos] = normalizePos(original_pos, index)
fixed_pos.x = original_pos.x + index.x;
fixed_pos.y = original_pos.y + index.y;
end


function [hit_pos] = calcHitPoint (target_pos, dest_pos, distance)
% ====================================================================
% This function calculates where shuould a moving object hit a static
% object (aka target_pos), so it'll move to a selected destination
% (aka dest_pos).
% ====================================================================

t = distance/calcDistance(target_pos, dest_pos, 'point_to_point');
hit_pos.x = target_pos.x - t*(dest_pos.x - target_pos.x);
hit_pos.y = target_pos.y - t*(dest_pos.y - target_pos.y);
end


function [playable, profile] = planStrategy (source_pos, target_pos,...
    dest_pos, reds_pos, profile, i, prev_k)

global BALLS_RADIUS;

global MAX_DEGREE;
temp_max_degree = MAX_DEGREE - 20*i;

hit_pos = calcHitPoint (target_pos, dest_pos, 2*BALLS_RADIUS);
vec_source_hit = buildVector (source_pos, hit_pos);
vec_target_dest = buildVector (target_pos, dest_pos);

angle = calcVecAngle(vec_source_hit, vec_target_dest);
if (angle > temp_max_degree)
    playable = false;
    return;
end

% Check source_hit
if (temp_max_degree==MAX_DEGREE)
    [clear,k] = checkRoute (source_pos, target_pos, reds_pos, 3*BALLS_RADIUS);
    if (clear==false)
        playable = false;
        return;
    end
end

% Check target_dest
[clear,k] = checkRoute (target_pos, dest_pos, reds_pos, 3*BALLS_RADIUS);
if (clear == true)
    playable = true;
    last_step = size(profile.plan, 2);
    profile.plan(last_step+1) = hit_pos;
    return;
    
else
    [playable, profile] = planStrategy(source_pos, reds_pos(k),...
        dest_pos, reds_pos, profile, i+1, k);
    
    last_step = size(profile.plan,2);
    temp = profile.plan(last_step);
    
    if (temp_max_degree==MAX_DEGREE)
        hit_pos = calcHitPoint(target_pos, temp, 2*BALLS_RADIUS);
        
        vec_source_hit = buildVector (source_pos, hit_pos);
        vec_target_dest = buildVector (target_pos, dest_pos);
        angle = calcVecAngle(vec_source_hit, vec_target_dest);
        profile.angle = angle;
        
    else
        hit_pos = calcHitPoint(reds_pos(prev_k), temp, 2*BALLS_RADIUS);
    end
    
    profile.plan(last_step+1) = hit_pos;
    
end
end


function [clear, kMin] = checkRoute (source_pos, dest_pos,...
    block_pos_array, min_distance)

num_of_block = size(block_pos_array, 2);
clear = true;
dMin = Inf;
kMin = -1;

for k=1:num_of_block
    
    if (block_pos_array(k).x == dest_pos.x && block_pos_array(k).y == dest_pos.y)
        continue;
    end
    
    vec_source_block = buildVector(source_pos, block_pos_array(k));
    vec_source_target = buildVector(source_pos, dest_pos);
    angle = calcVecAngle(vec_source_block, vec_source_target);
    
    vec1_abs = calcDistance(vec_source_block);
    vec2_abs = calcDistance(vec_source_target);
    
    if ( angle<90 && vec2_abs>vec1_abs )
        h = abs(vec1_abs * sind(angle));
        if (h < min_distance)
            d = calcDistance(block_pos_array(k), source_pos, 'point_to_point');
            if (d < dMin)
                dMin = d;
                kMin = k;
            end
        end
    end
end

if (dMin ~= Inf)
    clear = false;
end
end


function [norm_list, alt_list] = buildStrategiesLists(white_pos,...
    reds_pos, holes_pos, number_red)

% ===================================================================
% This function builds the list of available playing strategies.
% First, the function defines the Strategy struct type.
% Then the functions call planStrategy func to every available
% red ball + hole combo, and save the returned strategy profile in
% an array, called strategies_list.
% After saving all the strategies, the function returns the list.
% ===================================================================

    function [list] = sub_func(list)
        last_place = size(list,2);
        list(last_place+1).plan = strategy_profile.plan;
        list(last_place+1).profit = strategy_profile.profit;
    end

norm_list = [];
alt_list = [];

for i = 1:number_red
    for j = 1:6
        
        empty_profile.plan(1) = holes_pos(j);
        empty_profile.profit = i*j;
        
        [playable, strategy_profile] = planStrategy(white_pos,...
            reds_pos(i), holes_pos(j), reds_pos,...
            empty_profile, 0, 1);
        
        if (playable == false)
            continue;
            
        else
            %need to change the arguments
            %             is_safe = checkIfAvoids(source_pos, avoid_pos, block_pos, vStart, min_dist);
            %             if(is_safe == false)
            %                 continue;
            %             end
            %
            last_profile = size(strategy_profile.plan,2);
            strategy_profile.plan(last_profile+1) = white_pos;
            if(size(strategy_profile.plan,2) == 3)
                norm_list = sub_func(norm_list);
            else
                alt_list = sub_func(alt_list);
            end
        end
    end
end
end


function drawPlan (strategy_plan, figure_handle, rgb_color)
% ===================================================================
% This function takes a strategy *plan* and draw this plan on a
% specific figure specified by its handle ID.
% ===================================================================
num_of_lines = size(strategy_plan,2);
point_a.x = strategy_plan(1).x;
point_a.y = strategy_plan(1).y;

num_of_lines = num_of_lines - 1;
figure(figure_handle);

hold on
for p=2:num_of_lines+1
    point_b.x = strategy_plan(p).x;
    point_b.y = strategy_plan(p).y;
    
    plot ([point_a.x, point_b.x], [point_a.y, point_b.y], 'Color',...
        rgb_color, 'LineWidth', 4, 'LineStyle', '--');
    
    point_a = point_b;
end
hold off

end


function drawStrategiesList(list, handle)
color = [0.1,0.9,0.9];
for j=1:size(list,2)
    color(1) = color(1) + (30/360);
    rgb_color = hsv2rgb(color);
    drawPlan(list(j).plan, handle, rgb_color);
    
end
end


function [sorted_list] = sortStrategyList(unsorted_list)
% ============================= About ===============================
% This function sorts out the strategy list by the profitability of
% each strategy in the list (smaller is better).
% ===================================================================

sorted_list = unsorted_list;

list_size = size(unsorted_list, 2);

for l=1:list_size
    min=Inf; minID=1;
    for m=1:list_size
        if (unsorted_list(m).profit < min)
            min = unsorted_list(m).profit;
            minID = m;
        end
    end
	
    sorted_list(l).plan = unsorted_list(minID).plan;
    sorted_list(l).profit = unsorted_list(minID).profit;
    unsorted_list(minID).profit = Inf;
        
end
end


function [new_img, angle] = alignImage(src_img, point_a, point_b)
% This function is only working by theory (Because of
% weird shape, and un-accurate center detection.

vec = buildVector(point_a, point_b);
alpha = 90-calcVecAngle(vec);

new_img = imrotate(src_img, alpha);
end


function [robot_pos, stick_pos, arm_length] = getRobotSpecs(h,s,v)

    function [object_pos] = func1(server, h,s,v, color, radius)
        object_pos = findItems (server, h,s,v, color, radius);
        if (size(object_pos, 2) ~= 1)
            error('ERROR: The robot was not detected proprely.');
        end
    end

global server;

robot_pos = func1(h,s,v, 'yellow', 2);
stick_pos = func1(h,s,v, 'green', 2);

arm_length = calcDistance(robot_pos, stick_pos, 'point_to_point');

end


function directRobot(target_line, target_pos, vec_line)

    function [h,s,v] = getHSVfromCapture()
        trigger(source_capture);
        frame = getdata(source_capture);
        [h,s,v] = getHSV(frame);
    end

    function [object_pos] = getObject(h,s,v, color, radius)
        object_pos = findItems (server, h,s,v, color, radius);
        if (size(object_pos, 2) ~= 1)
            error('ERROR: The robot was not detected proprely.');
        end
    end

    function stopAndWait()
        controlRobot(COM1,'stop',1);
        pause(0.5);
    end

global source_capture;
global server;
global COM1;

TILL_DISTANCE = 10;
dist_robot_line = Inf;
controlRobot(COM1,'forward',1);
while(dist_robot_line > TILL_DISTANCE)
    [h,s,v] = getHSVfromCapture();
    rob_pos = getObject(h,s,v, 'yellow', 2.55);
    
    dist_robot_line = calcDistance(rob_pos, target_line, 'point_to_line');
end

stopAndWait();

TILL_DEGREE = 10;
alpha = Inf;
controlRobot(COM1,'rotate_right',1);
while(alpha > TILL_DEGREE)
    [h,s,v] = getHSVfromCapture();
    robot_pos = getObject(h,s,v, 'yellow', 2.55);
    stick_pos = getObject(h,s,v, 'green', 2.55);
    
    vec_robot_stick = buildVector(robot_pos, stick_pos);
    alpha = calcVecAngle(vec_robot_stick, vec_line);
end

stopAndWait();

TILL_DISTANCE = 10;
dist_robot_target = Inf;
controlRobot(COM1,'forward',1);
while(dist_robot_target > TILL_DISTANCE)
    [h,s,v] = getHSVfromCapture();
    robot_pos = getObject(h,s,v, 'yellow', 2.55);
    dist_robot_target = calcDistance(robot_pos, target_pos, 'point_to_point');
end

stopAndWait();
disp('Robot in position.');

end


function controlRobot(command, speed)

global COM1;

state{1} = {'stop'}; % Overiding stop.
state{2} = {0,1,2,3}; % auto-pilot.
state{3} = {'forward', 'backward', 'right', 'left'}; % movement.
state{4} = {'rotate_right', 'rotate_left','stick_up', 'stick_down',...
           'stick_inc_angle', 'stick_dec_angle', 'hit'}; % strategy planner.
        
switch(command)
    case state{1}
        word = 0;
        index = 1;
    
    case state{2}
        word = 63;
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

fwrite(COM1, word, 'uint8');

end


function waitForRobotResponse()
disp('Waiting for robot response...');

response = 0;
while(response ~= 1)
   response = fread(COM1);
end

disp('The robot have reported.');

end