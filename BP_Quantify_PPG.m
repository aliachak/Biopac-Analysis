function [HeartRate,NetEnvelope,Amplitude,PeakLocs] = BP_Quantify_PPG(data,BPcfg)
% BIOPAC data preprocessing toolbox - oxymetry quantification.
% This function produces three time-resolved quantifications of the
% oxymetry (heart beat measures) data from Biopac.
% 
%   data: a 1×n variable of type double that contains the n datapoints of 
%           the one heart rate channel (often called PPG by Biopac). 
%           It is recommended that the data has been preprocessed and that 
%           missing data has been interpolated before entering it here. 
%   BPcfg: the configuration structure that is produced by running
%           BP_Configuration.m. Be sure to enter the correct settings there.
%
% OUTPUT
%   HeartRate: a variable of size 1×n with the time-resolved heart rate
%       (based on distances between detected heart beats; interpolated 
%       between peaks)
%   NetEnvelope: the envelope of the oxymetry signal; interpolated between
%       peaks.
%   Amplitude: the peak amplitude of the discrete Fourier-transformed (DFT)
%       signal taken around every detected peak. This quantity is known to
%       correlate closely with blood pressure. One value per detected peak
%       is recorded; other data points are interpolated between these
%       points.
%   PeakLocs: locations of detected peaks. All zeros except at the points
%       of a detected heart beat peak (ones).
% Written by Roeland Heerema (roelandheerema@hotmail.com) in January 2018


%1. Find peak locations
    try %use existing Matlab function in "signal" toolbox
        [pos_PKS,pos_LOCS]= findpeaks(data);   
    catch %if not present, do the following:
        pos_LOCS = [];
        for i = 2:length(data)-1
            if e(i-1) <= e(i) && e(i+1) <= e(i)
                pos_LOCS = [pos_LOCS; i];
            end
        end
        pos_PKS = data(pos_LOCS);
    end
    PeakLocs = zeros(size(data)); PeakLocs(pos_LOCS) = 1;
 
%2. Make heart rate signal and interpolate
    BPM = pos_LOCS(2:end)-pos_LOCS(1:length(pos_LOCS)-1);   %Durations (in samples) between heart beats
    BPM = 60./(BPM/BPcfg.signal.FS);            %Express in beats per minute
    HeartRate = NaN(size(data));
        HeartRate(pos_LOCS(2:end)) = BPM;
        HeartRate = InterpolatePPG(HeartRate);
    
%3. Interpolate PKS signal (envelope) - respiration proxy
    PosEnvelope = NaN(size(data));
        for i = 1:length(pos_PKS)
            PosEnvelope(pos_LOCS(i)) = pos_PKS(i);
        end      
        PosEnvelope = InterpolatePPG(PosEnvelope); 
    NegEnvelope = NaN(size(data));
        try
            [neg_PKS,neg_LOCS]= findpeaks(-data);   
        catch %if not present, do the following:
            neg_LOCS = [];
            for i = 2:length(data)-1
                if e(i-1) <= e(i) && e(i+1) <= e(i)
                    neg_LOCS = [neg_LOCS; i];
                end
            end
            neg_PKS = data(neg_LOCS);
        end
        for i = 1:length(neg_PKS)
            NegEnvelope(neg_LOCS(i)) = -neg_PKS(i);
        end   
        NegEnvelope = InterpolatePPG(NegEnvelope);                
    NetEnvelope = PosEnvelope-NegEnvelope;    
    
%4. Compute amplitude of the discrete Fourier transformation (DFT) per beat
    Amplitude = NaN(size(data));
    %Make sure there are enough data points before the onset of the first beat cycle:
        first_neg_loc = find((neg_LOCS(1:end-1) - 0.05*(neg_LOCS(2:end)-neg_LOCS(1:end-1)))>0,1,'first');  
    %Find the first (positive) peak after the detected first trough:
        first_pos_loc = find(pos_LOCS > neg_LOCS(first_neg_loc),1,'first');
    %Make sure there are enough data points after the offset of the last beat cycle:
        last_neg_loc = find((neg_LOCS(2:end) + 0.10*(neg_LOCS(2:end)-neg_LOCS(1:end-1)))<=length(data),1,'last');  
    %Find the last (positive) peak before the detected last trough:
        last_pos_loc = find(pos_LOCS < neg_LOCS(last_neg_loc),1,'last');
    %Loop through the cycles for amplitude estimation:
        amp_pos_locs = pos_LOCS(first_pos_loc:last_pos_loc);
        amp_neg_locs = neg_LOCS(first_neg_loc:last_neg_loc);
        for cycle = 1:length(amp_pos_locs)
            window = amp_neg_locs(cycle)-round(0.05*(amp_neg_locs(cycle+1)-amp_neg_locs(cycle))) : ... %start of window
                amp_neg_locs(cycle+1)+round(0.1*(amp_neg_locs(cycle+1)-amp_neg_locs(cycle)));
            X = 1/length(window)*fftshift(fft(data(window),length(window)));%N-point complex DFT
            %----- NOTE: for now, the peak amplitude is taken!
            Amplitude(amp_pos_locs(cycle)) = max(sqrt(real(X).^2+imag(X).^2));
        end
        Amplitude = InterpolatePPG(Amplitude); 
        
%5. Visualize time-resolved data
    if BPcfg.quantify.PPG.Visualize
        figure
        subplot(2,1,1); hold on  %Raw signal + detected peaks
            plot(data); plot(PosEnvelope); plot(NegEnvelope)
            title('Raw signal and envelope')
        subplot(2,1,2); hold on
            plot(NetEnvelope); 
            plot(HeartRate/60);
            plot(Amplitude);
            title('Net envelope and heart rate (per second)')
            legend({'Envelope','BPS','Amplitude'})
    end            
end

%% Subfunction: interpolate heart rate signal
function [i_data] = InterpolatePPG(data)
%This function is a lot faster than the BP_Interpolate one because it is
%especially made to interpolate heart rate data (i.e., relatively very few
%samples are not NaN because they are the detected peaks)

Peaks = find(~isnan(data));
for i = 1:length(Peaks)
    if i == 1   %Boundary condition: start
        if Peaks(1) ~= 1    %First sample is no peak
            data(1:Peaks(1)) = data(Peaks(1));
        end
    else
        if i == length(Peaks)
            if Peaks(i) ~= length(data) %Last sample is no peak
                data(Peaks(i):end) = data(Peaks(i));
            end
        end
    %Replace all NaN's between peaks (linear interpolation)
        x = [Peaks(i-1) Peaks(i)];
        v = [data(Peaks(i-1)) data(Peaks(i))];
        xq = Peaks(i-1):Peaks(i);
        data(xq) = interp1(x,v,xq);
    end
end

i_data = data;  %Output

end