function filt_signal = bp_filter(signal, low_thresh,high_thresh,fs)

n           = 5;   % Butterworth filter order
range       = fs/2;
wn          = [low_thresh high_thresh]/range; 
[b,a]       = butter(n,wn);
filt_signal = filtfilt(b,a,signal);
