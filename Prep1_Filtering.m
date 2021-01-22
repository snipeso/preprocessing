% Script by Sophia Snipes, 21/01/21
% Filters and downsamples raw data into multiple sets for later data
% cleaning.
%
clear
close all
clc

General_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% choose what to filter

Refresh = false; % if false, and destination file already exists, it will skip it
Destination_Formats = {'Power', 'Cleaning', 'ICA'}; % chooses which filtering to do

LineNoise = 50; % frequency of line noise. 50 for EU, 60 for US



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% parameters

Parameters = struct();

% Cleaning: data for quickly scanning data and selecting bad timepoints
Parameters(2).Format = 'Cleaning'; % reference name
Parameters(2).fs = 125; % new sampling rate
Parameters(2).lp = 40; % low pass filter
Parameters(2).hp = 0.5; % high pass filter
Parameters(2).hp_stopband = 0.25; % high pass filter

% Wake: starting data for properly cleaned wake data
Parameters(3).Format = 'Power'; % reference name
Parameters(3).fs = 500; % new sampling rate
Parameters(3).lp = 40; % low pass filter
Parameters(3).hp = 0.5; % high pass filter
Parameters(3).hp_stopband = 0.25; % high pass filter


% ICA: heavily filtered data for getting ICA components
Parameters(4).Format = 'ICA'; % reference name
Parameters(4).fs = 500; % new sampling rate
Parameters(4).lp = 100; % low pass filter
Parameters(4).hp = 2.5; % high pass filter
Parameters(4).hp_stopband = .5; % high pass filter


% ERP: minimally filtered data for measuring ERPs
Parameters(6).Format = 'ERP'; % reference name
Parameters(6).fs = 500; % new sampling rate
Parameters(6).lp = 40; % low pass filter
Parameters(6).hp = 0.1; % high pass filter
Parameters(6).hp_stopband = 0.05; % high pass filter



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create filtered sets

Source = fullfile(Paths_Preprocessed, 'Unfiltered');
Files = deblank(string(ls(Source)));


for Indx_DF = 1:numel(Destination_Formats)
    Format = Destination_Formats{Indx_DF};
    Destination = fullfile(Paths_Preprocessed, Format, 'SET');
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    % get parameters based on format
    Indx = strcmp({Parameters.Format}, Destination_Format);
    new_fs = Parameters(Indx).fs;
    lowpass = Parameters(Indx).lp;
    highpass = Parameters(Indx).hp;
    hp_stopband = Parameters(Indx).hp_stopband;
    P = Parameters(Indx); % saved in EEG structure later for record keeping
    
    
    parfor Indx_F = 1:numel(Files) % this is really much faster in parallel
        Filename = Files{Indx_F};
        Filename_New = [extractBefore(Filename, '.set'), '_', Format, '.set']; % indicate what was done to the new file
        
        % skip filtering if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_New), 'file')
            disp(['***********', 'Already did ', Filename_Core, '***********'])
            continue
        end
        
        % load data
        EEG = pop_loadset('filepath', Source, 'filename', Filename);
        
        
        %%%%%%%%%%%%%%%%%%%%
        %%% process the data
        
        % notch filter for line noise
        EEG = lineFilter(EEG, LineNoise, false);
        
        % low-pass filter
        EEG = pop_eegfiltnew(EEG, [], lowpass); % this is a form of antialiasing
        
        % resample
        EEG = pop_resample(EEG, new_fs);
        
        % high-pass filter
        % NOTE: this is after resampling, otherwise crazy slow.
        EEG = hpFilter(EEG, highpass, hp_stopband);
        
        EEG.preprocessing = P;
        EEG = eeg_checkset(EEG);
        
        % save EEG
        pop_saveset(EEG, 'filename', Filename_New, ...
            'filepath', Destination, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
    end
end
