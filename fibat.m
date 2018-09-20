function val = fibat(img, C)
%% FIBAT Fluorescence Intensity Based Adaptive Thresholding
% 
%   T = fibat(IMG, C) outputs the threshold value T that results in the
%   most segmented ROIs from IMG that satisfy the criteria C
% 

% Initialize search range to entire range of pixel intensity values
minVal = max([min(img(img > 0)) 0]);
maxVal = max(img(:));

while true
    % Select test threshold values
    testVals = linspace(minVal, maxVal, C.numTestVals);
    testResults = zeros(1, C.numTestVals);
    
    % Perform segmentation using each test value
    for testNum = 1:numel(testVals)
        threshVal = testVals(testNum);
        
        imgThresh = applyThresh(img, threshVal);
        % remove edge ROIs casusd by motion correction
        if C.maxSize ~= inf
            imgThresh = xor(bwareaopen(imgThresh, 0), bwareaopen(imgThresh, C.maxSize));
        end
        imgThresh = morphologicalOps(imgThresh);
        
        % Apply criteria
        if C.maxSize == inf
            imgThresh = bwareaopen(imgThresh, C.minSize);
        else
            imgThresh = xor(bwareaopen(imgThresh, C.minSize), bwareaopen(imgThresh, C.maxSize));
        end
        
        % Collect threshold result
        [~, testResults(testNum)] = bwlabel(imgThresh);
    end
    
    % Find max ROIs segmented
    testMax = max(testResults);
    
    % Find test values that result in max ROIs
    testMaxInd = find(testResults == testMax);
        
    % Find new search range to contain best test values so far
    testMaxIndMin = max([1, min(testMaxInd) - 1]);
    testMaxIndMax = min([C.numTestVals, max(testMaxInd) + 1]);
    minVal = testVals(testMaxIndMin);
    maxVal = testVals(testMaxIndMax);
    
    % Further refinement will result in the same range so end here
    if (testMaxIndMax - testMaxIndMin + 1) / C.numTestVals >= C.alpha
        minVal = testVals(testMaxIndMin + 1);
        maxVal = testVals(testMaxIndMin + 1);
        break;
    end
    
    % Further refinement will not be useful so end here
    if maxVal - minVal < C.epsilon
        break;
    end
    
end

% Report threshold value that produced the best result
val = mean([minVal, maxVal]);

end