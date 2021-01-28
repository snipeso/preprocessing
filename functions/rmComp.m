% Script by Sophia Snipes, 28/01/21
% script that get looped for removing the selected components, plotting
% them, then saving them.


close all
clc

if ~Automate
    % remind user which dataset they're cleaning
    disp(Filename_Comps)
    
    % open interface for selecting components
    pop_selectcomps(EEG, 1:35);
    
    disp('press enter to proceed')
    
    % wait, only proceed when prompted
    pause
    
end

% get bad components
badcomps = find(EEG.reject.gcompreject);
clc
disp(Filename_Comps)

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

% remove components
NewEEG = pop_subcomp(NewEEG, badcomps);

% low-pass filter
NewEEG = pop_eegfiltnew(NewEEG, [], 40); % for whatever reason, sometimes ICA removal introduced high frequency noise




if CheckOutput
    % % show
    Pix = get(0,'screensize');
    try
    eegplot(Data.data(:, 100*EEG.srate:300*EEG.srate), 'spacing', 20, 'srate', NewEEG.srate, ...
        'winlength', 20, 'position', [0 Pix(4)/2 Pix(3) Pix(4)/2])
    eegplot(NewEEG.data(:, 100*EEG.srate:300*EEG.srate),'spacing', 20, 'srate', NewEEG.srate, ...
        'winlength', 20, 'position', [0 0 Pix(3) Pix(4)/2])
    catch
          eegplot(Data.data, 'spacing', 20, 'srate', NewEEG.srate, ...
        'winlength', 20, 'position', [0 Pix(4)/2 Pix(3) Pix(4)/2])
    eegplot(NewEEG.data,'spacing', 20, 'srate', NewEEG.srate, ...
        'winlength', 20, 'position', [0 0 Pix(3) Pix(4)/2])
    end
    
    % wait to give person time to look at both plots
    pause(5)
    x = input(['Is ', Filename_Destination, ' ok? (y/n/s) '], 's');
else
    x = 'auto';
end

if strcmpi(x, 'y')
    
    % save new dataset
    pop_saveset(NewEEG, 'filename', Filename_Destination, ...
        'filepath', Destination, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
    
    disp(['***********', 'Finished ', Filename_Destination, '***********'])
    close all
    Break = true;
elseif strcmpi(x, 'n')
    rmComp
elseif strcmpi(x, 'auto')
    pop_saveset(NewEEG, 'filename', Filename_Destination, ...
        'filepath', Destination, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
    
    disp(['***********', 'Finished ', Filename_Destination, '***********'])
    close all
    Break = false;
else
    Break = false;
end
