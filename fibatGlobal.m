function [imgThresh, val] = fibatGlobal(imgDiff, current_imgDiff, C)
%% FIBATGLOBAL Applies FIBAT at the global level of an image
% 
%   [BW, T] = fibalGlobal(IMG, IMG2, C), where IMG is the original
%   time-collapsed image I_0, IMG2 is the image I_n where previously
%   segmented ROIs have been cleared, and C contains free parameters.
% 

val = fibat(current_imgDiff, C);

imgThresh = applyThresh(imgDiff, val);

end