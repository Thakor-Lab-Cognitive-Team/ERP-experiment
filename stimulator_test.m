if exist('stimulator', 'var') == 0
    stimulator = serialport('/dev/cu.usbmodem14301', 9600);
    flush(stimulator);
end

if exist('stimulator', 'var') == 1
    fprintf('Arduino Uno stimulator connected on %s \n', stimulator.Port);
else
    error('Error: Arduino stimulator not connected \n');
end

%%
presentation = 4; % number of presentations for each trial
duration = 2; % duration of stimulation in sec
delay = 0; % delay after stimulation in sec
PW = 1; % pulse width in ms
freq = 20; % frequency in Hz

out = zeros(1, 4);
out(1) = 1; % start flag for Arduino
out(2) = duration; % length of stimulation in sec
out(3) = freq; % frequency of the pulse in Hz
out(4) = PW; % pulse width of stimulation in ms

for j = 1:presentation
    fprintf('%d of %d|\r\n', j, presentation);
    write(stimulator, out, 'single');
    pause(duration + delay);
end