function EEG_filt = hpFilter(EEG, high_pass, hp_stopband)
% Filter made by Sven Leach 2020

fs = EEG.srate;
StopAtten = 60;
PassRipple = 0.05;

hpFilter = designfilt('highpassfir', 'PassbandFrequency', high_pass, ...
    'StopbandFrequency', hp_stopband, 'StopbandAttenuation', StopAtten, ...
    'PassbandRipple', PassRipple, 'SampleRate', fs, 'DesignMethod', 'kaiser');

EEG_filt = firfilt(EEG, hpFilter.Coefficients);

