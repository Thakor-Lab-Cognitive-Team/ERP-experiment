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



