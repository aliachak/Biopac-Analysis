%% Example pipeline for preprocessing of heart rate data collected with BIOPAC
clear all; clc

%LOAD DATA -- PPG (photoplethysmography)
    %Example data: 90 trials, divided in 6 blocks of 15 trials.
    load([cd filesep 'Example data' filesep 'Example_Epochs.mat'])  %Load the epoch onset/offset times.
    load([cd filesep 'Example data' filesep 'Example_PPG.mat'])     %Load the raw Biopac data in Matlab format
    PPGdata = Example_PPG;
%CONFIGURATION
    % First modify, then run the configuration script. Note that most
    % analyses can be run if you only specify your sampling rate and
    % localize your SPM folder. Do take a look at the heartrate-specific 
    % default settings below, and see if they suit your needs (generally, 
    % they will).
    BP_Configuration    %(Produces a struct called BPcfg)
%ARTIFACTS
    % Enter the timestamps (in sample numbers) of visually detected artifacts 
    Eyeball = [1300000 1700000]; %For example, there's an artifactual window from 1300 to 1700 seconds (for 1000Hz sampling rate)                               
    [PPGdata,Epochs] = BP_Artifacts_Visual(PPGdata,'PPG',Epochs,Eyeball,BPcfg);    
%INTERPOLATE missing data
    PPGdata = BP_Interpolate(PPGdata,BPcfg);  %Avoids having NaNs in your 1D-signal
%FILTER (PER BLOCK)
    % You have the possibility to filter per block, should your experiment
    % contain blocks that have different signal-to-noise ratios.
    % Alternatively you can filter the entire 1D signal at once, if you
    % didn't divide the experiment in blocks in the configuration script.
    PPGdata = BP_Filter(PPGdata,'PPG',BPcfg);                      
%SMOOTH
    PPGdata = BP_Smooth(PPGdata,'PPG',BPcfg);
%VISUALLY INSPECT TRIALS
    % After these preprocessings steps, you may want to visually inspect
    % the data. For example, filtering can cause ringing artifacts at the
    % edges of your blocks. Here, your rejected trials are set as NaNs.
    Epochs = BP_VisualInspection(PPGdata,Epochs,BPcfg); 
%QUANTIFICATION
    % The PPG signal you have is not very informative until it's
    % quantified; this step translates your signal into a current
    % heartrate-signal, and a measure of net envelope of the signal (a
    % proxy that can be meaningful). It also gives you the locations (in
    % the signal) of the detected signal peaks (if you want to count them).
    [HeartRate,NetEnvelope,PeakLocs] = BP_Quantify_PPG(PPGdata,BPcfg);    
%EPOCHING
    % Now your 1D signal is cut up into pieces according to the Epoch
    % timestamps you specified.
    HeartRate = BP_Epoch(HeartRate,Epochs,BPcfg);
    NetEnvelope = BP_Epoch(NetEnvelope,Epochs,BPcfg);
%CROPPING OR PADDING
    % This step is optional in case you want all epochs to have the same
    % length, when this is not the case yet. For this step you have to
    % define a window in the configuration file
    HeartRate = BP_CropOrPad(HeartRate,'PPG',BPcfg);
    NetEnvelope = BP_CropOrPad(NetEnvelope,'PPG',BPcfg);
%STANDARDIZE
    % For analysis: standardize the signal. You can choose to do so over
    % the whole experiment or per block (if you have reason to expect
    % different signal-to-noise ratios between blocks).
    HeartRate = BP_Standardize(HeartRate,BPcfg);  
    NetEnvelope = BP_Standardize(NetEnvelope,BPcfg);  
 
%% That's it! You're ready to analyze your data now.