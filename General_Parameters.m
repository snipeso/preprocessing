
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Establish locations
Paths_Preprocessed = '';
Paths_Raw = '';
Filetype = '.raw'; % either .raw for EGI, or .eeg for BrainAmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% add subfolders to path
addpath(fullfile(cd, 'functions'))
addpath(fullfile(cd, 'brogden'))