function sample_sv(color)
conn = connectToDatabase();

NUM_OF_SAMPLES = 1000;

global source_capture;
setupCamera();
start(source_capture);

trigger(source_capture);
temp = getdata(source_capture);

I = imshow(temp);
[~,rect] = imcrop(I);

max_val = [0,0]; min_val = [Inf, Inf];
% max_val(1), min_val(1) -> s;
% max_val(2), min_val(2) -> h;


for i=1:NUM_OF_SAMPLES
    if (mod(i,50) == 0)
        disp(i)
    end
    trigger(source_capture);
    temp = getdata(source_capture);
    
    temp = imcrop(temp, rect);
    temp = rgb2hsv(temp);
    
    for j=2:3
        var = temp(:,:,j);
        
        mini = min(min(var));
        maxi = max(max(var));
                
        if (mini < min_val(j-1))
            min_val(j-1) = mini;
        end
        
        if (maxi > max_val(j-1))
            max_val(j-1) = maxi;
        end
    end    
end

sql = sprintf('INSERT INTO %s (s_min, v_min, s_max, v_max) VALUES (%f, %f, %f, %f);', color, min_val(1), min_val(2), max_val(1), max_val(2));
disp(sql);
try 
    exec(conn, sql);
catch
    error('ERROR: Couldn`t execute SQL query to MySQL server.');
    
end
end

function [conn] = connectToDatabase()
dbname = 'sql28217';
username = 'sql28217';
password = 'lS6*jZ5*';
driver = 'com.mysql.jdbc.Driver';
dburl = ['jdbc:mysql://sql2.freemysqlhosting.net:3306/' dbname];

javaclasspath('C:\Program Files\MySQL\Connector J 5.1.24\mysql-connector-java-5.1.24-bin.jar');

conn = database(dbname, username, password, driver, dburl);

end

function setupCamera()
global source_capture;

disp('Checking if the camera is ready:');

try
    a = imaqhwinfo('winvideo',1);
    text = sprintf('%s detected! trying to connect...', a.DeviceName);
    disp(text);
    
    try
        try
            source_capture = videoinput('winvideo',1, 'RGB24_1920x1080');
            
        catch
            % Cleaning previuos connection...
            temp = imaqfind;
            stop(temp(size(temp,2)));
            
            % trying again to connect...
            source_capture = videoinput('winvideo', 1, 'RGB24_1920x1080');
            
        end
        
        disp('Connection established successfully!');
        
        set(source_capture, 'FramesPerTrigger', 1);
        set(source_capture, 'TriggerRepeat', Inf);
        triggerconfig(source_capture, 'manual');
        
    catch
        disp('ERROR: The camera is being used by another program...');
        
    end
    
catch
    disp('ERROR: No connected camera was detected.');
end
end