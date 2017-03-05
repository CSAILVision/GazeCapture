% loadSubject.m
%
% This loads subject data into a struct given a path to a subject
% directory. This requires the MATLAB gason wrapper to read JSON files. You
% can get it from https://github.com/pdollar/coco/tree/master/MatlabAPI.

function output = loadSubject(path)

% Apple Face Detections
input = gason(fileread(fullfile(path, 'appleFace.json')));
output.appleFace.x = input.X;
output.appleFace.x(~input.IsValid) = NaN;
output.appleFace.y = input.Y;
output.appleFace.y(~input.IsValid) = NaN;
output.appleFace.w = input.W;
output.appleFace.w(~input.IsValid) = NaN;
output.appleFace.h = input.H;
output.appleFace.h(~input.IsValid) = NaN;

% Apple Left Eye Detections
input = gason(fileread(fullfile(path, 'appleLeftEye.json')));
output.appleLeftEye.x = input.X;
output.appleLeftEye.x(~input.IsValid) = NaN;
output.appleLeftEye.y = input.Y;
output.appleLeftEye.y(~input.IsValid) = NaN;
output.appleLeftEye.w = input.W;
output.appleLeftEye.w(~input.IsValid) = NaN;
output.appleLeftEye.h = input.H;
output.appleLeftEye.h(~input.IsValid) = NaN;

% Apple Right Eye Detections
input = gason(fileread(fullfile(path, 'appleRightEye.json')));
output.appleRightEye.x = input.X;
output.appleRightEye.x(~input.IsValid) = NaN;
output.appleRightEye.y = input.Y;
output.appleRightEye.y(~input.IsValid) = NaN;
output.appleRightEye.w = input.W;
output.appleRightEye.w(~input.IsValid) = NaN;
output.appleRightEye.h = input.H;
output.appleRightEye.h(~input.IsValid) = NaN;

% Dot Information
input = gason(fileread(fullfile(path, 'dotInfo.json')));
output.dot.num = input.DotNum;
output.dot.xPts = input.XPts;
output.dot.yPts = input.YPts;
output.dot.xCam = input.XCam;
output.dot.yCam = input.YCam;
output.dot.time = input.Time;

% Face Grid
input = gason(fileread(fullfile(path, 'faceGrid.json')));
output.faceGrid.x = input.X;
output.faceGrid.x(~input.IsValid) = NaN;
output.faceGrid.y = input.Y;
output.faceGrid.y(~input.IsValid) = NaN;
output.faceGrid.w = input.W;
output.faceGrid.w(~input.IsValid) = NaN;
output.faceGrid.h = input.H;
output.faceGrid.h(~input.IsValid) = NaN;

% Frames
input = gason(fileread(fullfile(path, 'frames.json')));
output.frames = input;

% Info
input = gason(fileread(fullfile(path, 'info.json')));
output.info.totalFrames = input.TotalFrames;
output.info.numFaceDetections = input.NumFaceDetections;
output.info.numEyeDetections = input.NumEyeDetections;
output.info.dataset = input.Dataset;
output.info.deviceName = input.DeviceName;

% Motion data omitted. Add it if you need it!

% Screen
input = gason(fileread(fullfile(path, 'screen.json')));
output.screen.w = input.W;
output.screen.h = input.H;
output.screen.orientation = input.Orientation;

end

