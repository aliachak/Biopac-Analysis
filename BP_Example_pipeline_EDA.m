%% Example pipeline for preprocessing of skin conductance data collected with BIOPAC
clear all; clc

%LOAD DATA -- EDA (electrodermal activity)
    %Example data: 90 trials, divided in 6 blocks of 15 trials.
    load([cd filesep 'Example data' filesep 'Example_Epochs.mat'])  %Load the epoch onset/offset times.
    load([cd filesep 'Example data' filesep 'Example_EDA.mat']) %Load the raw Biopac data in Matlab format
    EDAdata = Example_EDA;
%CONFIGURATION
    % First modify, then run the configuration script. Note that most
    % analyses can be run if you only specify your sampling rate and
    % localize your SPM folder. Do take a look at the skin
    % conductance-specific default settings below, and see if they suit
    % your needs (generally, they will).
    BP_Configuration    %(Produces a struct called BPcfg)
%ARTIFACTS
    % Enter the timestamps (in sample numbers) of visually detected artifacts 
    Eyeball = [1300000 1700000]; %For example, there's an artifactual window from 1300 to 1700 seconds (for 1000Hz sampling rate)                               
    [EDAdata,Epochs] = BP_Artifacts_Visual(EDAdata,'EDA',Epochs,Eyeball,BPcfg);    
%INTERPOLATE missing data
    EDAdata = BP_Interpolate(EDAdata,BPcfg);  %Avoids having NaNs in your 1D-signal
%FILTER (PER BLOCK)
    % You have the possibility to filter per block, should your experiment
    % contain blocks that have different signal-to-noise ratios.
    % Alternatively you can filter the entire 1D signal at once, if you
    % didn't divide the experiment in blocks in the configuration script.
    BPcfg.filter.BandPass.EDA = [0.01 4.9];
    EDAdata = BP_Filter(EDAdata,'EDA',BPcfg);  
    clc
    return
%SMOOTH
    % Smoothen the data; for low-frequency activity such as that from skin
    % conductance data, you only need this if your signal-to-noise ratio is
    % low.
    EDAdata = BP_Smooth(EDAdata,'EDA',BPcfg);
%VISUALLY INSPECT TRIALS
    % After these preprocessings steps, you may want to visually inspect
    % the data. For example, filtering can cause ringing artifacts at the
    % edges of your blocks. Here, your rejected trials are set as NaNs.
    Epochs = BP_VisualInspection(EDAdata,Epochs,BPcfg);       
%EPOCHING
    % Now your 1D signal is cut up into pieces according to the Epoch
    % timestamps you specified.
    EDAdata = BP_Epoch(EDAdata,Epochs,BPcfg);
%BASELINE CORRECTION
    % This step is optional, but improves the analyses you will perform
    % later.
    % For each epoch, you can subtract the mean vale of a baseline period 
    % from your window-of-interest. Both can be specified in the
    % configuration script.
    EDAdata = BP_Baseline(EDAdata,'EDA',BPcfg);
%STANDARDIZE
    % For analysis: standardize the signal. You can choose to do so over
    % the whole experiment or per block (if you have reason to expect
    % different signal-to-noise ratios between blocks).
    [EDAdata] = BP_Standardize(EDAdata,BPcfg);  
 
%% That's it! You're ready to analyze your data now.