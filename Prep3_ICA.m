% Script by Sophia Snipes, 26/01/21
% This does the independent component analysis, breaking down the data into
% components after removing bad channels and rereferencing to the average.
% The new dataset gets saved in the folder ICA/Components. 

clear
close all
clc

% TODO: interpolate segments before averaging?
General_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = true;
VeryBadChannels = [EEG_Channels.EMG, EEG_Channels.face]; % indicate here channels not to include for the average reference; like non-brain channels

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('Cz.mat', 'CZ')

Source = fullfile(Paths_Preprocessed, 'ICA', 'SET');
Source_Cuts = fullfile(Paths_Preprocessed, 'Cleaning', 'Cuts');
Destination = fullfile(Paths_Preprocessed, 'ICA', 'Components');

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];

for Indx_F = 1:numel(Files) % loop through files in target folder
    
    % get filenames
    Filename_Source = Files{Indx_F};
    Filename_Cuts =  [extractBefore(Filename_Source,'_ICA'), '_Cleaning_Cuts.mat'];
    Filename_Destination = [extractBefore(Filename_Source,'.set'), '_Components.set'];
    
    % skip if file already exists
    if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
        disp(['***********', 'Already did ', Filename_Destination, '***********'])
        continue
    elseif ~exist(fullfile(Source_Cuts, Filename_Cuts), 'file')
        warning(['***********', 'No cuts for ', Filename_Destination, '***********'])
        continue
    end
    
    % load dataset
    EEG = pop_loadset('filepath', Source, 'filename', Filename_Source);
    
    
    % load cuts
    load(fullfile(Source_Cuts, Filename_Cuts), 'badchans')
    if ~exist('badchans', 'var')
        badchans = [];
    end
    
    % remove bad channels
    badchans(badchans<1 | badchans>128) = [];
    EEG = pop_select(EEG, 'nochannel', unique([badchans, VeryBadChannels]));
    
            % add CZ
    EEG.data(end+1, :) = zeros(1, size(EEG.data, 2));
    EEG.chanlocs(end+1) = CZ;
    
    % rereference to average
    EEG = pop_reref(EEG, []);
    
    % run ICA (takes a while)
    EEG = pop_runica(EEG, 'runica');
    
    % save new dataset
    pop_saveset(EEG, 'filename', Filename_Destination, ...
        'filepath', Destination, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
    
    disp(['***********', 'Finished ', Filename_Destination, '***********'])
end