function rmSnip(EEG, StartTime, EndTime, Channel)
% Function by Sophia Snipes, 2020
% Used to manually mark a segment of data in a single channel to remove.
% StartTime and EndTime should be indicated in seconds. N.B.: if this is
% run even once, then the EEG data to plot will double, and so things will
% get slower.

m = matfile(EEG.CutFilepath,'Writable',true);

Content = whos(m);

if ~ismember('cutData', {Content.name})
    m.cutData = nan(size(EEG.data)); % for plotting purposes
end

fs = EEG.srate;
[ch, pnts] = size(EEG.data); 
Start = round(StartTime*fs);
End = round(EndTime*fs);

%%% handle incorrect inputs
if Start < 1
    Start = 1;
end

% edge case if EndTime is later than the actual file end
Max = size(EEG.data, 2);
if End > Max
    End = Max;
end

if Channel < 1 || Channel > ch
    error('Not a real channel')
end

%%% save snippet to cut
m.cutData(Channel, Start:End) = EEG.data(Channel, Start:End);
