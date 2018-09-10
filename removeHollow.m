function [clean_mask, removed_mask] = removeHollow(img, mask)
%% REMOVEHOLLOW Removes thin objects.
% 
%   [BW2, BW3] = removeHollow(IMG, BW), where BW2 is IMG with thin 
%   objects removed. If the solidity (i.e. ratio of the area of the 
%   convex hull of an object to the area of that object) is greater than 
%   approximately the golden ratio, then it is removed. An object may 
%   also be removed if its centroid is not located inside the object. BW3
%   contains said objects
% 

    clean_mask = mask;
    removed_mask = zeros(size(mask));
    [imgLabel, numRois] = bwlabel(mask);

    for i=1:numRois
        imgMask = (imgLabel == i);
        
        % Remove ROI based on solidity
        imgMaskConv = bwconvhull(imgMask);
        solidity = sum(imgMaskConv(:)) / sum(imgMask(:));
        if solidity > 1.7
            clean_mask(imgMask) = false;
        end

        % Remove ROI if centroid not inside ROI
        roiStats = regionprops(imgMask,'Centroid');
        roi_centroid = round(roiStats.Centroid);
        if img(roi_centroid(2), roi_centroid(1)) == 0
            clean_mask(imgMask) = false;
            removed_mask(imgMask) = true;
        end
    end

end