% Last update (by Idan on 20/05 at 13:17):
% @ Splited out general functions to seperate files.
% @ isMoving was updated to real-time.
%
% TODO:
% @ Add follow_white check func to buildStrategy (Idan has a scheme).
% @ Consider moving alignImage to a seperate file too.


function Robilliard(src_img)
%% Setup
% Connect to database:
conn = connectToDatabase();

disp('Robilliard is up and running:');
disp('-----------------------------');

% Constant (global) values
global MAX_DEGREE;
global BALLS_MASS;
global BALLS_RADIUS;
global SURFACE_FRICTION;
global source_capture;

SURFACE_FRICTION = 0.5;
MAX_DEGREE = 70;
BALLS_MASS = 14.5;

if (nargin ~= 0)
    frame = src_img;
    
else
    % Setuping the camera.
    source_capture = setupCamera(1);
    start(source_capture);
    disp('Waiting for camera setup...');
    pause(10);
    disp('go');
    %frame = isMoving(source_camera, 200);
    trigger(source_capture);
    frame = getdata(source_capture);
    
end
obj1 = openSerialBus();
% ================== Game loop will start here!!! ======================
%% Get Strategies
% Detecting the magenta colored stickers.
[hf,sf,vf] = getHSV(frame);
crop_cords = findItems (conn, hf,sf,vf, 'magenta', 2.5);
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
holes_pos = findItems (conn, h,s,v, 'black', 2.5);
if (size(holes_pos, 2) ~= 6)
    error('ERROR: the holes were not detected properly.');
end


% Finding the locaion of the white ball.
[white_ball_pos, BALLS_RADIUS] = findItems (conn, h,s,v, 'white', 2.5);
if (size(white_ball_pos, 2) ~= 1)
    error('ERROR: white ball was not detected properly.');
end


% Finding the location of the red balls
red_balls_pos = findItems (conn, h,s,v, 'red', 2.5);
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


% Drawing out the different strategies.
norm_handle = figure('Name', 'Normal Strategies');
imshow(table_image);

alt_handle = figure('Name', 'Alternative Strategies');
imshow(table_image);

drawStrategiesList(norm_list, norm_handle);
drawStrategiesList(alt_list, alt_handle);
%% Directing Robot
arm_length = calcArmLength(conn);

while(1)
    try
        temp = size(norm_list(1).plan,2)-1;
        temp = norm_list(1).plan(temp);
        
    catch
        error('ERROR: Strategy list is empty.');
    end
       
    hit_white_pos = calcHitPoint(white_ball_pos, temp, 2*BALLS_RADIUS);%The position where the stick needs to arrive.
    target_pos = calcHitPoint(hit_white_pos,temp, arm_length); %The position where the robot(himself) needs to arrive.
    
    hit_white_pos = normalizePos(hit_white_pos, crop_cords(1));
    target_pos = normalizePos(target_pos, crop_cords(1));
    
    % Enter robot code here!
%     [target_side, target_side_id] = findSide(target_pos, crop_cords(1), crop_cords(2));
%     if (strcmp(target_side, 'in_frame'))
%         norm_list(1) = [];
%         continue;
%     end
    
    break;
end

%[robot_side, robot_side_id] = findSide(robot_pos, crop_cords(1), crop_cords(2));

% num_sides = target_side_id - robot_side_id;
% if (num_sides < 0)
%     num_sides = num_sides + 4;
% end

vec_line = buildVector(target_pos, hit_white_pos);
target_line = buildLine(target_pos, hit_white_pos);
%connectToCom1;
directRobot(source_capture, conn, obj1, target_line, target_pos, vec_line); % Rafi.


% ================== Game loop will end here!!! ======================

% Closing the camera connection.
stop(source_capture);

end


function [fixed_pos] = normalizePos(original_pos, index)
fixed_pos.x = original_pos.x + index.x;
fixed_pos.y = original_pos.y + index.y;
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


function [arm_length] = calcArmLength(conn)

    function [object_pos] = func2(conn, h,s,v, color, radius)
        object_pos = findItems (conn, h,s,v, color, radius);
        if (size(object_pos, 2) ~= 1)
            error('ERROR: The robot was not detected proprely.');
        end
    end

global source_capture;

trigger(source_capture);
frame = getdata(source_capture);
[h,s,v] = getHSV(frame);

robot_pos = func2(conn,h,s,v, 'yellow', 2);
stick_pos = func2(conn,h,s,v, 'green', 2);

arm_length = calcDistance(robot_pos, stick_pos, 'point_to_point');

end