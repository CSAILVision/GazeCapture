% faceGridFromFaceRect.m
%
% Given face detection data, generate face grid data.
%
% Input Parameters:
% - frameW/H: The frame in which the detections exist
% - gridW/H: The size of the grid (typically same aspect ratio as the
%     frame, but much smaller)
% - labelFaceX/Y/W/H: The face detection (x and y are 0-based image
%     coordinates)
% - parameterized: Whether to actually output the grid or just the
%     [x y w h] of the 1s square within the gridW x gridH grid.

function labelFaceGrid = faceGridFromFaceRect(frameW, frameH, gridW, ...
    gridH, labelFaceX, labelFaceY, labelFaceW, labelFaceH, parameterized)

scaleX = gridW / frameW;
scaleY = gridH / frameH;
numSamples = length(labelFaceW);
if parameterized
  labelFaceGrid = zeros(numSamples, 4);
else
  labelFaceGrid = zeros(numSamples, gridW * gridH);
end

for i=1:numSamples
  grid = zeros(gridH, gridW);
  
  % Use one-based image coordinates.
  xLo = round(labelFaceX(i) * scaleX) + 1;
  yLo = round(labelFaceY(i) * scaleY) + 1;
  w = round(labelFaceW(i) * scaleX);
  h = round(labelFaceH(i) * scaleY);

  if parameterized
    labelFaceGrid(i, :) = [xLo yLo w h];
  else
    xHi = xLo + w - 1;
    yHi = yLo + h - 1;

    % Clamp the values in the range.
    xLo = min(gridW, max(1, xLo));
    xHi = min(gridW, max(1, xHi));
    yLo = min(gridH, max(1, yLo));
    yHi = min(gridH, max(1, yHi));

    grid(yLo:yHi, xLo:xHi) = ones(yHi - yLo + 1, xHi - xLo + 1);

    % Flatten the grid.
    grid = grid';
    grid = grid(:)';
    labelFaceGrid(i, :) = grid;
  end
end

end
