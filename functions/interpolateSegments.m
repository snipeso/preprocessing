function [EEGnew, badchans] = interpolateSegments(EEG, Cuts_Filepath, ExcludeChannels, PlotData)
% Function by Sophia Snipes, 28/01/21


EEGnew = EEG;


ChanLabels = {EEG.chanlocs.labels};

%%% load cuts
m = matfile(Cuts_Filepath,'Writable',false);
Content = whos(m);

% create badchans variable
if ~ismember('badchans', {Content.name})
    badchans = [];
else
    badchans = m.badchans;
end


%%% interpolate bad segments

% get clusters of data to interpolate (overlapping segments)
if ismember('cutData', {Content.name}) % check if there are cuts
    
    Segments = nandata2windows(m.cutData);
    Segments(:, 2:3) = Segments(:, 2:3)/m.srate; % convert into seconds. TODO: make fix if srate not provided
    
    Segments(ismember(Segments(:, 1), ExcludeChannels), :) = []; % ignore segments that don't have neighbors needed for interp
    Clusters = segments2clusters(Segments); % group segments into clusters based on temporal overlap
    
    for Indx_C = 1:size(Clusters, 2)
        
        % select the column of data of the current cluster
        Start = round(EEGnew.srate*Clusters(Indx_C).Start);
        End = round(EEGnew.srate*Clusters(Indx_C).End);
        
        EEGmini =  pop_select(EEG, 'point', [Start, End]);
        
        if  isempty(EEGmini.data)
            continue
        end
        
        % select channels that won't be used for interpolation
        RemoveChannels = string(unique([badchans, Clusters(Indx_C).Channels, ExcludeChannels]));
        [Overlap, RemoveChannelsIndx] = intersect(ChanLabels, RemoveChannels);
        
        EEGmini = pop_select(EEGmini, 'nochannel', RemoveChannelsIndx);
        
        
        % interpolate bad segments TODO: maybe use 128 chanlocs?
        EEGmini = pop_interp(EEGmini, EEG.chanlocs);
        
        % replace interpolated data into new data structure
        % Note: channel selection is all over the place because it's
        % assumed that the cuts data is the whole 128 set, whereas the EEG
        % set can have however many electrodes it wants
        
        for Indx_Ch = 1:numel(Overlap)
            
            % don't insert segments in all channels that were not orignally
            % segmented
            if ismember(double(Overlap(Indx_Ch)), [badchans, ExcludeChannels])
                continue
            end
            Ch = RemoveChannelsIndx(Indx_Ch); %TODO: check if correct channels are selected

            EEGnew.data(Ch, Start:End) = EEGmini.data(Ch, :);
            
        end
    end
end

% provide new indexes of manually marked bad channels
RemoveChannels = string(unique(badchans));
[~, badchans] = intersect(ChanLabels, RemoveChannels);
badchans = unique(badchans); % this is a bit redundant, because all the bad channels were removed before the ICA

if ~isempty(badchans)
    A =1;
end

if exist('PlotData', 'var') && PlotData
     eegplot(EEG.data, 'srate', EEG.srate, 'winlength', 30, 'data2', EEGnew.data)
     disp(['Starts:'])
    disp({Clusters.Start})
end


