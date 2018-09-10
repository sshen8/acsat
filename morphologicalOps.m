function imgOut = morphologicalOps(imgIn)
%% MORPHOLOGICALOPS Refines segmented image
% 
%   I = morphologicalOps(IMG), where I is the result of standard 
%   morphological operations i.e. filling up holes, breaking H-
%   connected sections, and removing spur pixels
% 

imgOut = imfill(imgIn, 'holes');
imgOut = bwmorph(imgOut, 'hbreak');
imgOut = bwmorph(imgOut, 'spur');

end

