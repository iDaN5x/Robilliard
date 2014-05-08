function TestColorFromDatabase(color)

conn = connectToDatabase();

source_capture = setupCamera(1);
start(source_capture);
pause(10);
while(1)
    trigger(source_capture);
    imgh = getdata(source_capture);
    imgh = rgb2hsv(imgh);
    
    h = imgh(:,:,1);
    s = imgh(:,:,2);
    v = imgh(:,:,3);
    
    bin = detectColor(conn, h,s,v, color);
    imshow(bin);
end

end