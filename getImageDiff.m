function imgDiff = getImageDiff(imgSeq)
%% GETIMAGEDIFF Returns 2-dimensional representation of an image sequence
% 
%   I = getImageDiff(M), where M is a 3-dimensional matrix containing a 
%   sequence of input images, and where the value of each pixel in I is
%   the difference between the maximum value and the mean value of that 
%   pixel in the image sequence
% 

imgMax = max(imgSeq, [], 3);
imgMax = double(imgMax);
imgMean = double(mean(imgSeq, 3));
imgDiff = imgMax - imgMean;
    
end