% cm2pts.m
%
% Convert screen coordinates in centimeters to screen coordinates in
% points. See the documentation in screen2cam.m for more information; this
% function behaves similarly.
function [xPts, yPts] = cm2pts(xCm, yCm, orientation, device, screenW, ...
    screenH)

loadAppleDeviceData;

% First, convert mm to cm.
xCm = xCm * 10;
yCm = yCm * 10;

processed = false(size(xCm));
xPts = NaN(size(xCm));
yPts = NaN(size(yCm));

% Process device by device.
for i = 1:length(deviceName)
  curr = strcmpi(device, deviceName(i));
  xCurr = xCm(curr);
  yCurr = yCm(curr);
  oCurr = orientation(curr);
  o1 = oCurr == 1;
  o2 = oCurr == 2;
  o3 = oCurr == 3;
  o4 = oCurr == 4;
  screenWCurr = screenW(curr);
  screenHCurr = screenH(curr);

  % NOTE: This assumes the active screen area is the full screen. This is
  % always the case in GazeCapture. Using the active screen area allows us
  % to account for Display Zoom.
  xCurr(o1 | o2) = ...
      xCurr(o1 | o2) .* (screenWCurr(o1 | o2) ./ deviceScreenWidthMm(i));
  yCurr(o1 | o2) = ...
      yCurr(o1 | o2) .* (screenHCurr(o1 | o2)) ./ deviceScreenHeightMm(i);
  xCurr(o3 | o4) = ...
      xCurr(o3 | o4) .* (screenWCurr(o3 | o4)) ./ deviceScreenHeightMm(i);
  yCurr(o3 | o4) = ...
      yCurr(o3 | o4) .* (screenHCurr(o3 | o4)) ./ deviceScreenWidthMm(i);

  % Store the results.
  xPts(curr) = xCurr;
  yPts(curr) = yCurr;

  processed = processed | curr;
end

if ~all(processed)
  warning('The following devices were not recognized. Expect NaN return values.');
  disp(unique(device(~processed)));
end

end
