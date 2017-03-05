% loadAllSubjects.m
%
% Loads all subject metadata into memory given the base path.

function subjects = loadAllSubjects(base_data_path)

subjects = [];

subjectDirs = dir(base_data_path);
for subjectDir = subjectDirs'
    if ~subjectDir.isdir || subjectDir.name(1) == '.'
        continue;
    end
    s = loadSubject(fullfile(base_data_path,subjectDir.name));
    subjects = [subjects; s];
end

end

