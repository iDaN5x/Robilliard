function [new_image] = isMoving(source_capture, MAX_CHANGE_PERCENT)
FILTER = 50;
STATIC_SEQ_COUNT = 15;

text = sprintf('\nWaiting for a static image sequence...');
disp(text);

trigger(source_capture);
old_image = getdata(source_capture);
pix_in_image = size(old_image,1) * size(old_image,2);

count = 0;
while(count < STATIC_SEQ_COUNT)
    trigger(source_capture);
    new_image = getdata(source_capture);
    
	diff_image = (new_image - old_image) + (old_image - new_image); %imabsdiff.
	
	R = diff_image(:,:,1);
	G = diff_image(:,:,1);
	B = diff_image(:,:,1);
	
	binImage = (R > FILTER) | (G > FILTER) | (B > FILTER);
	
	change_percent = sum(sum(binImage)) / pix_in_image;
    if(change_percent < MAX_CHANGE_PERCENT)
		count = count + 1;
	else
		count = 0;
    end
	
	old_image = new_image;  
end

disp('The image sequence is now static.');
end