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
Destination_Formats = {'Power'}; % chooses which filtering to do

LineNoise = 50; % frequency of line noise. 50 for EU, 60 for US

ShaveTime = [0 1]; % data to remove (start and stop in seconds)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Create filtered sets

Source = fullfile(Paths_Preprocessed, 'Unfiltered');
Files = deblank(string(ls(Source)));
Files(~contains(Files, '.set')) = [];

for Indx_DF = 1:numel(Destination_Formats)
    Format = Destination_Formats{Indx_DF};
    Destination = fullfile(Paths_Preprocessed, Format, 'SET');
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    % get parameters based on format
    new_fs = Parameters.(Format).fs;
    lowpass = Parameters.(Format).lp;
    highpass = Parameters.(Format).hp;
    hp_stopband = Parameters.(Format).hp_stopband;
    P = Parameters.(Format); % saved in EEG structure later for record keeping
    
    
    for Indx_F = 1:numel(Files) % this is really much faster in parallel
        Filename = Files{Indx_F};
        Filename_New = [extractBefore(Filename, '.set'), '_', Format, '.set']; % indicate what was done to the new file
        
        % skip filtering if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_New), 'file')
            disp(['***********', 'Already did ', Filename, '***********'])
            continue
        end
        
        % load data
        EEG = pop_loadset('filepath', Source, 'filename', Filename);
        
        
        %%%%%%%%%%%%%%%%%%%%
        %%% process the data
        
        % chop off the first 5 seconds
        EEG = pop_select(EEG, 'notime', ShaveTime);
        
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
