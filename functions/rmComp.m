% Script by Sophia Snipes, 28/01/21
% script that get looped for removing the selected components, plotting
% them, then saving them.


close all
clc

if ~Automate
    
    % plot components in the time domain
    Pix = get(0,'screensize');
    tmpdata = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
    eegplot( tmpdata, 'srate', EEG.srate,  'spacing', 10, 'dispchans', 35, ...
        'winlength', 20, 'position', [0 0 Pix(3) Pix(4)*.97], ...
        'limits', [EEG.xmin EEG.xmax]*1000);
    
    % open interface for selecting components
    pop_selectcomps(EEG, 1:35);
    
    disp('press enter to proceed')
    
    % wait, only proceed when prompted
    pause
    
end

% get bad components
badcomps = find(EEG.reject.gcompreject); % get indexes of selected components
clc
close all

if ~Automate
    
    % save dataset, now containing new components to remove
    pop_saveset(EEG, 'filename', Filename_Comps, ...
        'filepath', Source_Comps, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
end

% merge data with component structure
NewEEG = EEG;
NewEEG.data = Data.data;
NewEEG.pnts = Data.pnts;
NewEEG.srate = Data.srate;
NewEEG.xmax = Data.xmax;
NewEEG.times = Data.times;
NewEEG.event = Data.event;

% remove components
NewEEG = pop_subcomp(NewEEG, badcomps);

% low-pass filter
NewEEG = pop_eegfiltnew(NewEEG, [], Parameters.(Data_Type).lp); % for whatever reason, sometimes ICA removal introduces high frequency noise


if CheckOutput
    % % show
    Pix = get(0,'screensize');
    %     try % NOTE TO GIDI: if you liked the old visualization, just switch back to this
    %         eegplot(Data.data(:, 100*EEG.srate:300*EEG.srate), 'spacing', 20, 'srate', NewEEG.srate, ...
    %             'winlength', 20, 'position', [0 Pix(4)/2 Pix(3) Pix(4)/2])
    %         eegplot(NewEEG.data(:, 100*EEG.srate:300*EEG.srate),'spacing', 20, 'srate', NewEEG.srate, ...
    %             'winlength', 20, 'position', [0 0 Pix(3) Pix(4)/2])
    %     catch
    %         eegplot(Data.data, 'spacing', 20, 'srate', NewEEG.srate, ...
    %             'winlength', 20, 'position', [0 Pix(4)/2 Pix(3) Pix(4)/2])
    %         eegplot(NewEEG.data,'spacing', 20, 'srate', NewEEG.srate, ...
    %             'winlength', 20, 'position', [0 0 Pix(3) Pix(4)/2])
    %     end
    
    % plot before and after in two fullscreen windows
    eegplot(Data.data, 'spacing', 20, 'srate', NewEEG.srate, ...
        'winlength', 20, 'position', [0 0 Pix(3) Pix(4)*.97],  ...
        'eloc_file', Data.chanlocs)
    eegplot(NewEEG.data,'spacing', 20, 'srate', NewEEG.srate, ...
        'winlength', 20, 'position', [0 0 Pix(3) Pix(4)*.97], ...
        'eloc_file', NewEEG.chanlocs,  'winrej',  TMPREJ) % Note: this now plots the segments of data marked as bad
    
    % wait to give person time to look at both plots
    pause(5)
    x = input(['Is the file ok? (y/n/s) '], 's');
else
    x = 'auto';
end

% remove channels not to include in final dataset
NotCh = find(ismember({NewEEG.chanlocs.labels}, string(EEG_Channels.exclude)));
NewEEG = pop_select(NewEEG, 'nochannel', NotCh);

% interpolate channels
FinalChanlocs = StandardChanlocs;
FinalChanlocs(ismember({StandardChanlocs.labels}, string(EEG_Channels.exclude))) = [];
FinalChanlocs(end+1) = CZ;
NewEEG = pop_interp(NewEEG, FinalChanlocs);

switch x
    case 'y'
        % save new dataset
        pop_saveset(NewEEG, 'filename', Filename_Destination, ...
            'filepath', Destination, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        
        disp(['***********', 'Finished ', Filename_Destination, '***********'])
        close all
        Break = true;
        
    case 's'
        Break = false;
        
    case 'auto'
        pop_saveset(NewEEG, 'filename', Filename_Destination, ...
            'filepath', Destination, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        
        disp(['***********', 'Finished ', Filename_Destination, '***********'])
        close all
        Break = false;
    case 'redo'
        delete(fullfile(Source_Comps, Filename_Comps))
        disp(['***********', 'Deleting ', Filename_Destination, '***********'])
        close all
        Break = true;
    otherwise % if 'n' or anything else
        rmComp
end
