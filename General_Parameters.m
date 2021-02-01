
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Establish locations
Paths_Preprocessed = '';
Paths_Raw = '';
Filetype = '.raw'; % either .raw for EGI, or .eeg for BrainAmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% add subfolders to path
addpath(fullfile(cd, 'functions'))
addpath(fullfile(cd, 'brogden'))


%%% EEG channels for 128 EGI net
EEG_Channels = struct();

EEG_Channels.mastoids = [49, 56];
EEG_Channels.EMG = [107, 113];
EEG_Channels.face = [126, 127];
EEG_Channels.ears  = [43, 44 48, 114, 119, 120];
EEG_Channels.neck = [63, 68, 73, 81, 88, 94, 99];