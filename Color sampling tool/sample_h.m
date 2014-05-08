function sample_h(color)
conn = connectToDatabase();

global source_capture;
NUM_OF_SAMPLES = 1000;

setupCamera();
start(source_capture);
trigger(source_capture);
temp = getdata(source_capture);

I = imshow(temp);
[~,rect] = imcrop(I);

h_max = 0; h_min = Inf;

for i=1:NUM_OF_SAMPLES
    if (mod(i,75) == 0)
        disp(i);
    end
    trigger(source_capture);
    temp = getdata(source_capture);
    temp = imcrop(temp, rect);
    
    temp = rgb2hsv(temp);
    h = temp(:,:,1);
        
    if (strcmp(color, 'red'))
        for i=1:size(h,1)
            for j=1:size(h,2)
                if (h(i,j) >= 0.5)
                    if (h(i,j) < h_min)
                        h_min = h(i,j);
                    end
                    
                else
                    if (h(i,j) > h_max)
                        h_max = h(i,j);
                    end
                end
            end
        end
        
    else
        mini = min(min(h));
        maxi = max(max(h));
                
        if (mini < h_min)
            h_min = mini;
        end
        
        if (maxi > h_max)
            h_max = maxi;
        end
    end
end

sql = sprintf('ALTER TABLE `%s` CHANGE COLUMN `h_min` `h_min` FLOAT NOT NULL DEFAULT %f, CHANGE COLUMN `h_max` `h_max` FLOAT NOT NULL DEFAULT %f;' , color, h_min, h_max);
disp(sql);
try 
    exec(conn, sql);
catch
    error('ERROR: Couldn`t execute SQL query to MySQL server.');
end

disp(h_min);
disp(h_max);

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