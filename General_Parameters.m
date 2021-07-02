
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Establish locations
Paths_Preprocessed = 'C:\Users\schlaf\Desktop\TempData\Preprocessed';
Paths_Raw = 'C:\Users\schlaf\Desktop\TempData\Raw';
Filetype = '.eeg'; % either .raw for EGI, or .eeg for BrainAmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add subfolders to path
addpath(fullfile(cd, 'functions'))
addpath(fullfile(cd, 'brogden'))

% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end


%%% parameters
Parameters = struct();

% Power: starting data for properly cleaned wake data
Parameters.Power.fs = 250; % new sampling rate
Parameters.Power.lp = 40; % low pass filter
Parameters.Power.hp = 0.5; % high pass filter
Parameters.Power.hp_stopband = 0.25; % high pass filter gradual roll-off

