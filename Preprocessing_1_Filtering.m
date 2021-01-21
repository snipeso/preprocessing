clear
close all
clc

General_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = false; % if false, and destination file already exists, it will skip it

Destination_Formats = {'Power', 'Cleaning', 'ICA'}; % chooses which filtering to do

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% parameters

% light filtering
% new_fs = 125; % maybe 250?
% low_pass = 40;
% high_pass = 0.5;
% hp_stopband = 0.25;
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


% % ERP: minimally filtered data for measuring ERPs
% Parameters(6).Format = 'ERP'; % reference name
% Parameters(6).fs = 500; % new sampling rate
% Parameters(6).lp = 40; % low pass filter
% Parameters(6).hp = 0.1; % high pass filter
% Parameters(6).hp_stopband = 0.05; % high pass filter



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create filtered sets


Files = deblank(string(ls(fullfile(Paths.Preprocessed, 'Unfiltered'))));


for Indx_DF = 1:numel(Destination_Formats)
    Format = Destination_Formats{Indx_DF};


    parfor Indx_F = 1:numel(Files) % this is really much faster in parallel
        

    end

end
