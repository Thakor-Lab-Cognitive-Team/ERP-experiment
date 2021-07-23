%% BPF for preprocessing

data = EEG.data;
fs = EEG.srate;
numChan = size(data,1);
fData = zeros(size(data));
for i = 1:numChan
    fData(i,:) = bp_filter(double(data(i,:)),0.3,50,fs);
end
EEG.data = single(fData);

%do_fft(data,fs);

%% save .set
pop_saveset(EEG);

%{
%% Functions
function filt_signal = bp_filter(signal, low_thresh,high_thresh,fs)

n           = 5;   % Butterworth filter order
range       = fs/2;
wn          = [low_thresh high_thresh]/range;
[b,a]       = butter(n,wn);
filt_signal = filtfilt(b,a,signal);
end

function [Y,f]= do_fft(signal,Fs)

L = length(signal);          % signal length

signal = detrend(signal);      % remove mean of the signal

NFFT = 2^nextpow2(L);        % Next power of 2 from length of signal
Y = fft(signal,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2);

% plot single side fft
figure
plot(f,2*abs(Y(1:NFFT/2))) 
axis([0 Fs/2 0 max(2*abs(Y(1:NFFT/2)))])
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
end
%}