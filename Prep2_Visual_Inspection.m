% Script by Sophia Snipes 22/01/21
% This is a tool for visually inspecting data, determining which timepoints
% to remove, and which channels are bad. See documentation for suggestions
% and how to use.

clear
close all
clc

General_Parameters

Filename = []; % either provide a specific filename here, or leave [], so a random file will be selected
SuggestCuts = true; % if true, a rudimentary algorithm will try and identify noisy segments

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load data

Source = fullfile(Paths_Preprocessed, 'Power', 'SET');
Destination = fullfile(Paths_Preprocessed, 'Power', 'Cuts');

EEG = loadEEGtoCut(Source, Destination, Filename); % load file
m = matfile(EEG.CutFilepath,'Writable',true); % create cuts file, load it to current workspace

markData(EEG) % plot data


%% remove or restore a whole channel
%%% Use these to mark whole channels to be removed. If you made a mistake,
%%% you can run the same channel in restoreCh(). 
%%% These are run through the editor. To see the channels removed, save the
%%% EEG plot, then run MarkData(EEG) again.

% rmCh(EEG.CutFilepath, []) % remove channel or list of channels from data
% rsCh(EEG.CutFilepath, []) % restore removed channels


%% remove or restore a little piece of a channel
%%% If there's a little chunck of a channel that went haywire, but the
%%% rest of the channel is fine, you can mark a section to remove, by
%%% running rmSnip(), indicating in seconds the start time and end time
%%% of the channel you want to remove. If you run this, then open
%%% markData() it will highlight the section in red.

% remove channels entirely
% rmSnip(EEG, StartTime, EndTime, Channel) % remove a snippet of data
% rsSnip(EEG, StartTime, EndTime, Channel) % restore a snippet of data


