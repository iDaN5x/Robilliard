function cleanCameraConnection()
temp = imaqfind();

for i=1:size(temp,2)
    stop(temp(i));
end

end