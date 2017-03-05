% faceGridFromParams.m
%
% Given face grid parameters (and optionally size, which is 25 for
% GazeCapture data), return the flattened face grid.

function labelFaceGrid = ...
    faceGridFromParams(labelFaceGridParams, gridW, gridH)

if nargin < 2
  gridW = 25;
  gridH = 25;
end

numSamples = size(labelFaceGridParams, 1);
labelFaceGrid = zeros(numSamples, gridW * gridH);
for i = 1:numSamples
  grid = zeros(gridH, gridW);

  xLo = labelFaceGridParams(i, 1);
  yLo = labelFaceGridParams(i, 2);
  w = labelFaceGridParams(i, 3);
  h = labelFaceGridParams(i, 4);

  xHi = xLo + w - 1;
  yHi = yLo + h - 1;

  % Clip the values to the range.
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
