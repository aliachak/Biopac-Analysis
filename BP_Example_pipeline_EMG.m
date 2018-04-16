%% Example pipeline for preprocessing of electromyography data collected with BIOPAC
clear all; clc

%LOAD DATA -- EMG (electromyography)
    %Example data: 90 trials, divided in 6 blocks of 15 trials.
    load([cd filesep 'Example data' filesep 'Example_Epochs.mat'])  %Load the epoch onset/offset times.
    load([cd filesep 'Example data' filesep 'Example_EMG.mat'])     %Load the raw Biopac data in Matlab format
    EMGdata = Example_EMG;
%CONFIGURATION
    % First modify, then run the configuration script. Note that most
    % analyses can be run if you only specify your sampling rate and
    % localize your SPM folder. Do take a look at the EMG-specific 
    % default settings below, and see if they suit your needs (generally, 
    % they will).
    BP_Configuration    %(Produces a struct called BPcfg)
%ARTIFACTS
    % Enter the timestamps (in sample numbers) of visually detected artifacts 
    Eyeball = [1300000 1700000]; %For example, there's an artifactual window from 1300 to 1700 seconds (for 1000Hz sampling rate)                               
    [EMGdata,Epochs] = BP_Artifacts_Visual(EMGdata,'EMG',Epochs,Eyeball,BPcfg);    
%INTERPOLATE missing data
    EMGdata = BP_Interpolate(EMGdata,BPcfg);  %Avoids having NaNs in your 1D-signal
%FILTER (PER BLOCK)
    % You have the possibility to filter per block, should your experiment
    % contain blocks that have different signal-to-noise ratios.
    % Alternatively you can filter the entire 1D signal at once, if you
    % didn't divide the experiment in blocks in the configuration script.
    EMGdata = BP_Filter(EMGdata,'EMG',BPcfg);                      
%SMOOTH
    EMGdata = BP_Smooth(EMGdata,'EMG',BPcfg);
%VISUALLY INSPECT TRIALS
    % After these preprocessings steps, you may want to visually inspect
    % the data. For example, filtering can cause ringing artifacts at the
    % edges of your blocks. Here, your rejected trials are set as NaNs.
    Epochs = BP_VisualInspection(EMGdata,Epochs,BPcfg);    
%EPOCHING
    % Now your 1D signal is cut up into pieces according to the Epoch
    % timestamps you specified.
    EMGdata = BP_Epoch(EMGdata,Epochs,BPcfg);
%CROPPING OR PADDING
    % This step is optional in case you want all epochs to have the same
    % length, when this is not the case yet. For this step you have to
    % define a window in the configuration file
    EMGdata = BP_CropOrPad(EMGdata,'EMG',BPcfg);
%STANDARDIZE
    % For analysis: standardize the signal. You can choose to do so over
    % the whole experiment or per block (if you have reason to expect
    % different signal-to-noise ratios between blocks).
    EMGdata = BP_Standardize(EMGdata,BPcfg);  
 
%% That's it! You're ready to analyze your data now.