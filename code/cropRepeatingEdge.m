% cropRepeatingEdge.m
%
% Discretely crop an image and allow for going beyond image boundaries by
% repeating edge pixels. Images beyond the corners (i.e., beyond both the
% width and the height of the image) will have the closest corner color.
% The crop rectangle should have the format: [x y w h]. If no content is
% visible, the frame will be black. Note: This could also be done with
% padarray but this interface is nice for our purposes.

function output = cropRepeatingEdge(image, rect)

cropX = rect(1);
cropY = rect(2);
cropW = rect(3);
cropH = rect(4);

output = uint8(zeros(cropH, cropW, size(image, 3)));

leftPadding = max(0, 1 - cropX);
topPadding = max(0, 1 - cropY);
rightPadding = max((cropX + cropW - 1) - size(image, 2), 0);
bottomPadding = max((cropY + cropH - 1) - size(image, 1), 0);

% Copy content.
contentOutPixelsY = 1 + topPadding : cropH - bottomPadding;
contentOutPixelsX = 1 + leftPadding : cropW - rightPadding;
contentInPixelsY = cropY + topPadding : cropY + cropH - 1 - bottomPadding;
contentInPixelsX = cropX + leftPadding : cropX + cropW - 1 - rightPadding;
output(contentOutPixelsY, contentOutPixelsX, :) ...
    = image(contentInPixelsY, contentInPixelsX, :);

% Checking for an error that occurred.
if numel(contentOutPixelsX) == 0
  warning('No out pixels in y direction.');
  output = NaN;
  return;
end
if numel(contentOutPixelsY) == 0
  warning('No out pixels in y direction.');
  output = NaN;
  return;
end

% Pad directly above and below image.
output(1:topPadding, contentOutPixelsX, :) = ...
    repmat(output(contentOutPixelsY(1), contentOutPixelsX, :), ...
    [topPadding, 1, 1]);
output(end + 1 - bottomPadding:end, contentOutPixelsX, :) = ...
    repmat(output(contentOutPixelsY(end), contentOutPixelsX, :), ...
    [bottomPadding, 1, 1]);

% Pad to the left and right.
output(:, 1:leftPadding, :) = ...
    repmat(output(:, contentOutPixelsX(1), :), [1, leftPadding, 1]);
output(:, end + 1 - rightPadding:end, :) = ...
    repmat(output(:, contentOutPixelsX(end), :), [1, rightPadding, 1]);

end

