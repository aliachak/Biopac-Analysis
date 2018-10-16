function [s_data] = BP_Standardize(data,type,BPcfg)
% BIOPAC data preprocessing toolbox - standardization.
% This function standardizes continuous physiological signals in one of two 
% ways:
%   1. Per block, if you specified them; or
%   2. Across all trials.
% Option (1) is useful if you suspect there are great differences in the
% signal-to-noise ratio between blocks, and if the experimental conditions
% are comparable between blocks. See the configuration script for how to
% define the blocks.
% The data you enter has to be epoched. The window and baseline signal you 
% specified in the configuration file will be included in the
% standardization. If you want the entire epoch to be standardized, be sure
% that the baseline or window include sample 1:end. Trials of different
% durations are allowed.
% 
% INPUT
%   data:  a n×1 cell variable of which every cell contains the data of
%           one trial; i.e. when data has been epoched. In this case, data
%           from rejected trials are discarded in the standardization
%           procedure.
%   BPcfg: the configuration structure that is produced by running
%           BP_Configuration.m. Be sure to enter the correct settings there.
%
% OUTPUT
%   s_data: the standardized dataset (format n×1 trials; like "data" input)
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018

%Settings
    FS = BPcfg.signal.FS;   %Sampling rate
    Blocks = BPcfg.signal.Blocks;
        if isempty(Blocks)
            Blocks = 1:length(data);
        end
        s_data = cell(size(data));  %output
    %Get the signal of interest (the specified window and baseline)
        switch type
            case 'EMG'
                signal_start = min(BPcfg.Window.EMG(:,1))*FS;
                signal_end = max(BPcfg.Window.EMG(:,2))*FS;
            case 'EDA'
                signal_start = min(BPcfg.Window.EDA(:,1))*FS;
                signal_end = max(BPcfg.Window.EDA(:,2))*FS;
            case 'PPG'
                signal_start = min(BPcfg.Window.PPG(:,1))*FS;
                signal_end = max(BPcfg.Window.PPG(:,2))*FS;
        end
        if signal_start == 0; signal_start = 1; end %Start with the first, not the zero-th sample
%Loop through blocks
    for block = 1:size(Blocks,1)
        %Collect trial signal only
            all_trial_signal = []; borders = []; count = 1;
                for trial = Blocks(block,:)
                    if ~isempty(data{trial})   
                        trial_signal = data{trial};
                        if signal_end == Inf;
                            trial_signal = trial_signal(signal_start:end);
                        else
                            trial_signal = trial_signal(signal_start:signal_end);
                        end
                        all_trial_signal = [all_trial_signal trial_signal];
                        borders(trial,:) = [count count+length(trial_signal)-1];
                        count = count+length(trial_signal);
                    else
                        borders(trial,:) = NaN(1,2);
                    end
                end
        %Standardize signal from trials
                z_trial_signal = nanzscore(all_trial_signal);
%                 z_trial_signal = z_missing(all_trial_signal); %if there's missing data
        %Put the z-scored data back into the 1D signal
            for trial = Blocks(block,:)
                if ~isempty(data{trial})
                    z_data = data{trial};
                    if signal_end == Inf
                        z_data(signal_start:end) = z_trial_signal(borders(trial,1):borders(trial,2));     
                    else
                        z_data(signal_start:signal_end) = z_trial_signal(borders(trial,1):borders(trial,2));     
                    end
                        s_data{trial} = z_data; 
                end
            end
    end    
    disp('Data has been standardized.')
end

% %% Auxiliary function: standardize a signal with missing samples
% function [st_data] = z_missing(data)
%     z_data = zscore(data(~isnan(data)));
%     count = 1;
%     for samples = 1:length(data)
%         if ~isnan(data(samples))
%             data(samples) = z_data(count);
%             count = count+1;
%         end
%     end
%     st_data = data;
% end