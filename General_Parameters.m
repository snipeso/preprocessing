
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Establish locations
Paths_Preprocessed = 'C:\Users\colas\Desktop\TestPrep\Preprocessed';
Paths_Raw = '';
Filetype = '.raw'; % either .raw for EGI, or .eeg for BrainAmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add subfolders to path
addpath(fullfile(cd, 'functions'))
addpath(fullfile(cd, 'brogden'))

% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end

%%% EEG channels for 128 EGI net
EEG_Channels = struct();

EEG_Channels.mastoids = [49, 56];
EEG_Channels.EMG = [107, 113];
EEG_Channels.face = [126, 127];
EEG_Channels.ears  = [43, 44 48, 114, 119, 120];
EEG_Channels.neck = [63, 68, 73, 81, 88, 94, 99];

EEG_Channels.exclude = [...
    EEG_Channels.EMG, ...
    EEG_Channels.face, ...
    EEG_Channels.ears, ...
    EEG_Channels.neck];

%%% parameters
Parameters = struct();

% Cleaning: data for quickly scanning data and selecting bad timepoints
Parameters.Cleaning.fs = 125; % new sampling rate
Parameters.Cleaning.lp = 40; % low pass filter
Parameters.Cleaning.hp = 0.5; % high pass filter
Parameters.Cleaning.hp_stopband = 0.25; % high pass filter gradual roll-off to this freuqency

% Power: starting data for properly cleaned wake data
Parameters.Power.fs = 250; % new sampling rate
Parameters.Power.lp = 40; % low pass filter
Parameters.Power.hp = 0.5; % high pass filter
Parameters.Power.hp_stopband = 0.25; % high pass filter gradual roll-off

% ICA: heavily filtered data for getting ICA components
Parameters.ICA.fs = 500; % new sampling rate
Parameters.ICA.lp = 100; % low pass filter
Parameters.ICA.hp = 2.5; % high pass filter
Parameters.ICA.hp_stopband = 1.5; % high pass filter gradual roll-off

% Scoring: has special script for running this
Parameters.Scoring.fs = 128;
Parameters.Scoring.SpChannel = 6;
Parameters.Scoring.lp = 40; % low pass filter
Parameters.Scoring.hp = .5; % high pass filter
Parameters.Scoring.hp_stopband = .2; % high pass filter gradual roll-off

% ERP: starting data for properly cleaned ERPs
Parameters.ERP.fs = 250; % new sampling rate
Parameters.ERP.lp = 40; % low pass filter
Parameters.ERP.hp = 0.1; % high pass filter
Parameters.ERP.hp_stopband = 0.05; % high pass filter gradual roll-off
