function imgOut = removeSmall(imgIn, minSize)
%% REMOVESMALL Removes small objects from binary image
% 
%   BW2 = removeSmall(BW, N) is BW2 = bwareaopen(BW, N)
% 

imgOut = bwareaopen(imgIn, minSize);

end