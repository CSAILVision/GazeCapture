% cam2screen.m
%
% Convert physcial coordinates (in centimeters) from the camera (i.e., in
% our prediction space) to screen coordinates (in points, or centimeters
% depending on the useCm argument). useCm defaults to false, but in
% practice, we typically set it to true. See screen2cam.m for more
% information; this function behaves similarly.
function [xScreen, yScreen] = cam2screen(xCam, yCam, orientation, ...
    device, screenW, screenH, useCm)

if nargin < 7
  useCm = false;
end

loadAppleDeviceData;

processed = false(size(xCam));
xScreen = NaN(size(xCam));
yScreen = NaN(size(yCam));

% First, convert input to millimeters to be compatible with
% apple_device_data.csv.
xCam = xCam * 10;
yCam = yCam * 10;

% Process device by device.
for i = 1:length(deviceName)
  curr = strcmpi(device, deviceName(i));
  xCurr = xCam(curr);
  yCurr = yCam(curr);
  oCurr = orientation(curr);
  o1 = oCurr == 1;
  o2 = oCurr == 2;
  o3 = oCurr == 3;
  o4 = oCurr == 4;
  if ~useCm
    screenWCurr = screenW(curr);
    screenHCurr = screenH(curr);
  end

  % Transform so that measurements are relative to the device's origin
  % (depending on its orientation).
  dX = deviceCameraToScreenXMm(i);
  dY = deviceCameraToScreenYMm(i);
  dW = deviceScreenWidthMm(i);
  dH = deviceScreenHeightMm(i);
  xCurr(o1) = xCurr(o1) + dX;
  yCurr(o1) =  -yCurr(o1) - dY;
  xCurr(o2) = xCurr(o2) - dX + dW;
  yCurr(o2) = -yCurr(o2) + dY + dH;
  xCurr(o3) = xCurr(o3) - dY;
  yCurr(o3) = -yCurr(o3) - dX + dW;
  xCurr(o4) = xCurr(o4) + dY + dH;
  yCurr(o4) = -yCurr(o4) + dX;

  if ~useCm
    % Convert from mm to screen points.
    xCurr(o1 | o2) = xCurr(o1 | o2) .* (screenWCurr(o1 | o2) ./ dW);
    yCurr(o1 | o2) = yCurr(o1 | o2) .* (screenHCurr(o1 | o2) ./ dH);
    xCurr(o3 | o4) = xCurr(o3 | o4) .* (screenWCurr(o3 | o4) ./ dH);
    yCurr(o3 | o4) = yCurr(o3 | o4) .* (screenHCurr(o3 | o4) ./ dW);
  end

  % Store the results.
  xScreen(curr) = xCurr;
  yScreen(curr) = yCurr;

  processed = processed | curr;
end

if ~all(processed)
  warning(['The following devices were not recognized. Expect NaN ' ...
           'return values.']);
  disp(unique(device(~processed)));
end

if useCm
  % Convert from mm to centimeters.
  xScreen = xScreen / 10;
  yScreen = yScreen / 10;
end

end
