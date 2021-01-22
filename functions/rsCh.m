function rsCh(CutFilepath, Ch)
% Function by Sophia Snipes, 2020
% Removes from list of channels to remove the provided list of channels Ch.

m = matfile(CutFilepath,'Writable',true);

Content = whos(m);
if ismember('badchans', {Content.name})
   m.badchans(ismember(m.badchans, Ch)) = [];
else
    m.badchans = Ch;
end
    