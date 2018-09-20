function plotPerim(img, roi, color)
% Shows a figure of the raw image with the perimeters of segmented cells highlighted.
% plotPerim(img, roi)
% plotPerim(img, roi, color)

if nargin < 3
    color = [1 0 0];
end

figure;
imagesc(img);
axis image;
colormap(gray);
hold on;
for k = 1:length(roi)
    [y, x] = ind2sub(size(img), roi(k).pixel_idx);
    idx = boundary(x, y);
	plot(x(idx), y(idx), 'Color', color, 'LineWidth', 1.2);
end

end