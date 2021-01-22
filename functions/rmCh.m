function rmCh(CutFilename, Ch)
% Function by Sophia Snipes, 2020
% used with Prep2 for manually identifying channels to remove. Updates mat
% file of cuts with channels to remove.

m = matfile(CutFilename,'Writable',true);

Content = whos(m);
if ismember('badchans', {Content.name})
   m.badchans = [m.badchans, Ch];
else
    m.badchans = Ch;
end
    