function imgSep = fibatLocal(imgDiff, imgThresh, C, tree_id)
%% FIBATLOCAL Applies FIBAT at the local level of an image
% 
%   BW2 = fibatLocal(IMG, BW, C, STR) recursively applies FIBAT, using 
%   parameters C, to each ROI in the binary image BW and to each of the 
%   resulting ROIs in order to separate overlapping ROIs. STR is used to
%   display separation progress
% 

imgSep = zeros(size(imgThresh));

[imgLabel, num] = bwlabel(imgThresh);

for i=1:num
    % Display separation progress
    if isempty(tree_id)
        current_tree_id = [num2str(i),'(',num2str(num),')'];
    else
        current_tree_id = [tree_id,'->',num2str(i),'(',num2str(num),')'];
    end
    fprintf(['\t',current_tree_id,'\n']);
    
    % Get an individual ROI
    imgMaskBW = (imgLabel == i);
    imgMaskBW = dilate(imgMaskBW);
    
    % Crop
    roiStats = regionprops(imgMaskBW,'BoundingBox');
    rect = roiStats.BoundingBox;
    row_min = max(floor(rect(2)),1);
    row_max = min(floor(rect(2)+ceil(rect(4))), size(imgThresh,1));
    col_min = max(floor(rect(1)),1);
    col_max = min(floor(rect(1)+ceil(rect(3))), size(imgThresh,2));
    
    crop_imgDiff = imgDiff(row_min:row_max, col_min:col_max);
    crop_imgThresh = imgMaskBW(row_min:row_max, col_min:col_max);
    crop_imgMask = crop_imgThresh .* crop_imgDiff;
    
    % Perform FIBAT segmentation
    threshValFinal = fibat(crop_imgMask, C);

    crop_imgSep = applyThresh(crop_imgMask, threshValFinal);
    crop_imgSep = morphologicalOps(crop_imgSep);
    crop_imgSep = removeSmall(crop_imgSep, C.minSize);

    numSeparated = bwconncomp(crop_imgSep);
    imgSep(logical(imgMaskBW)) = 0;
    if numSeparated.NumObjects > 1
        % FIBAT separated the ROI so keep the output and continue recursively applying FIBAT
        imgSep(row_min:row_max, col_min:col_max) = imgSep(row_min:row_max, col_min:col_max) | fibatLocal(crop_imgDiff, crop_imgSep, C, current_tree_id);
    else
        % FIBAT could not separate the ROI so exit the recursive loop
        imgSep(row_min:row_max, col_min:col_max) = imgSep(row_min:row_max, col_min:col_max) | imgThresh(row_min:row_max, col_min:col_max);
    end
end




end