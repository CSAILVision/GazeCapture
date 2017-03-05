% screen2cam.m
%
% Convert screen coordinates (in points, or centimeters if useCm is true)
% to physical coordinates (in centimeters) from the camera (our prediction
% space). The device data is pulled from apple_device_data.csv via
% loadAppleDeviceData.m. cam2screen.m is the inverse.
%
% Input Parameters
% ================
% With the exception of useCm (which is a logical scalar), all input
% vectors should be the same size, with an element for each sample to be
% processed.
% - xScreen/yScreen: Screen coordinates from the top-left corner of the
%     screen. Positive x is down and positive y is right. Units are
%     determined by useCm.
% - orientation: The orientation of the device as an integer (1-4). See the
%     README for more information.
% - device: Cell array of strings describing the device name.
% - screenW/screenH: Size of the active screen area. This allows us to
%     account for Display Zoom. This assumes the active screen area covers
%     the entire screen (which is the case in GazeCapture).
% - useCm: Whether to interpret xScreen/yScreen as points or centimeters.
%     Default: points.
%
% Output Parameters
% =================
% - xCam/yCam: xScreen/yScreen transformed to our prediciton space,
%     measured in centimeters from the center of the camera on the device,
%     dependent on the orientation of the device.
function [xCam, yCam] = screen2cam(xScreen, yScreen, orientation, ...
    device, screenW, screenH, useCm)

if nargin < 7
  useCm = false;
end

loadAppleDeviceData;

processed = false(size(xScreen));
xCam = NaN(size(xScreen));
yCam = NaN(size(yScreen));

% Process device by device.
for i = 1:length(deviceName)
  curr = strcmpi(device, deviceName(i));
  xCurr = xScreen(curr);
  yCurr = yScreen(curr);
  oCurr = orientation(curr);
  o1 = oCurr == 1;
  o2 = oCurr == 2;
  o3 = oCurr == 3;
  o4 = oCurr == 4;
  if ~useCm
    screenWCurr = screenW(curr);
    screenHCurr = screenH(curr);
  end
  dX = deviceCameraToScreenXMm(i);
  dY = deviceCameraToScreenYMm(i);
  dW = deviceScreenWidthMm(i);
  dH = deviceScreenHeightMm(i);

  if ~useCm
    xCurr(o1 | o2) = xCurr(o1 | o2) .* (dW ./ screenWCurr(o1 | o2));
    yCurr(o1 | o2) = yCurr(o1 | o2) .* (dH ./ screenHCurr(o1 | o2));
    xCurr(o3 | o4) = xCurr(o3 | o4) .* (dH ./ screenWCurr(o3 | o4));
    yCurr(o3 | o4) = yCurr(o3 | o4) .* (dW ./ screenHCurr(o3 | o4));
  else
    % Convert cm to mm.
    xCurr(o1 | o2) = xCurr(o1 | o2) .* 10;
    yCurr(o1 | o2) = yCurr(o1 | o2) .* 10;
    xCurr(o3 | o4) = xCurr(o3 | o4) .* 10;
    yCurr(o3 | o4) = yCurr(o3 | o4) .* 10;
  end

  % Transform to camera space, depending on the orientation.
  xCurr(o1) = xCurr(o1) - dX;
  yCurr(o1) = -dY - yCurr(o1);
  xCurr(o2) = dX - dW + xCurr(o2);
  yCurr(o2) = dY + dH - yCurr(o2);
  xCurr(o3) = dY + xCurr(o3);
  yCurr(o3) = dW - dX - yCurr(o3);
  xCurr(o4) = -dY - dH + xCurr(o4);
  yCurr(o4) = dX - yCurr(o4);

  % Store the results.
  xCam(curr) = xCurr;
  yCam(curr) = yCurr;

  processed = processed | curr;
end

if ~all(processed)
  warning(['The following devices were not recognized. Expect NaN ' ...
           'return values.']);
  disp(unique(device(~processed)));
end

% Finally, convert mm to cm.
xCam = xCam / 10;
yCam = yCam / 10;

end
