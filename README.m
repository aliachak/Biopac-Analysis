%% Readme: Biopac-Analysis toolkit
% By Roeland Heerema (roelandheerema@hotmail.com)
% last update April 2018

% This toolbox offers a number of functions to help you analyze three data
% types acquired using BIOPAC: heart rate (PPG), skin conductance (EDA),
% and facial musculature (EMG).

% Take a look at the example pipelines and try them out using the example
% data. This will give you a feel for how to use the functions.

% The key idea is that you can perform your preprocessing with minimal
% information provided. This is where the BP_Configuration script comes in.
% Here, you only have to fill in the sampling rate of your signal (e.g.,
% 1000Hz for the example data) and the directory where you saved SPM
% (because some tools use functions from the SPM external plugin
% "FieldTrip", developed for M/EEG data.

% Overview of the functions:
% - BP_Artifacts_Visual: look at your trials and determine which ones to
% reject visually,
% - BP_Baseline: baseline-correction, provided you entered the timestamp of
% your window-of-interest and its preceding baseline,
% - BP_CropOrPad: crop or pad the data so that all trials have the same
% length (the aforementioned window you can optionally specify),
% - BP_Epoch: cut up a 1D-signal into epochs based on the timestamps you
% provide,
% - BP_Filter: remove frequencies of no interest from your signal
% - BP_Interpolate: linearly fills the gaps in your signal, e.g. where you
% identified artifacts
% - BP_Quantify_PPG: specific quantification script for PPG data:
% produces the heartrate and envelope of the signal; output of the same 
% size as the input
% - BP_Smooth: smoothens your signal
% - BP_Standardize: z-scores your trials (epoched data entered)
% - BP_Standardize_1D: z-scores a 1D-signal
% - BP_VisualInspection: visualizes your signal and trial onsets; allows
% you to visually identify noisy trials.