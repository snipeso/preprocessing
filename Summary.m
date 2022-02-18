% this script is to plot and quantify the amount of data removed


Datapath = 'D:\Work\adMDD\Data';

Group_Folders = {'HCeve', 'HCmor'; 'MDDeve', 'MDDmor'};

Participants = {'53_', '22_', '50_', '27_', '57_', '36_', '33_', '25_', '42_', '44_', '55_', '41_', '45_';
    '01_', '03_', '05_', '06_', '07_', '08_', '09_', '11_', '12_', '13_', '14_', '15_', '16_'};

Sessions = {'Evening', 'Morning'};


addchARTpaths() % gets functions for chART plots
Colors = [repmat(getColors(1, 'rainbow', 'blue'), size(Participants, 2), 1);
    repmat(getColors(1, 'rainbow', 'red'), size(Participants, 2), 1)];

PlotProps = getProperties('Powerpoint');






%%% number of channels removed

%% load in channel data


% chData_d is a P x S x Ch matrix
chData = zeros(numel(Participants), 2, 128);

for Indx_S = 1:2
    Indx = 1;
    for Indx_G = 1:2
        Path = fullfile(Datapath, Group_Folders{Indx_G, Indx_S}, 'Cleaning', 'Cuts');
        Content = ls(Path);
        for Indx_P = 1:size(Participants, 2)
            badchans = [];
            Filename = deblank(string(Content(strcmp(string(Content(:, 1:3)), Participants{Indx_G, Indx_P}), :)));
            load(fullfile(Path, Filename), 'badchans')
            chData(Indx, Indx_S, badchans) = 1;
            Indx = Indx+1;
            disp(['Finished ', char(Filename)])
        end
    end
end


%% plot 
figure
plotConfettiSpaghetti(sum(chData(2:end, :, :), 3), [], Sessions, Colors(2:end, :), PlotProps)


%% same as above for number of components removed





%% % of data removed in time