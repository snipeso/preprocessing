> ### Linked pages
> [version 1](./ICA.html)


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
1) Install BrainAmp extension. This can easily be done from the EEGLAB GUI.
2) Adjust in "General_Parameters.mat" the location of the raw files, and the location in which you want to save the preprocessed data.


## 1. 
