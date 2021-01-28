% Script by Sophia Snipes, 21/01/21
% Converts raw data into EEGLAB SET files

General_Parameters

% create destination folder
Paths_SET = fullfile(Paths_Preprocessed, 'Unfiltered');
if ~exist(Paths_SET, 'dir')
    mkdir(Paths_SET)
end

Files = deblank(string(ls(Paths_Raw))); % get list of filenames
Files(~contains(Files, Filetype)) = []; % only consider headers

for Indx_F = 1:numel(Files)
    
    [EEG, SET] = loadData(Files{Indx_F}, Paths_Raw);
    
    % save
    pop_saveset(EEG, 'filename', SET, ...
        'filepath', Paths_SET, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
end
