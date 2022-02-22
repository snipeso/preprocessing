% this script is to plot and quantify the amount of data removed
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






%%% number of channels removed

%% load in channel data & removed windows


% chData_d is a P x S x Ch matrix
chData = zeros(numel(Participants), 2, 128);
tData = zeros(numel(Participants), 2, 2); % time removed, total time

for Indx_S = 1:2
    Indx = 1;
    for Indx_G = 1:2
        Path = fullfile(Datapath, Group_Folders{Indx_G, Indx_S}, 'Cleaning', 'Cuts');
        Content = ls(Path);
        for Indx_P = 1:size(Participants, 2)
            badchans = [];
            TMPREJ = [];
            Filename = deblank(string(Content(strcmp(string(Content(:, 1:3)), Participants{Indx_G, Indx_P}), :)));
            load(fullfile(Path, Filename), 'badchans', 'TMPREJ', 'srate')
            chData(Indx, Indx_S, badchans) = 1;
            
            % get total of removed data
            if size(TMPREJ, 1) >= 1
                tData(Indx, Indx_S, 1) = sum(diff(TMPREJ(:, 1:2)/srate, 1, 2));
            end
            
            disp(['Finished ', char(Filename)])
                        Indx = Indx+1;
        end
    end
end


%% same as above for components removed

icData = zeros(numel(Participants), 2, 2); % components removed, total components

for Indx_S = 1:2
    Indx = 1;
    for Indx_G = 1:2
        Path = fullfile(Datapath, Group_Folders{Indx_G, Indx_S}, 'ICA', 'Components');
        Content = ls(Path);
        for Indx_P = 1:size(Participants, 2)
            badchans = [];
            TMPREJ = [];
            Filename = deblank(string(Content(strcmp(string(Content(:, 1:3)), Participants{Indx_G, Indx_P}), :)));
            EEG = pop_loadset('filename', char(Filename), 'filepath', Path);
            
            % get total data size
            tData(Indx, Indx_S, 2) = size(EEG.data, 2)/EEG.srate;
           
            icData(Indx, Indx_S, 1) = nnz(EEG.reject.gcompreject);
            icData(Indx, Indx_S, 2) = numel(EEG.reject.gcompreject);
            
            disp(['Finished ', char(Filename)])             
            Indx = Indx+1;
        end
    end
end

%% plot 

figure
plotConfettiSpaghetti(sum(chData, 3), [], Sessions, Colors, PlotProps)
title('# of removed channels', 'FontSize', PlotProps.Text.TitleSize)
legend(Groups)


saveFig('ChannelsRemoved', Destination, PlotProps)

%% same as above for number of components removed

Data = squeeze(icData(:, :, 1)./icData(:, :, 2))*100;

figure
plotConfettiSpaghetti(Data, [], Sessions, Colors, PlotProps)
title('% removed components', 'FontSize', PlotProps.Text.TitleSize)
legend(Groups)

saveFig('ComponentsRemoved', Destination, PlotProps)

%% % of data removed in time
figure
plotConfettiSpaghetti(squeeze(tData(:, :, 2))/60, [], Sessions, Colors, PlotProps)
title('Total recording time', 'FontSize', PlotProps.Text.TitleSize)
ylabel('minutes')
legend(Groups)

saveFig('TimeRecordings', Destination, PlotProps)


%%
figure
Data = squeeze(tData(:, :, 1)./tData(:, :, 2))*100;
plotConfettiSpaghetti(Data, [], Sessions, Colors, PlotProps)
title('% time removed', 'FontSize', PlotProps.Text.TitleSize)
legend(Groups)

saveFig('TimeRemoved', Destination, PlotProps)

