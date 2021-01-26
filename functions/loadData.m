function [EEG, SET] = loadData(Filename, Filepath)
% Reads either EGI or BrainAmp data

% get channel locations file for 128 channels
load('StandardChanlocs128.mat', 'StandardChanlocs')


% get common part of filename
Core = extractBefore(Filename, '.');
Filetype = extractAfter(Filename, '.');
SET = [Core, '.set'];

switch Filetype
    case 'raw'
        % open the file
        fid = fopen([Filepath, Filename], 'rb', 'b');
        [segInfo, dataFormat, header_array, EventCodes, Samp_Rate, NChan, scale, NSamp, NEvent] = readRAWFileHeader(fid);
        fclose(fid);
        
        % save all info to EEG structure
        EEG.setname = SET;
        EEG.filename = Filename;
        EEG.filepath = Filepath;
        
        EEG.nbchan = NChan;
        EEG.pnts = NSamp;
        EEG.srate = Samp_Rate;
        EEG.scale = scale;
        EEG.seginfo = segInfo;
        EEG.dataformat = dataFormat;
        EEG.headerarray = header_array;
        EEG.EventCodes = EventCodes;
        EEG.nevent = NEvent;
        
        % convert and load to structure the EEG data
        EEG.data = loadEGIBigRaw([Filepath, Filename],1:NChan);
        
    case 'eeg'
        VHDR = [Core, '.vhdr'];
        EEG = pop_loadbv(Filepath, VHDR); % If this doesn't work, it's because you didn't download the BV extention yet
end

% update EEG structure
EEG.ref = 'CZ';
EEG.chanlocs = StandardChanlocs;