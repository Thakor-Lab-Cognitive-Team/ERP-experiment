%{
Structure of the experiment:

1st block sensory mapping:
stimulate the subject with TENS and vibrotactile
stimulation and map areas of stimulation

2nd block threshold detection:
stimulate the subject with different intensity of TENS and viobrotactile
and identify the 50% stimulation threshold

3rd block sensory feedback:
stimulate the subject with the 50% stimulation threshold and two
intensities above it, and record the force applied for each level

4th block EEG recordings:
1. apply force when there is a stimulus, disregard intensity
2. apply force when there is a stimulus with regards to discrete intensity
3. apply force when there is a stimulus with regards to continuous
intensity
%}
clc; clear;

%% Connect to arduino stimulator and sensor
subject_name = input('Enter subject name: ', 's');
folder_name = strcat('data/', date, '/', subject_name);
mkdir(folder_name);

if exist('stimulator', 'var') == 0
    stimulator = serialport('/dev/cu.usbmodem14301', 9600);
    flush(stimulator);
    configureTerminator(stimulator, "LF");
end


if exist('sensor', 'var') == 0
    sensor = serialport('/dev/cu.usbmodem142401', 9600);
    flush(sensor);
    sensor.UserData = struct("data",[],"count", 1);
    configureTerminator(sensor, "LF");
    configureCallback(sensor, "terminator", @readData);
    sensor_out = zeros(1, 3);
    sensor_out(1) = 1; % start flag for Arduino
    sensor_out(2) = 2500; % length of sampling in millisec
    sensor_out(3) = 100; % sampling_freq
end

if exist('stimulator', 'var') == 1
    fprintf('Arduino Uno stimulator connected on %s \n', stimulator.Port);
else
    error('Error: Arduino stimulator not connected \n');
end

% if exist('sensor', 'var') == 1
%     fprintf('Arduino Uno sensor connected on %s \n', sensor.Port);
% else
%     error('Error: Arduino sensor not connected \n');
% end

fprintf('Experiment: ERP study with TENS and Vibration \nhit enter to continue \n');

%% 1. Sensory mapping
presentation = 4; % number of presentations for each trial
duration = 2; % duration of stimulation in sec
delay = 4; % delay after stimulation in sec
freq = 10; % frequency in Hz
PW = 1; % pulse width in ms

out = zeros(1, 4);
out(1) = 1; % start flag for Arduino
out(2) = duration; % length of stimulation in sec
out(3) = freq; % frequency of the pulse in Hz
out(4) = PW; % pulse width of stimulation in ms

for j = 1:presentation
    fprintf('\n%d of %d\r', j, presentation);
    write(stimulator, out, 'single');
    pause(duration + delay);
end

fprintf('hit enter to continue to threshold detection\n');
pause;

%% 2. Threshold detection
freq = [2 14 26 38 50];
percentage = zeros(5, 1);
presentation = 10;

for i = 1:5
    out = zeros(1, 4);
    out(1) = 1; % start flag for Arduino
    out(2) = duration; % length of stimulation in sec
    out(3) = freq(i); % frequency of pulse in Hz
    out(4) = PW; % pulse width of stimulation in ms
    
    fprintf('frequency %d', i);
    pause(1);
    
    for j =1:1
        fprintf('\n%d of %d\r', j, presentation);
        write(stimulator, out, 'single');
        pause(duration);  
        % percentage(i) = percentage(i) + input('Do you feel the stimulation? 1 is No, 2 is Yes: ') - 1;
    end
    % pause(10);
end

% Save data
percentage = percentage ./ presentation;
save(strcat(folder_name, '/psychophysics.mat'), 'percentage');
[~, idx] = min(abs(percentage - 0.5));
threshold = freq(idx);
plot(freq, percentage, '-*');
fprintf('The threshold frequency is %d\n', threshold);

fprintf('hit enter to continue to Sensory feedback\n');
pause;

%% 3. Sensory feedback
freq = [threshold threshold+5 threshold+10];
forces = cell(3, presentation);
average_forces = cell(3, 1);

for i = 1:3
    out = zeros(1, 4);
    out(1) = 1; % start flag for Arduino
    out(2) = duration; % length of stimulation in sec
    out(3) = freq(i); % frequency of pulse in Hz
    out(4) = PW; % pulse width of stimulation in ms
    
    fprintf('frequency %d', i);
    pause(1);
    
    for j = 1:presentation
        fprintf('\n%d of %d\r', j, presentation);
        sensor.UserData = struct("data",[],"count", 1);
        write(stimulator, out, 'single');
        write(sensor, sensor_out, 'uint16');
        pause(duration + delay);  
        forces{i, j} = sensor.UserData.data;
    end
    pause(10);
