% generateCrops.m
% This script generates all of the image crops required to train iTracker.
% It will create three subdirectories in each subject directory:
% "appleFace," "appleLeftEye," and "appleRightEye."

baseDirectory = '/path/to/data';
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
    s = loadSubject(subjectDir);
    appleFaceDir = fullfile(subjectDir, 'appleFace');
    appleLeftEyeDir = fullfile(subjectDir, 'appleLeftEye');
    appleRightEyeDir = fullfile(subjectDir, 'appleRightEye');
    mkdir(appleFaceDir);
    mkdir(appleLeftEyeDir);
    mkdir(appleRightEyeDir);
    
    for i = 1:length(s.frames)
        frameFilename = s.frames{i};
        frame = imread(fullfile(subjectDir, 'frames', frameFilename));
        % iTracker requires we have face and eye detections; we don't save
        % any if we don't have all three.
        if isnan(s.appleFace.x(i)) || isnan(s.appleLeftEye.x(i)) || isnan(s.appleRightEye.x(i))
            continue;
        end
        faceImage = cropRepeatingEdge(frame, round([s.appleFace.x(i) s.appleFace.y(i) s.appleFace.w(i) s.appleFace.h(i)]));
        leftEyeImage = cropRepeatingEdge(faceImage, round([s.appleLeftEye.x(i) s.appleLeftEye.y(i) s.appleLeftEye.w(i) s.appleLeftEye.h(i)]));
        rightEyeImage = cropRepeatingEdge(faceImage, round([s.appleRightEye.x(i) s.appleRightEye.y(i) s.appleRightEye.w(i) s.appleRightEye.h(i)]));
        imwrite(faceImage, fullfile(appleFaceDir, frameFilename));
        imwrite(leftEyeImage, fullfile(appleLeftEyeDir, frameFilename));
        imwrite(rightEyeImage, fullfile(appleRightEyeDir, frameFilename));
    end
end