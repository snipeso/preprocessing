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

Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Source = fullfile(Paths_Preprocessed, 'Power', 'SET');
Source_Cuts = fullfile(Paths_Preprocessed, 'Power', 'Cuts');
Destination = fullfile(Paths_Preprocessed, 'Power', 'Clean');

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];

for Indx_F = 1:numel(Files) % loop through files in target folder
    
    % get filenames
    Filename_Source = Files{Indx_F};
     Filename_Cuts =  [extractBefore(Filename_Source, '.set'), '_Cuts.mat'];
     Filename_Destination = ['Clean_',Files{Indx_F}];
   
    % skip if file already exists
    if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
        disp(['***********', 'Already did ', Filename_Destination, '***********'])
        continue
    elseif ~exist(fullfile(Source_Cuts, Filename_Cuts), 'file')
        disp(fullfile(Source_Cuts, Filename_Cuts))
        continue
    end
    
    % load dataset
    EEG = pop_loadset('filepath', Source, 'filename', Filename_Source);
    
    % convert to double (weirdly super important for ICA)
    EEG.data = double(EEG.data);
    
    % remove data marked manually
    [EEG, TMPREJ] = cleanCuts(EEG, fullfile(Source_Cuts, Filename_Cuts));
    
    
    % remove bad segments
    if ~isempty(TMPREJ)
        EEG = eeg_eegrej(EEG, eegplot2event(TMPREJ, -1));
    end
    
   
    
    % save new dataset
    pop_saveset(EEG, 'filename', Filename_Destination, ...
        'filepath', Destination, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
    
    disp(['***********', 'Finished ', Filename_Destination, '***********'])
    clear cutData srate badchans TMPREJ
end