end

figure();
hold on;
color = ['r', 'g', 'b'];
for i =1:3
    dimension = max(cellfun('length', forces(1, :)));
    average_forces{i} = zeros(1, dimension);
    for j = 1:presentation
        average_forces{i} = average_forces{i} + padarray(forces{i, j}, [0 dimension-size(forces{i,j},2)], 0, 'post');
    end
    average_forces{i} = average_forces{i} / presentation;
    plot(average_forces{i}, color(i));
end
legend('low', 'mid', 'high');

% Save data
save(strcat(folder_name, '/forces_sensory_feedback.mat'), 'forces');
save(strcat(folder_name, '/average_forces_sensory_feedback.mat'), 'average_forces');

fprintf('hit enter to continue to EEG recordings\n');
pause;

%% 4. EEG recordings
presentation = 30;
forces = cell(3, presentation);
average_forces = cell(3, 1);
% Generate random sequence of stimulation
sequence = randi(3, 2, presentation);
freq_sequence = zeros(3, presentation);
freq_sequence(1:2, :) = freq(sequence);
freq = [freq threshold+2.5 threshold+7.5 threshold+12.5];
sequence = randi(6, 1, presentation);
freq_sequence(3, :) = freq(sequence);

% Block 1
fprintf('Block 1: grip when there is a stimulation\n');
pause;
% Stimulation
for i = 1:presentation
    fprintf('%d of %d trial|\r\n', i, presentation);
    sensor.UserData = struct("data",[],"count", 1);
    out(1) = 1; % start flag for Arduino
    out(2) = duration; % length of stimulation in sec
    out(3) = freq_sequence(1, i); % frequency of pulse in Hz
    out(4) = PW; % pulse width of stimulation in ms
    write(stimulator, out);
    write(sensor, sensor_out, 'single');
    pause(duration + delay);
    forces{1, i} = sensor.UserData.data;
end
dimension = max(cellfun('length', forces(1, :)));
average_forces{1} = zeros(1, dimension);
for j = 1:presentation
    average_forces{1} = average_forces{1} + reshape(forces{1, j}, [1 dimension]);
end
average_forces{1} = average_forces{1} / presentation;

% Block 2
fprintf('Block 2: grip according to stimulation intensity\n');
pause;
% Stimulation
for i = 1:presentation
    fprintf('%d of %d trial|\r\n', i, presentation);
    sensor.UserData = struct("data",[],"count", 1);
    out(1) = 1; % start flag for Arduino
    out(2) = duration; % length of stimulation in sec
    out(3) = freq_sequence(1, i); % frequency of pulse in Hz
    out(4) = PW; % pulse width of stimulation in ms
    write(stimulator, out);
    write(sensor, sensor_out, 'single');
    pause(duration + delay);
    forces{2, i} = sensor.UserData.data;
end
dimension = max(cellfun('length', forces(2, :)));
average_forces{2} = zeros(1, dimension);
for j = 1:presentation
    average_forces{2} = average_forces{2} + reshape(forces{2, j}, [1 dimension]);
end
average_forces{2} = average_forces{2} / presentation;

% Block 3
fprintf('Block 3: grip according to stimulation intensity\n');
pause;
% Stimulation
for i = 1:presentation
    fprintf('%d of %d trial|\r\n', i, presentation);
    sensor.UserData = struct("data",[],"count", 1);
    out(1) = 1; % start flag for Arduino
    out(2) = duration; % length of stimulation in sec
    out(3) = freq_sequence(1, i); % frequency of pulse in Hz
    out(4) = PW; % pulse width of stimulation in ms
    write(stimulator, out);
    write(sensor, sensor_out, 'single');
    pause(duration + delay);
    forces{3, i} = sensor.UserData.data;
end
dimension = max(cellfun('length', forces(3, :)));
average_forces{3} = zeros(1, dimension);
for j = 1:presentation
    average_forces{3} = average_forces{3} + reshape(forces{3, j}, [1 dimension]);
end
average_forces{3} = average_forces{3} / presentation;

% Save data
save(strcat('data/', date, '/', subject_name, '/forces_EEG_recording.mat'), forces);
save(strcat('data/', date, '/', subject_name, '/average_forces_EEG_recording.mat'), average_forces);
save(strcat('data/', date, '/', subject_name, '/stimulation_EEG_recording.mat'), freq_sequence);

