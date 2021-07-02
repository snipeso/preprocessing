function [EEG, SET] = loadData(Filename, Filepath)
% Reads either EGI or BrainAmp data


% get common part of filename
Core = extractBefore(Filename, '.');
Filetype = extractAfter(Filename, '.');
SET = [Core, '.set'];

switch Filetype
    case 'raw'
        % open the file
        fid = fopen(fullfile(Filepath, Filename), 'rb', 'b');
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
        EEG.event = [];
        EEG.trials = 0;
        EEG.nevent = NEvent; % TODO: 
        EEG.icawinv = [];
        EEG.icaweights = [];
        EEG.icasphere = [];
        EEG.xmax = EEG.pnts;
        EEG.xmin = 0;
        EEG.icaact = [];
        
        % convert and load to structure the EEG data
        Data = loadEGIBigRaw(fullfile(Filepath, Filename),1:NChan);
        
        EEG.data = Data;
       
    case 'eeg'
        VHDR = [Core, '.vhdr'];
        EEG = pop_loadbv(Filepath, VHDR); % If this doesn't work, it's because you didn't download the BV extention yet
end

EEG = eeg_checkset(EEG);