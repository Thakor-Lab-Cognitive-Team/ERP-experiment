clc; clear;

%% Connect to arduino stimulator and sensor
if exist('stimulator', 'var') == 0
    stimulator = serialport('/dev/cu.usbmodem14301', 9600);
    flush(stimulator);
    configureTerminator(stimulator, "LF");
end

if exist('stimulator', 'var') == 1
    fprintf('Arduino Uno stimulator connected on %s \n', stimulator.Port);
else
    error('Error: Arduino stimulator not connected \n');
end

fprintf('Experiment: ERP study with TENS and Vibration \n');


%% 2. Threshold detection
duration = 2; % duration of stimulation in sec
delay = 4; % delay after stimulation in sec
freq = 2; % frequency in Hz
PW = [0.1 0.3 0.5 0.7 0.9]; % pulse width in ms
percentage = zeros(5, 1);
presentation = 25;

% Generate random sequence of stimulation
sequence = randi(5, 1, presentation);
pw_sequence = PW(sequence);


for i = 1:presentation
    fprintf('\n%d of %d\r', i, presentation);
    pause(1);
    out = zeros(1, 4);
    out(1) = 1; % start flag for Arduino
    out(2) = duration; % length of stimulation in sec
    out(3) = freq; % frequency of pulse in Hz
    out(4) = pw_sequence(i); % pulse width of stimulation in ms   
    write(stimulator, out, 'single');
    pause(duration);
    percentage(sequence(i)) = percentage(sequence(i)) + input('Do you feel the stimulation? 1 is No, 2 is Yes: ') - 1;
end

% Save data
for i = 1:5
    percentage(i) = percentage(i) / sum(sequence == i);
end
[~, idx] = min(abs(percentage - 0.5));
threshold = PW(idx);
plot(PW, percentage, '-*');
fprintf('The threshold pulse width is %d\n', threshold);

fprintf('finished threshold detection\n');