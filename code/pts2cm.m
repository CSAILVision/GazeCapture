% pts2cm.m
%
% Convert screen coordinates in points to screen coordinates in
% centimeters. See the documentation in screen2cam.m for more information;
% this function behaves similarly.
function [xCm, yCm] = pts2cm(xPts, yPts, orientation, device, screenW, ...
    screenH)

loadAppleDeviceData;

processed = false(size(xPts));
xCm = NaN(size(xPts));
yCm = NaN(size(yPts));

% Process device by device.
for i = 1:length(deviceName)
  curr = strcmpi(device, deviceName(i));
  xCurr = xPts(curr);
  yCurr = yPts(curr);
  oCurr = orientation(curr);
  o1 = oCurr == 1;
  o2 = oCurr == 2;
  o3 = oCurr == 3;
  o4 = oCurr == 4;
  screenWCurr = screenW(curr);
  screenHCurr = screenH(curr);

  xCurr(o1 | o2) = ...
      xCurr(o1 | o2) .* (deviceScreenWidthMm(i) ./ screenWCurr(o1 | o2));
  yCurr(o1 | o2) = ...
      yCurr(o1 | o2) .* (deviceScreenHeightMm(i) ./ screenHCurr(o1 | o2));
  xCurr(o3 | o4) = ...
      xCurr(o3 | o4) .* (deviceScreenHeightMm(i) ./ screenWCurr(o3 | o4));
  yCurr(o3 | o4) = ...
      yCurr(o3 | o4) .* (deviceScreenWidthMm(i) ./ screenHCurr(o3 | o4));

  % Store the results.
  xCm(curr) = xCurr;
  yCm(curr) = yCurr;

  processed = processed | curr;
end

if ~all(processed)
  warning(['The following devices were not recognized. Expect NaN ' ...
           'return values.']);
  disp(unique(device(~processed)));
end

% Finally, convert mm to cm.
xCm = xCm / 10;
yCm = yCm / 10;

end
