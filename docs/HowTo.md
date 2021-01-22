# How to just run everything

0. Figure out for yourself how to convert data into a "set" file. Make sure all the data you want to clean is in the same folder, called "Unfiltered".
1. In *General_Parameters.m*, change the *Paths_Preprocessed* variable to the location of your "Unfiltered" folder.
2. Run *Prep1_Filtering.m*. This can take several hours if you have a lot of data.
3. Run *Prep2_Visual_Inspection.m*. A popup will show the EEG in the EEGLAB GUI "data scroll". 
    1. Scroll through all the data, click and drag over segments that contain major artefacts. 
    2. Click "Save" to save and close the window. It will not save if you don't click save! 
    3. If there's a whole channel that is bad, go to the editor, run `rmCh(EEG.CutFilepath, [])` with the list of channel indices in []. 
    4. To see which channel you've actually removed, close the current EEG window (save if you selected any data to cut), and then run again `MarkData(EEG)`
    5. If you want to restore the channel removed, just run `rsCh(EEG.CutFilepath)`.
4. Repeat 3 until all data is cleaned. Suggestion: either have anonymized/blinded filenames, or take special care not to look at the editor before choosing what to remove and leave behind to avoid biasing the data cleaning.
5. Run 