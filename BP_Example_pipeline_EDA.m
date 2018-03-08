%% Example pipeline for preprocessing of skin conductance data collected with BIOPAC
clear all; clc

%LOAD DATA
    load('ppt_39_11052017.mat') %Load the raw Biopac data in Matlab format
    EDAdata = data(:,6);        %From your Biopac dataset, select the skin conductance channel
    load('Trigger_ppt_39_11052017.mat');    
    Epochs = Trigger.Epochs;    %Load your epochs, this should be a cell of size ntrials×2 
                                %(columns for [onset sample number, offset sample number])
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
    EDAdata = BP_Interpolate(EDAdata);  %Avoids having NaNs in your 1D-signal
%FILTER (PER BLOCK)
    % You have the possibility to filter per block, should your experiment
    % contain blocks that have different signal-to-noise ratios.
    % Alternatively you can filter the entire 1D signal at once, if you
    % didn't divide the experiment in blocks in the configuration script.
    EDAdata = BP_Filter(EDAdata,'EDA',BPcfg);                      
%SMOOTH
    % Smoothen the data; for low-frequency activity such as that from skin
    % conductance data, you only need this if your signal-to-noise ratio is
    % low.
    EDAdata = BP_Smooth(EDAdata,'EDA',BPcfg);
%VISUALLY INSPECT TRIALS
    % After these preprocessings steps, you may want to visually inspect
    % the data. For example, filtering can cause rining artifacts at the
    % edges of your blocks.
    Epochs = BP_VisualInspection(EDAdata,Epochs,BPcfg);       
%EPOCHING
    % Now your 1D signal is cut up into pieces according to the Epoch
    % timestamps you specified.
    EDAdata = BP_Epoch(EDAdata,Epochs,BPcfg);
%STANDARDIZE
    % For analysis: standardize the signal. You can choose to do so over
    % the whole experiment or per block (if you have reason to expect
    % different signal-to-noise ratios between blocks).
    [EDAdata] = BP_Standardize(EDAdata,BPcfg);  
 
%% That's it! You're ready to analyze your data now.