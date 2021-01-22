function rsSnip(EEG, StartTime, EndTime, Channel)
% Function by Sophia Snipes, 2020
% Unselects a snippet of data from a channel from the matrix marking
% snippets to be removed. N.B.: the timepoints don't have to be exact match
% for the ones marked by rmSnip. 

m = matfile(EEG.CutFilepath,'Writable',true);

Content = whos(m);

fs = EEG.srate;
Start = round(StartTime*fs);
End = round(EndTime*fs);

% edge case if EndTime is later than the actual file end
Max = size(EEG.data, 2);
if End > Max
    End = Max;
end

if ismember('cutData', {Content.name})
    m.cutData(Channel, Start:End) = nan;
end
