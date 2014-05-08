function cleanCameraConnection()
temp = imaqfind();
stop(temp(size(temp,2)));

end