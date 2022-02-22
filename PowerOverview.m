clear
clc
close all

addpath 'C:\Users\colas\Projects\chART'

Datapath = 'D:\Work\adMDD\Data';
Destination = 'D:\Work\adMDD\Preprocessing Eval';

Group_Folders = {'HCeve', 'HCmor'; 'MDDeve', 'MDDmor'};

Participants = {'53_', '22_', '50_', '27_', '57_', '36_', '33_', '25_', '42_', '44_', '55_', '41_', '45_', '58_', '31_';
    '01_', '03_', '05_', '06_', '07_', '08_', '09_', '11_', '12_', '13_', '14_', '15_', '16_', '115', '119'};

Sessions = {'Evening', 'Morning'};
Groups = {'HC', 'MD'};

addchARTpaths() % gets functions for chART plots
Colors = [repmat(getColors(1, 'rainbow', 'blue'), size(Participants, 2), 1);
    repmat(getColors(1, 'rainbow', 'red'), size(Participants, 2), 1)];

PlotProps = getProperties('Powerpoint');



%% get power

Window = 8;
Overlap = .75;

chData = zeros(2, size(Participants, 2), 2, 112);

for Indx_S = 1:2
    for Indx_G = 1:2
        Path = fullfile(Datapath, Group_Folders{Indx_G, Indx_S}, 'Final');
        Content = ls(Path);
        for Indx_P = 1:size(Participants, 2)
            Filename = deblank(string(Content(strcmp(string(Content(:, 1:3)), Participants{Indx_G, Indx_P}), :)));
            EEG = pop_loadset('filename', char(Filename), 'filepath', Path);
            
            fs = EEG.srate;
            
            nfft = 2^nextpow2(Window*fs);
            noverlap = round(nfft*Overlap);
            window = hanning(nfft);
            [Power, Freqs] = pwelch(EEG.data', window, noverlap, nfft, fs);
            chData(Indx_G, Indx_P, Indx_S, :, 1:size(Power, 1)) = Power';
            
            disp(['Finished ', char(Filename)])
        end
    end
end



%% plot spectrums of all channels

for Indx_G = 1:2
    for Indx_S = 1:2
        
        figure('units', 'normalized', 'outerposition', [0 0 1 1])
        for Indx_P = 1:size(Participants, 2)
            subplot(3, 5, Indx_P)
            plot(log(Freqs), log(squeeze(chData(Indx_G, Indx_P, Indx_S, :, :)))', 'Color', [.6 .6 .6 .15], 'LineWidth', .5)
            xlim(log([.5 40]))
            title([Groups{Indx_G}, Participants{Indx_G, Indx_P}, ' ', Sessions{Indx_S}])
            
        end
        setLims(3, 5, 'y')
        saveFig(['Power_', Groups{Indx_G}, '_', Sessions{Indx_S}], Destination, PlotProps)
        
    end
end
