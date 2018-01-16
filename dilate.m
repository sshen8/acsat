function imgOut = dilate(imgIn)
%% DILATE Dilates image using disk structuring element
% 
%   IMG2 = dilate(IMG) performs dilation using strel('disk', 1, 0)
% 

se = strel('disk', 1, 0);
imgOut = imdilate(imgIn,se);

end