function imgOut = clearSegmented(imgIn, imgThresh)
%% CLEARSEGMENTED Clears previously segmented ROIs from the image
% 
%   IMG2 = clearSegmented(IMG, BW) where IMG is the time-collapsed image
%   I_{n-1} to be cleared, BW is a binary image containing ROIs segmented
%   in iteration n-1 of ACSAT, and IMG2 has ROIs set to pixel intensity 
%   values of zero in IMG
% 

imgOut = imgIn;
imgOut(logical(imgThresh)) = 0;

end