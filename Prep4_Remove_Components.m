% Script by Sophia Snipes 28/01/21
% Script for manually removing components of ICA. Basically run it, then it
% will show the top 35 component topoplots. Select the ones that contain
% the artifacts you want to remove, then click "ok". Then two eegplot
% scrolls will show up, the before and after of the EEG. After 5 seconds,
% the editor will ask if the current selection is good. If you answer 'y',
% then it will save the new eeg without the components. If you answer 'n',
% it will loop around and show the topographies again. If you answer 's',
% it will skip the current recording, and show the next one.

% If you indicate true for Automate, and false for Checkoutput, it will
% just take all the components selected, and apply them to the desired
% Data_Type. This is useful if you've removed components from Power, but
% now also want to do it for the ERP filtered data.

clear
eeglab
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = false;

Data_Type = 'Power';
Filename = [];
CheckOutput = true; % indicate true if you want to see what the data looks like once removed the components
Automate = false; % indicate false if you want to manually choose the components. Otherwise it will use what was previously selected

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

General_Parameters

load('Cz.mat', 'CZ')

% get files and paths
Source_Comps = fullfile(Paths_Preprocessed, 'ICA', 'Components');
Source_Data = fullfile(Paths_Preprocessed, Data_Type, 'SET');
Destination = fullfile(Paths_Preprocessed, 'ICA', ['Deblinked_',Data_Type]);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end


Files = deblank(cellstr(ls(Source_Comps)));
Files(~contains(Files, '.set')) = [];

% randomize files list
nFiles = numel(Files);
Files = Files(randperm(nFiles));

for Indx_F = 1:nFiles % loop through files in source folder
    
    if isempty(Filename) % choose a random filename
        % get filenames
        Filename_Comps = Files{Indx_F};
        Filename_Data = replace(Filename_Comps, 'ICA_Components', Data_Type);
        Filename_BadComps = [extractBefore(Filename_Comps,'.set'), '.mat'];
        Filename_Destination = [extractBefore(Filename_Data, Data_Type), 'Deblinked.set'];
        
        % skip if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['***********', 'Already did ', Filename_Destination, '***********'])
            continue
        end
    else % load requested file
        Filename_Comps = Filename;
        Filename_Data = replace(Filename_Comps, 'ICA_Components', Data_Type);
        Filename_BadComps = [extractBefore(Filename_Comps,'.set'), '.mat'];
        Filename_Destination = [extractBefore(Filename_Data, Data_Type), 'Deblinked.set'];
    end
    
    if ~exist(fullfile(Source_Data, Filename_Data), 'file')
        disp(['***********', 'No data for ', Filename_Destination, '***********'])
        continue
    elseif ~exist(fullfile(Source_Comps, Filename_Comps), 'file')
        disp(['***********', 'No badcomps for ', Filename_Destination, '***********'])
        continue
    end
    
    % load data
    Data = pop_loadset('filepath', Source_Data, 'filename', Filename_Data); % this is the EEG data you want to remove components from
    EEG = pop_loadset('filepath', Source_Comps, 'filename', Filename_Comps); % this is the EEG data where components were generated
    

    
    % remove channels from Data that aren't in EEG
    Data = pop_select(Data, 'channel', labels2indexes({EEG.chanlocs.labels}, Data.chanlocs));
    
           % add CZ
    Data.data(end+1, :) = zeros(1, size(Data.data, 2));
    Data.chanlocs(end+1) = CZ;
    
    % rereference to average
    Data = pop_reref(Data, []);
    
    rmComp
    if Break % if person indicates 'y', the loop is exited
        break
    end
    
end
