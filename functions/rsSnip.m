function rsSnip(EEG, StartTime, EndTime, Channel)
% Function by Sophia Snipes, 2020
% Unselects a snippet of data from a channel from the matrix marking
% snippets to be removed. N.B.: the timepoints don't have to be exact match
% for the ones marked by rmSnip. 

m = matfile(EEG.CutFilepath,'Writable',true);

Content = whos(m);

fs = EEG.srate;
[ch, pnts] = size(EEG.data);
Start = round(StartTime*fs);
End = round(EndTime*fs);

% handle incorrect inputs
if Start < 1
    Start = 1;
end

if End > pnts
    End = pnts;
end

if Channel < 1 || Channel > ch
    error('Not a real channel')
end

if ismember('cutData', {Content.name})
    m.cutData(Channel, Start:End) = nan;
end
