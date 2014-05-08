cam = setupCamera(2);

cam_props = getselectedsource(cam);
cam_props.Exposure = -11;

start(cam);

for i=1:100
    trigger(cam);
    frame = getdata(cam);
    
    
end

stop(cam);