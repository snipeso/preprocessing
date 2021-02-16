% Script by Sophia Snipes, 28/01/21
% Interpolates EEG data after components have been removed. Only considers
% channels indicated.

% function that interpolates bad channels and bad little segments

close all
clc
clear


General_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DataType = 'Power';
Refresh = false;
ExcludeChannels = [...
    EEG_Channels.EMG, ...
    EEG_Channels.face, ...
    EEG_Channels.ears, ...
    EEG_Channels.neck];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% get final channels
load('StandardChanlocs128.mat', 'StandardChanlocs')
load('Cz.mat', 'CZ')
StandardChanlocs(ExcludeChannels) = [];
StandardChanlocs(end+1) = CZ;


% get files and paths
Source_EEG = fullfile(Paths_Preprocessed, 'ICA', ['Deblinked_', DataType]);
Source_Cuts = fullfile(Paths_Preprocessed, 'Cleaning', 'Cuts');
Destination = fullfile(Paths_Preprocessed, 'Interpolated', DataType);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source_EEG)));
Files(~contains(Files, '.set')) = [];

for Indx_F = 1:numel(Files) % loop through files in target folder
    
    % get filenames
    Filename_Source_EEG = Files{Indx_F};
    Filename_Cuts =  [extractBefore(Filename_Source_EEG,'_Deblinked.set'), '_Cleaning_Cuts.mat'];
    Filename_Destination = [extractBefore(Filename_Source_EEG,'_Deblinked.set'), '_Clean.set'];
    
    % skip filtering if file already exists
    if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
        disp(['***********', 'Already did ', Filename_Destination, '***********'])
        continue
    elseif ~exist(fullfile(Source_Cuts, Filename_Cuts), 'file')
        disp(['***********', 'No cuts for ', Filename_Destination, '***********'])
        continue
    end
    
    % load dataset
    EEG = pop_loadset('filepath', Source_EEG, 'filename', Filename_Source_EEG);
    
    % clean data segments
    [EEGnew, badchans] = interpolateSegments(EEG, fullfile(Source_Cuts, Filename_Cuts), ExcludeChannels);
    
    
    % interpolate bad channels
    RemoveChannels =  labels2indexes(unique([badchans(:); ExcludeChannels]), EEGnew.chanlocs);
    EEGnew = pop_select(EEGnew, 'nochannel', RemoveChannels); % NOTE: this also takes out the not EEG channels and interpolates them; this is fine, we ignore it, but you have to remove them because otherwise they contribute to the interpolation
    EEGnew = pop_interp(EEGnew, StandardChanlocs);
    
    
    
    pop_saveset(EEGnew,  'filename', Filename_Destination, ...
        'filepath', Destination, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
    
    
    clear badchans cutData filename filepath TMPREJ
    
end