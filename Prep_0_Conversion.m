% Script by Sophia Snipes, 21/01/21
% Converts BrainAmp data into EEGLAB SET files


% create destination folder
Paths.SET = fullfile(Paths.Preprocessed, 'Unfiltered');
if ~exist(Paths.SET, 'dir')
    mkdir(Paths.SET)
end


% get channel locations file for 128 channels
load(fullfile([cd, '\StandardChanlocs128.mat']), 'StandardChanlocs')

Files = deblank(string(ls(Paths.Raw))); % get list of filenames
Files(~contains(Files, '.vhdr')) = []; % only consider headers

for Indx_F = 1:numel(Files)
    
    VHDR = Files{Indx_F};
    Core = extractBefore(VHDR, '.');
    SET = [Core, '.set'];
    
    % load the data into EEGLAB structure
    EEG = pop_loadbv(Path, VHDR);
    
    % update EEG structure
    EEG.ref = 'CZ';
    EEG.chanlocs = StandardChanlocs;
    
    % save
    pop_saveset(EEG, 'filename', SET, ...
        'filepath', Paths.SET, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
    
end
