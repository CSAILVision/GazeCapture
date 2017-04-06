% loadAllSubjectsVectors.m
%
% This script loads subject data into same-sized vectors, with a row for
% each sample. Variables will be placed into your workspace and prefixed
% with "gc." This format is not particularly compact (compared to the
% struct format in loadAllSubjects.m) since many values will be repeated
% for a subject, but you may find this convenient, particularly for
% compatibility with some of the provided scripts. This requires the MATLAB
% gason wrapper to read JSON files. You can get it from
% https://github.com/pdollar/coco/tree/master/MatlabAPI.

%% Don't overwrite workspace variables.
if exist('baseDirectory', 'var') || exist('currSubject', 'var') || ...
        exist('input', 'var') || exist('subjectDir', 'var') || ...
        exist('subjectDirs', 'var')
    error(['A workspace variable in this script will overwrite ' ...
           'existing variables.']);
end

%% Configuration.
baseDirectory = '/path/to/data';

%% Initialize variables.

% Subject and frame number are sufficient to reconstruct filenames, which
% we avoid loading into memory.
gcSbjNum = [];
gcFrmNum = [];

% True if face and eyes were detected. Only true samples were used to train
% iTracker.
gcAppleValid = [];

% On-device face and eye detections (using Apple's detectors).
gcAppleFaceX = [];
gcAppleFaceY = [];
gcAppleFaceW = [];
gcAppleFaceH = [];
gcAppleLeftEyeX = [];
gcAppleLeftEyeY = [];
gcAppleLeftEyeW = [];
gcAppleLeftEyeH = [];
gcAppleRightEyeX = [];
gcAppleRightEyeY = [];
gcAppleRightEyeW = [];
gcAppleRightEyeH = [];

% Parameterized face grid as [X Y W H].
gcFaceGridParams = [];

% String describing the device type.
gcDeviceName = {};

% "Active screen area" in points.
gcScreenW = [];
gcScreenH = [];

gcDotNum = [];
gcDotXPts = [];
gcDotYPts = [];
gcDotXCam = [];
gcDotYCam = [];
gcDotStartTime = [];

% 1 = portrait; 2 = portrait upside down; 3 = landscape with home button on
% the right; 4 = landscape with home button on the left.
gcOrientation = [];

% Dataset.
gcTrain = [];
gcVal = [];
gcTest = [];

%% Load from JSON files.

if ~exist(baseDirectory, 'dir')
    error(['The specified base directory does not exist. Please edit ' ...
           'the script to specify the root of the numbered subject ' ...
           'directories.']);
end

subjectDirs = dir(baseDirectory);
for currSubject = subjectDirs'
    % Valid subject directories have five-digit numbers.
    if ~currSubject.isdir || length(currSubject.name) ~= 5 || ...
            ~all(isstrprop(currSubject.name, 'digit'))
        continue;
    end
    disp(['Processing subject ' currSubject.name '...'])
    subjectDir = fullfile(baseDirectory, currSubject.name);
    
    % Apple Face Detections
    input = gason(fileread(fullfile(subjectDir, 'appleFace.json')));
    input.X(~input.IsValid) = NaN;
    input.Y(~input.IsValid) = NaN;
    input.W(~input.IsValid) = NaN;
    input.H(~input.IsValid) = NaN;
    gcAppleFaceX = [gcAppleFaceX; input.X'];
    gcAppleFaceY = [gcAppleFaceY; input.Y'];
    gcAppleFaceW = [gcAppleFaceW; input.W'];
    gcAppleFaceH = [gcAppleFaceH; input.H'];

    % Apple Left Eye Detections
    input = gason(fileread(fullfile(subjectDir, 'appleLeftEye.json')));
    input.X(~input.IsValid) = NaN;
    input.Y(~input.IsValid) = NaN;
    input.W(~input.IsValid) = NaN;
    input.H(~input.IsValid) = NaN;
    gcAppleLeftEyeX = [gcAppleLeftEyeX; input.X'];
    gcAppleLeftEyeY = [gcAppleLeftEyeY; input.Y'];
    gcAppleLeftEyeW = [gcAppleLeftEyeW; input.W'];
    gcAppleLeftEyeH = [gcAppleLeftEyeH; input.H'];

    % Apple Right Eye Detections
    input = gason(fileread(fullfile(subjectDir, 'appleRightEye.json')));
    input.X(~input.IsValid) = NaN;
    input.Y(~input.IsValid) = NaN;
    input.W(~input.IsValid) = NaN;
    input.H(~input.IsValid) = NaN;
    gcAppleRightEyeX = [gcAppleRightEyeX; input.X'];
    gcAppleRightEyeY = [gcAppleRightEyeY; input.Y'];
    gcAppleRightEyeW = [gcAppleRightEyeW; input.W'];
    gcAppleRightEyeH = [gcAppleRightEyeH; input.H'];

    % Dot Information
    input = gason(fileread(fullfile(subjectDir, 'dotInfo.json')));
    gcDotNum = [gcDotNum; input.DotNum'];
    gcDotXPts = [gcDotXPts; input.XPts'];
    gcDotYPts = [gcDotYPts; input.YPts'];
    gcDotXCam = [gcDotXCam; input.XCam'];
    gcDotYCam = [gcDotYCam; input.YCam'];
    gcDotStartTime = [gcDotStartTime; input.Time'];

    % Face Grid
    input = gason(fileread(fullfile(subjectDir, 'faceGrid.json')));
    input.X(~input.IsValid) = NaN;
    input.Y(~input.IsValid) = NaN;
    input.W(~input.IsValid) = NaN;
    input.H(~input.IsValid) = NaN;
    gcFaceGridParams = [gcFaceGridParams; ...
        [input.X' input.Y' input.W' input.H']];

    % Frames
    input = gason(fileread(fullfile(subjectDir, 'frames.json')));
    gcFrmNum = [gcFrmNum; cellfun(@(x) str2num(x(1:5)), input)'];

    % Info
    input = gason(fileread(fullfile(subjectDir, 'info.json')));
    gcTrain = [gcTrain; repmat(strcmp(input.Dataset, 'train'), input.TotalFrames, 1)];
    gcVal = [gcVal; repmat(strcmp(input.Dataset, 'val'), input.TotalFrames, 1)];
    gcTest = [gcTest; repmat(strcmp(input.Dataset, 'test'), input.TotalFrames, 1)];

    gcDeviceName = [gcDeviceName; repmat({input.DeviceName}, input.TotalFrames, 1)];
    
    gcSbjNum = [gcSbjNum; repmat(str2double(currSubject.name), input.TotalFrames, 1)];

    % Motion data omitted. Add it if you need it!

    % Screen
    input = gason(fileread(fullfile(subjectDir, 'screen.json')));
    gcScreenW = [gcScreenW; input.W'];
    gcScreenH = [gcScreenH; input.H'];
    gcOrientation = [gcOrientation; input.Orientation'];

end

gcAppleValid = ~isnan(gcAppleFaceX) & ~isnan(gcAppleLeftEyeX);

clear baseDirectory currSubject input subjectDir subjectDirs
