# How to just run everything

0. Install EEGLAB and download these preprocessing scripts, preferably cloning them with github
    - if using BrainAmp, then install the "bv toolbox" for eeglab (just use the GUI, try to import one of the files, and there's a menu option for downloading the necessary toolbox for BrainAmp).
1. Change string parameters in *General_Parameters.m*:
    - change the *Paths_Raw* to the location of your .raw files (or .eeg for BrainAmp). N.B. All your files should be in this one folder. If you have subfolders, you'll need to write some code for yourself.
    - *Paths_Preprocessed* variable to the location you want to save the preprocessed files
    - Indicate the filetype (either .raw or .eeg)
2. Run *Prep0_Conversion.m*. This converts the raw files to .set files in the folder *{Paths_Preprocessed}/Unfiltered*.
3. Run *Prep1_Filtering.m*. This can take several hours if you have a lot of data.
    - Current scripts are set for EU recordings; if your data was recorded in a country with 60Hz line noise (e.g. US), change *LineNoise* variable.
    - Current scripts shave off the first 5 seconds of data because there was insane noise; If you don't want this, just provide [] in *ShaveTime*.
4. Run *Prep2_Visual_Inspection.m*. A random file that hasn't been cleaned will be selected. A popup will show the EEG in the EEGLAB GUI "data scroll". Suggestions on what to remove are in [CutData](./CutData.html)
    1. Scroll through all the data, click and drag over columns of data that contain major artefacts. 
    2. Click "Save" to save and close the window. It will not save if you don't click save! 
    3. If there's a whole channel that is bad, go to the editor, run `rmCh(EEG.CutFilepath, [])` with the list of channel indices in []. 
    4. To see which channel you've actually removed, close the current EEG window (save if you selected any data to cut), and then run again `MarkData(EEG)`
    5. If you want to restore the channel removed, just run `rsCh(EEG.CutFilepath)`.
    6. It is also possible to remove a limited segment of data in one channel, but the process hasn't been 100% verified. 
5. Repeat previous step until all data is cleaned.
6. Run *Prep3_ICA.m*.
    - If not using EGI 128ch net, indicate first in the variable "VeryBadChannels" the indices of channels that are not recording brain data, and wouldn't make sense to include.
7. Run *Prep4_Remove_Components.m*. This will randomly select a file, show you the top 35 ICA component topographies. 
    1. Click on the component ID button to see the power spectrum. Use this to decide whether to remove or not.
    2. Click "Reject" if you consider it noise. See [ICA](./ICA.html) to know what counts as noise.
    3. Do the above for all components to remove. Then click "OK".
    4. Two popups will appear, the top with the whole data, the bottom with the data once the selected components were removed. After 5 seconds, the editor will wait for user input on whether the selection of components was ok. 
        - indicate 'y' if the data is correctly cleaned
        - indicate 'n' if you want to select different components.
        - indicate 's' if you want to skip and do a different one.
    5. Repeat 4 until the data is cleaned. This also allows you to play around while learning what to remove. N.B. The data columns to cut are not indicated, so there might be bad data that isn't supposed to go away with the ICA, but you have already indicated as bad.
8. Run *Prep5_Interpolation.m*. This will save all the data in *{Paths_Preprocessed}/Interpolated* where every file has the same number of channels, the data has been filtered, and all the bad components have been removed. Use this for later analyses.
    - Change *Exclude_Channels* if you have different preferences of which channels to keep in the end.
