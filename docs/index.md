> #### Linked pages
> [How to](./HowTo.html) actually run everything without changing anything.
> [What's noise](./CutData.html) and what not to manually remove from EEG data.


This set of MATLAB scripts was developed and used by Sophia Snipes to clean high-density EEG data. This tutorial involves descriptions of the various pieces of code, as well as explanations for certain choices (whether based on prior work, trial-and-error, or just arbitrary), allowing the reader to decide for themselves what they wish to keep or change. There are furthermore detailed descriptions about the manual portions involved in data cleaning, and the criterion used for designating data as noise or artefact. 

Disclaimer: this is a work in progress, and will invariably change as more information comes to light. Exact scripts used in published data are saved in seperate repositories.

# The Pipeline


## 0. Formatting the data
### Dependencies
This process heavily relies on the [EEGLAB Toolbox](https://sccn.ucsd.edu/eeglab/index.php), designed on version 2019.

### Data structure
All files should be saved as ".set", using the EEGLAB data structure. Importantly, these must already contain the fields "srate" and "chanlocs", and of course "data". EEG data is thus stored as a channel x time matrix. An example script is provided for converting data from BrainAmp to EEGLAB.

SET files are expected to be in the same folder, with meaningful names (e.g. "P01_baseline_task1.set"). 

NO PROCESSING should be done to the starting data! It should be the rawest of raw data, saved as an EEGLAB structure. 

### Example script
1. Install BrainAmp extension. This can easily be done from the EEGLAB GUI.
2. Adjust in "General_Parameters.mat" the location of the raw files, and the location in which you want to save the preprocessed data.
3. Run script, and hope for the best!


## 1. Filtering
This script takes the raw data, and filters it in many ways. 

### Filtering parameters

| Type          |  srate     | high-pass | low-pass | stop-band |
| ------------- |:----------:| :-----:   | :-----:  | :-----:   |
| Cleaning      | 125        | 0.5       | 40       | 0.25      |
| ICA           | 500        | 2.5       | 100      | 0.5       |
| Power         | 500        | 0.5       | 40       | 0.25      |
| ERP           | 500        | 0.1       | 40       | 0.05      |


#### Cleaning
This is used for visually inspecting the data and identfying periods of noise. Uses the minimum reasonable sampling rate to make the files lighter, but has the same pass filters as "Power" and "ERP", because different filters will change whether there's an artefact that needs to be cut out or not. 

#### ICA
ICA can have different filtering parameters than the data you actually remove it from. This is good, since ICA does better in a certain frequency range that is different from what is of interest for the EEG.
The parameters were based off [Person et al. 2020](). The high sampling rate and low-pass filter allows the inclusion of microsaccades in the eye components, so these can also be removed. The high high-pass filter is recommended for removing blinks.

> N.B. Some EEG is plagued by sweating artifacts, and these are <1 Hz. These can be removed with ICA, but with different filters.


#### Power
This is the main data I focus on. The components will be removed from this set. The frequency range is typical for sleep research. The high srate was to match the ICA, but I don't know if that actually matters. 


#### ERP
Different filters are needed for calculating Event Related Potentials, since important components like the P300 can be affected by strong filtering. Furthermore, effects can leak into pre-stimulus timepoints, and that is very bad.

![](./images/ERP_filtering.PNG)


### Procedure
This is the steps that the script follows:

1. **Notch filter for line noise.** Unless the recording was done in a really good Faraday cage, there is usually some line noise. In my own data, there was so much I got harmonics. The function provided does a notch filter for the requested frequency and 4 harmonics using a Kaiser FIR filter. I found it on some stackexchange post, I'm no expert, but the data looked reasonable. 
![](./images/NotchHarmonics.PNG)
Usually, this is overkill since most of the time there's the low-pass filter shortly after, but in some recordings, there is just so much line noise, that the LP filter doesn't completely get rid of it. In general, it doesn't hurt.

2. **Low-pass filter.** This is done before resampling as a form of anti-aliasing, and more generally removes non-brain activity (scalp EEG can't actually pick up anything over 100Hz from the brain, if not lower). Since I don't really care too much about the higher frequencies, much less their phase, I just implemented standard EEGLAB filter for this.

3. **Downsampling.** This is usually optional if you didn't record data at insanely high sampling rates like I did. In general, it speeds things up to have lower srates. Rule of thumb is to have a sampling rate 3-5 times higher than your LP filter.

4. **High-pass filter.** This is a more specially designed filter that tries to cut off the lower frequencies at exactly the value indicated (whereas the EEGLAB filter is more gradual, leaving intact frequencies a little lower than the HP cutoff). Importantly, the low-pass and high pass filters need to happen seperately (or so I'm told by engineering types). Also, better to do this filter after downsampling, since it takes a long time. 


## 2. Visual Inspection
This set of scripts allows the experimenter to go through every recording, identify bad channels and bad time segments. At the moment things are very crude, partially using the EEGLAB GUI and the editor to run functions.

The data to be removed in a file saved as "{originalfilename}_Cuts.mat". The functions take advantage of the "writable" property of mat files, so that every change is instantly saved to the mat file without the user having to explicitly save things every time. The only time the user needs to "save" is after using the EEGLAB GUI.

Advice on what data to cut can be found [here](./CutData.html).

### Scripts
This system operates by having a main script that starts the process for each file.
1. A random file is selected.
2. A corresponding "Cuts" mat file is created, saving sampling rate and corresponding filenames/paths. This mat file is where all the other functions save changes.
3. A popup shows the EEG in a scrollable form. This is where you select what data to remove.
4. Channels can be removed by running `rmCh()` in the editor. These will be visualized whenever the EEG popup is re-opened. 
5. When finished with the first file, the researcher runs the script again. Now a random file will be selected, excluding those that already have a corresponding "cuts" file.

#### Prep2_Visual_Inspection.m
This is the script that you start from. By just playing "run", it goes through all the steps needed to initiate a "Cuts" mat file, where the information about what to remove is saved. The cuts file is kept seperate from the EEG, because it can get called independently of any one EEG set file. This script will also open up the EEG viewing window by running `MarkEEG(EEG)`. It also has commented out the other functions that can be run to remove and restore data.
If you wish to clean a specific file, change the variable `Filename = []` to contain the actual filename that interests you. This will work even if a cuts file already exists. 

N.B. So long as you don't clear the workspace, you can access the current file. Once its cleared, the only way to know which file was just edited is to go to your folder of cuts, and see which one was edited most recently. 


#### loadEEGtoCut(Source, Destination, Filename)
This function looks at the source folder, and if no filename is specifically provided, then it will randomly select one of the source files that doesn't have a corresponding "cuts" file in the destination. 

This also creates the cuts mat file, saves the relevant filenames/paths, and srate.


#### MarkData(EEG)
This a bit of a messy script that uses EEGLAB's GUI to show the EEG data, Cut segments already selected, and removed channels. To save selected segments to remove, need to click "save". If you don't want to keep them, just close the window. To see channels removed from the editor, need to close window and run this function again.

#### rmCh(Cuts_Filepath, Channels)
This is used to indicate which channels to remove. Theoretically, if you want to remove the same set of channels, and the Cuts files already exist for them, you could just run this on a loop. 

#### rsCh()
Same as above, only it deselects channels to remove. This is in case you make a mistake and indicated the wrong channel index.