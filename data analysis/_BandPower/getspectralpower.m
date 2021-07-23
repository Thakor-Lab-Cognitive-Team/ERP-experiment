function [spectra,F,T]=getspectralpower(data,window,noverlap,fftlen,fs)
spectra=[];
[nc, np]=size(data);
for i=1:nc
    x=data(i,:);
    [S,F,T]=spectrogram(x,window,noverlap,fftlen,fs);
    spectra(i,:,:)=(abs(S)).^2;
end
end