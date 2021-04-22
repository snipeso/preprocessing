% Script by Sophia Snipes, 26/01/21
% This does the independent component analysis, breaking down the data into
% components after removing bad channels and rereferencing to the average.
% The new dataset gets saved in the folder ICA/Components.
% Inspired by https://sccn.ucsd.edu/wiki/Makoto's_preprocessing_pipeline

clear
close all
clc

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
    
    % convert to double (weirdly super important for ICA)
    EEG.data = double(EEG.data);
    
    % remove data marked manually
    [EEG, TMPREJ] = cleanCuts(EEG, fullfile(Source_Cuts, Filename_Cuts));
    
    % add CZ
    EEG.data(end+1, :) = zeros(1, size(EEG.data, 2));
    EEG.chanlocs(end+1) = CZ;
    EEG = eeg_checkset(EEG);
    
    % remove bad segments
    if ~isempty(TMPREJ)
        EEG = eeg_eegrej(EEG, eegplot2event(TMPREJ, -1));
    end
    
    % rereference to average
    EEG = pop_reref(EEG, []);
    
    % run ICA (takes a while)
    Rank = sum(eig(cov(double(EEG.data'))) > 1E-7);
    if Rank ~= size(EEG.data, 1)
        warning(['Applying PCA reduction for ', Filename_Source])
    end
    
    EEG = pop_runica(EEG, 'runica', 'pca', Rank);
    
    % save new dataset
    pop_saveset(EEG, 'filename', Filename_Destination, ...
        'filepath', Destination, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
    
    disp(['***********', 'Finished ', Filename_Destination, '***********'])
    clear cutData srate badchans TMPREJ
end