%% ACSAT Automated Cell Segmentation by Adaptive Thresholding
% 
%   Inputs:  - "data" which is the image sequence to be segmented
%            - free parameters which can be set below
%   Outputs: - "all_roi" which contains the segmented ROIs
%            - "iteration" which contains intermediates during each
%               iteration of ACSAT
% 

%% Free parameters
delta = 0.1; %termination condition for ACSAT
fibatGlobalParam.minSize = 50; %A_min for global FIBAT
fibatGlobalParam.maxSize = 300; %A_max for global FIBAT
fibatGlobalParam.numTestVals = 12; %number of test threshold values for FIBAT
fibatGlobalParam.alpha = 0.9; %termination condition for FIBAT
fibatGlobalParam.epsilon = 1e-3; %termination condition for FIBAT automatically calculated in pre-processing
fibatLocalParam.minSize = 20; %A_min for local FIBAT
fibatLocalParam.maxSize = inf; %A_max for local FIBAT
fibatLocalParam.numTestVals = 12; %number of test threshold values for FIBAT
fibatLocalParam.alpha = 0.9; %termination condition for FIBAT
fibatLocalParam.epsilon = 1e-3; %termination condition for FIBAT automatically calculated in pre-processing

%% Pre-Processing
tic;
% Generate time-collapsed image
disp('Generating time-collapsed image');
imgDiff = getImageDiff(data); %time-collapsed image I_0
current_imgDiff = imgDiff;

% Find smallest difference between pixel value and its neighbors
diffMat = zeros([size(imgDiff) + 2 8]);
diffMat(:,:,1) = abs(conv2(imgDiff, [1 0 0; 0 -1 0; 0 0 0]));
diffMat(:,:,2) = abs(conv2(imgDiff, [0 1 0; 0 -1 0; 0 0 0]));
diffMat(:,:,3) = abs(conv2(imgDiff, [0 0 1; 0 -1 0; 0 0 0]));
diffMat(:,:,4) = abs(conv2(imgDiff, [0 0 0; 1 -1 0; 0 0 0]));
diffMat(:,:,5) = abs(conv2(imgDiff, [0 0 0; 0 -1 1; 0 0 0]));
diffMat(:,:,6) = abs(conv2(imgDiff, [0 0 0; 0 -1 0; 1 0 0]));
diffMat(:,:,7) = abs(conv2(imgDiff, [0 0 0; 0 -1 0; 0 1 0]));
diffMat(:,:,8) = abs(conv2(imgDiff, [0 0 0; 0 -1 0; 0 0 1]));
diffMat = min(diffMat, [], 3);
diffMat(end,:) = [];
diffMat(:,end) = [];
diffMat(1,:) = [];
diffMat(:,1) = [];
diffMat = diffMat(:);
fibatGlobalParam.epsilon = min(diffMat(diffMat > 0));
fibatLocalParam.epsilon = fibatGlobalParam.epsilon;

%% Iterative Thresholding
clear iteration;
iteration_idx = 0; %iteration number n = 1, 2, ...
while iteration_idx <= 1 || abs(iteration(iteration_idx).val - iteration(iteration_idx - 1).val) / iteration(1).val >= delta
    iteration_idx = iteration_idx + 1;
    iteration(iteration_idx).timeStart = toc;
    fprintf(['Iteration ', num2str(iteration_idx), '\n']);
    
    %% ROI Removal
    if iteration_idx > 1
        % Remove ROIs already segmented
        temp_imgThresh = iteration(iteration_idx - 1).imgThresh;
        temp_imgThresh = dilate(temp_imgThresh);
        current_imgDiff = clearSegmented(iteration(iteration_idx - 1).image, temp_imgThresh);
        % Remove ROIs that were deemed not real in previous iteration
        temp_removed_mask = iteration(iteration_idx - 1).removed_mask;
        temp_removed_mask = dilate(temp_removed_mask);
        current_imgDiff = clearSegmented(current_imgDiff, temp_removed_mask);
    end
    iteration(iteration_idx).image = current_imgDiff;
    
    %% Global Thresholding
    fprintf('Global FIBAT....');
    
    [imgThresh, iteration(iteration_idx).val] = fibatGlobal(imgDiff, current_imgDiff, fibatGlobalParam);
    
    % Reporting
    fprintf([num2str(iteration(iteration_idx).val)]);
    iteration(iteration_idx).pre_imgThresh = imgThresh;
    if iteration_idx > 1
        terminationRatio = abs(iteration(iteration_idx).val - iteration(iteration_idx - 1).val) / iteration(1).val;
        fprintf(['....ratio: ', num2str(terminationRatio)]);
        if terminationRatio < delta
            fprintf('....end ACSAT\n');
            break;
        end
    end
    
    % Morphological operations
    imgThresh = removeSmall(imgThresh, fibatGlobalParam.minSize);
    imgThresh = removeHollow(current_imgDiff, imgThresh);
    imgThresh = morphologicalOps(imgThresh);

    %% Local Thresholding
    fprintf('\nLocal FIBAT\n');
    
    imgSep = fibatLocal(current_imgDiff, imgThresh, fibatLocalParam, [num2str(iteration_idx),' |']);
    
    % Reporting
    iteration(iteration_idx).imgSep = imgSep;

    % Morphological operations
    imgSep = removeSmall(imgSep, fibatGlobalParam.minSize);
    [imgSep, iteration(iteration_idx).removed_mask] = removeHollow(current_imgDiff, imgSep);
    imgSep = morphologicalOps(imgSep);

    %% Reporting
    % Report segmented binary image
    iteration(iteration_idx).imgThresh = imgSep;
    
    % Report pixel indicies of ROIs from binary image
    segmented_rois = bwconncomp(imgSep);
    iteration(iteration_idx).roi_count = segmented_rois.NumObjects;
    if iteration(iteration_idx).roi_count == 0
        fprintf('0 ROIs....end ACSAT\n');
        break;
    end
    [iteration(iteration_idx).roi(1:segmented_rois.NumObjects, 1).iteration] = deal(iteration_idx);
    [iteration(iteration_idx).roi(1:segmented_rois.NumObjects, 1).pixel_idx] = deal(segmented_rois.PixelIdxList{:});
    
    % Report iteration time
    iteration(iteration_idx).timeEnd = toc;
end

%% Final segmentation result
% Union of all ROIs from all iterations except the last
all_roi = cat(1, iteration(1:(iteration_idx - 1)).roi);
clear current_imgDiff diffMat iteration_idx temp_imgThresh temp_removed_mask imgThresh terminationRatio imgSep segmented_rois
