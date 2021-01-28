
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Establish locations
Paths_Preprocessed = 'C:\Users\colas\polybox\MDD\Raw Files\MDD_evening\test';
Paths_Raw = 'C:\Users\colas\polybox\MDD\Raw Files\MDD_evening\test';
Filetype = '.raw'; % either .raw for EGI, or .eeg for BrainAmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% add subfolders to path
addpath(fullfile(cd, 'functions'))
addpath(fullfile(cd, 'brogden'))