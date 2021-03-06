function [s_data] = BP_Standardize(data,epochs,type,BPcfg)
% BIOPAC data preprocessing toolbox - standardization.
% This function standardizes continuous physiological signals in one of two 
% ways:
%   1. Per block, if you specified them; or
%   2. Across all trials.
% Option (1) is useful if you suspect there are great differences in the
% signal-to-noise ratio between blocks, and if the experimental conditions
% are comparable between blocks. See the configuration script for how to
% define the blocks.
% The data you enter has to be epoched and it is assumed that your entire
% epoch has to be included in the standardization. Trials of different
% durations are allowed.
% 
% INPUT
%   data:  a n�1 cell variable of which every cell contains the data of
%           one trial; i.e. when data has been epoched. In this case, data
%           from rejected trials are discarded in the standardization
%           procedure.
%   BPcfg: the configuration structure that is produced by running
%           BP_Configuration.m. Be sure to enter the correct settings there.
%
% OUTPUT
%   s_data: the standardized dataset (format n�1 trials; like "data" input)
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018

%Settings
    Blocks = BPcfg.signal.Blocks;
        if isempty(Blocks)
            Blocks = 1:length(epochs);
        end
    
%Loop through blocks
    for block = 1:size(Blocks,1)
        %Collect trial signal only
            trial_signal = []; borders = []; count = 1;
                for trial = Blocks(block,:)
                    if ~isnan(epochs(trial,1))       
                        if ~isempty(WOI)    %If you don't want the entire trial, but a specified window after onset.
                            if WOI(2) == Inf %Window extends to the end of the epoch
                                windowend = epochs(trial,2) - (epochs(trial,1)+WOI(1));
                            else
                                windowend = WOI(2);
                            end
                            trial_signal = [trial_signal data(epochs(trial,1)+WOI(1):epochs(trial,1)+windowend)];                
                            borders(trial,:) = [count count+(windowend-WOI(1))]; 
                            count = count+(windowend-WOI(1))+1;    
                        else                %Standardize the entire trial
                            trial_signal = [trial_signal data(epochs(trial,1):epochs(trial,2))];
                            borders(trial,:) = [count count+epochs(trial,2)-epochs(trial,1)];
                            count = count+epochs(trial,2)-epochs(trial,1)+1;          
                        end
                    else                    %Missing trial
                            borders(trial,:) = NaN(1,2);
                    end
                end

        %Standardize signal from trials
            if sum(isnan(trial_signal))==0  %No missing data
                z_trial_signal = zscore(trial_signal);
            else %Missing data
                z_trial_signal = z_missing(trial_signal);
            end            

        %Put the z-scored data back into the 1D signal
            for trial = Blocks(block,:)
                if ~isnan(epochs(trial,1))
                    if ~isempty(WOI)
                        if WOI(2) == Inf %Window extends to the end of the epoch
                            windowend = epochs(trial,2) - (epochs(trial,1)+WOI(1));
                        else
                            windowend = WOI(2);
                        end
                        data(epochs(trial,1)+WOI(1):epochs(trial,1)+windowend) = ...
                            z_trial_signal(borders(trial,1):borders(trial,2));     
                    else %Entire epoch has been standardized
                        data(epochs(trial,1):epochs(trial,2)) = ...
                            z_trial_signal(borders(trial,1):borders(trial,2));     
                    end
                end
            end
    end    
%Output    
    s_data = data;
    disp('Data has been standardized.')
end

%% Auxiliary function: standardize a signal with missing samples
function [st_data] = z_missing(data)
    z_data = zscore(data(~isnan(data)));
    count = 1;
    for samples = 1:length(data)
        if ~isnan(data(samples))
            data(samples) = z_data(count);
            count = count+1;
        end
    end
    st_data = data;
end