function imgOut = applyThresh(imgIn, thresh)
%% APPLYTHRESH Segments image by thresholding
% 
%   BW = applyThresh(IMG, T) segments image IMG using threshold value T to
%   produce binary image BW
% 

imgOut = (imgIn >= thresh);

end