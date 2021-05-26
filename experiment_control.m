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
1. apply minumum force when there is a stimulus, disregard intensity
2. apply force when there is a stimulus with regards to discrete intensity
3. apply force when there is a stimulus with regards to continuous
intensity
%}
clc; clear;

%% Connect to arduino stimulator and sensor
subject_name = input('Enter subject name: ', 's');
% folder_name = strcat('/Users/ze/Documents/Thakor Lab/ERP
% experiment/data/', date, '/', subject_name); % Mac
folder_name = strcat('C:\Users\keqin\OneDrive\Documents\GitHub\ERP-experiment\data\', datestr(now, 'yyyy-mm-dd'), '\', subject_name); % Windows
mkdir(folder_name);

if exist('stimulator', 'var') == 0
    % stimulator = serialport('/dev/cu.usbmodem14301', 9600); % Mac
    stimulator = serialport('COM3', 9600); % Windows
    flush(stimulator);
    configureTerminator(stimulator, "LF");
end


if exist('sensor', 'var') == 0
    % sensor = serialport('/dev/cu.usbmodem142401', 9600); % Mac
    sensor = serialport('COM7', 9600);
    flush(sensor);
    sensor.UserData = struct("data",[],"count", 1);
    configureTerminator(sensor, "LF");
    configureCallback(sensor, "terminator", @readData);
    sensor_out = zeros(1, 3);
    sensor_out(1) = 1; % start flag for Arduino
    sensor_out(2) = 4000; % length of sampling in millisec, one more second than trial duration
    sensor_out(3) = 100; % sampling_freq
end

if exist('stimulator', 'var') == 1
    fprintf('Arduino Uno stimulator connected on %s \n', stimulator.Port);
else
    error('Error: Arduino stimulator not connected \n');
end

if exist('sensor', 'var') == 1
    fprintf('Arduino Uno sensor connected on %s \n', sensor.Port);
else
    error('Error: Arduino sensor not connected \n');
end

fprintf('Experiment: ERP study with TENS and Vibration \n');

%% 1. Sensory mapping
presentation = 50; % number of presentations for each trial
duration = 3; % duration of stimulation in sec
delay = 2; % delay after stimulation in sec, one less second than actual delay
freq = 2; % frequency in Hz
PW = 4.25; % pulse width in ms
jitter_max = 0.5;
jitter_min = -0.5;

out = zeros(1, 5);
out(1) = 1; % start flag for Arduino
out(2) = duration; % length of stimulation in sec
out(3) = freq; % frequency of the pulse in Hz
out(4) = PW; % pulse width of stimulation in ms
out(5) = 1; % trigger type

for j = 1:presentation
    fprintf('\n%d of %d\r', j, presentation);
    write(stimulator, out, 'single');
    jitter = (jitter_max - 0) *rand() + 0;         %add some jitter to the delay between stimulation presentations
    pause(duration + 0 + jitter);
end

fprintf('finished sensory mapping\n');

%% 2. Threshold detection
PW = [1.25 1.5 1.75 2 2.25];
percentage = zeros(5, 1);
presentation = 50;

% Generate random sequence of stimulation
sequence = randi(5, 1, presentation);
PW_sequence = PW(sequence);


for i = 1:presentation
    fprintf('\n%d of %d\r', i, presentation);
    out(1) = 1; % start flag for Arduino
    out(2) = duration; % length of stimulation in sec
    out(3) = freq; % frequency of pulse in Hz
    out(4) = PW_sequence(i); % pulse width of stimulation in ms 
    out(5) = 1; % trigger type
    write(stimulator, out, 'single');
    pause(duration);
    percentage(sequence(i)) = percentage(sequence(i)) + input('Do you feel the stimulation? 1 is No, 2 is Yes: ') - 1;
end

% Save data
for i = 1:5
    percentage(i) = percentage(i) / sum(sequence == i);
end
save(strcat(folder_name, '/psychophysics.mat'), 'percentage');
[~, idx] = min(abs(percentage - 0.5));
threshold = PW(idx);
plot(PW, percentage, '-*');
fprintf('The threshold frequency is %d\n', threshold);

fprintf('finished threshold detection\n');

%% 3. Sensory feedback
PW = [threshold threshold+1 threshold+2.25];
stim_counter = zeros(1, 3);
presentation = 30;
forces = cell(3, presentation);
average_forces = cell(3, 1);
dimension = ones(3, 1);
average_forces{1} = zeros(1, dimension(1));
average_forces{2} = zeros(1, dimension(2));
average_forces{3} = zeros(1, dimension(3));

% Generate random sequence of stimulation
sequence = randi(3, 1, presentation);
PW_sequence = PW(sequence);


color = ['r', 'g', 'b'];

for i = 1:presentation
    pointer = sequence(i);
    fprintf('\n%d of %d\r', i, presentation);
    out(1) = 1; % start flag for Arduino
    out(2) = duration; % length of stimulation in sec
    out(3) = freq; % frequency of pulse in Hz
    out(4) = PW_sequence(i); % pulse width of stimulation in ms   
    out(5) = sequence(i); % trigger type
    sensor.UserData = struct("data", [], "count", 1);
    write(sensor, sensor_out, 'uint16');
    pause(1);
    write(stimulator, out, 'single');
    jitter = (jitter_max - jitter_min) *rand() + jitter_min;         %add some jitter to the delay between stimulation presentations
    pause(duration + delay + jitter);
    stim_counter(pointer) = stim_counter(pointer) + 1;
    if isempty(sensor.UserData.data)
		sensor.UserData.data = 0;
	end
    dimension(pointer) = max([dimension(pointer), length(sensor.UserData.data)]);
    average_forces{pointer} = padarray(average_forces{pointer}, [0 dimension(pointer)-length(average_forces{pointer})], 0, 'pre');
    forces{pointer, stim_counter(pointer)} = padarray(sensor.UserData.data, ...
        [0 dimension(pointer)-length(sensor.UserData.data)], 0, 'pre');
    average_forces{pointer} = average_forces{pointer} + forces{pointer, stim_counter(pointer)};
    figure(2);
    clf(2);
    hold on;
    yline(1);
    plot(average_forces{1}./stim_counter(1), 'r');
    plot(average_forces{2}./stim_counter(2), 'g');
    plot(average_forces{3}./stim_counter(3), 'b');
    legend('threshold', 'low', 'mid', 'high', 'AutoUpdate', 'off');
	
	for j = 1:3
		force = forces(j, :);
		emptyCells = cellfun(@isempty,force);
		force(emptyCells) = [];
		for t = 1:length(force)
			force{t} = padarray(force{t}, [0 dimension(j)-size(force{t},2)], 0, 'pre');
		end
		force = cell2mat(force');
		S = std(force);
		x = 1:1:(length(average_forces{j}));
		x2 = [x, fliplr(x)];
		h = plot(x, average_forces{j}./stim_counter(j)+S, 'Color', color(j), 'LineWidth', 2);
		h.Color(4) = 0.1;
		inBetween = [average_forces{j}./stim_counter(j), fliplr(average_forces{j}./stim_counter(j)+S)];
		h = fill(x2, inBetween, color(j));
		set(h,'facealpha',.1);
		h = plot(x, average_forces{j}./stim_counter(j)-S, 'Color', color(j), 'LineWidth', 2);
		h.Color(4) = 0.1;
		inBetween = [average_forces{j}./stim_counter(j), fliplr(average_forces{j}./stim_counter(j)-S)];
		h = fill(x2, inBetween, color(j));
		set(h,'facealpha',.1);
	end
    hold off;
end

% Save data
save(strcat(folder_name, '/sensory_feedback_sequence.mat'), 'sequence');
save(strcat(folder_name, '/sensory_feedback_stimulation.mat'), 'PW_sequence');
save(strcat(folder_name, '/sensory_feedback_forces.mat'), 'forces');
save(strcat(folder_name, '/sensory_feedback_average_forces.mat'), 'average_forces');

fprintf('finished sensory feedback\n');


%% 4. EEG recordings
presentation = 120; % Must be multiples of 24
forces = cell(3, presentation);
average_forces = cell(3, 1);

% Generate pseudo-random sequence of stimulation
PW = [threshold threshold+1 threshold+2.25];
sequence = nan(3, presentation);
temp = [ones(2, presentation/6), 2*ones(2, presentation/6), 3*ones(2, presentation/6)];
temp = [temp, randi(3, 2, presentation/2)];
sequence(1, :) = temp(1, randperm(presentation));
sequence(2, :) = temp(2, randperm(presentation));
PW = [PW threshold+2.75];
temp = [ones(1, presentation/8), 2*ones(1, presentation/8), 3*ones(1, presentation/8), 4*ones(1, presentation/8)];
temp = [temp, randi(4, 1, presentation/2)];
sequence(3, :) = temp(randperm(presentation));
PW_sequence = PW(sequence);

% Create Visual fixpoint
figure('WindowState', 'fullscreen', ...
       'MenuBar', 'none', ...
       'ToolBar', 'none');
ax = axes('Units','Normalize','Position',[0 0 1 1]);
xlim([-1, 1]);
ylim([-1, 1]);
set(gca,'Color','k');
set(gca,'TickLength',[0 0])
hold on;
plot([-0.03, 0.03], [0.5, 0.5], 'w', 'LineWidth', 5);
plot([0, 0], [0.45, 0.55], 'w', 'LineWidth', 5);
hold off;

%% Block 1
fprintf('Block 1: grip when there is a stimulation\n');

% Stimulation
for i = 1:presentation
    fprintf('\n%d of %d\r', i, presentation);
    out(1) = 1; % start flag for Arduino
    out(2) = duration; % length of stimulation in sec
    out(3) = freq; % frequency of pulse in Hz
    out(4) = PW_sequence(1, i); % pulse width of stimulation in ms
    out(5) = sequence(1, i); % trigger type
    sensor.UserData = struct("data", [], "count", 1);
    write(sensor, sensor_out, 'uint16');
    pause(1);
    write(stimulator, out, 'single');
    jitter = (jitter_max - jitter_min) *rand() + jitter_min;         %add some jitter to the delay between stimulation presentations
    pause(duration + delay + jitter);
    forces{1, i} = sensor.UserData.data;
	if mod(i, 30) == 0
		% rest
		input('Please hit enter to continue: ');
	end
end

dimension = max(cellfun('length', forces(1, :)));
average_forces{1} = zeros(1, dimension);
for j = 1:presentation
    average_forces{1} = average_forces{1} + padarray(forces{1, j}, [0 dimension-size(forces{1,j},2)], 0, 'pre');
end
average_forces{1} = average_forces{1} / presentation;


%% Block 2
fprintf('Block 2: grip according to stimulation intensity\n');
% Stimulation
for i = 1:72
    fprintf('\n%d of %d\r', i, presentation);
    out(1) = 1; % start flag for Arduino
    out(2) = duration; % length of stimulation in sec
    out(3) = freq; % frequency of pulse in Hz
    out(4) = PW_sequence(2, i); % pulse width of stimulation in ms
    out(5) = sequence(2, i); % trigger type
    sensor.UserData = struct("data", [], "count", 1);
    write(sensor, sensor_out, 'uint16');
    pause(1);
    write(stimulator, out, 'single');
    jitter = (jitter_max - jitter_min) *rand() + jitter_min;         %add some jitter to the delay between stimulation presentations
    pause(duration + delay + jitter);
    forces{2, i} = sensor.UserData.data;
	if mod(i, 30) == 0
		% rest
		input('Please hit enter to continue: ');
	end
end
dimension = max(cellfun('length', forces(2, :)));
average_forces{2} = zeros(1, dimension);
for j = 1:presentation
    average_forces{2} = average_forces{2} + padarray(forces{2, j}, [0 dimension-size(forces{2,j},2)], 0, 'pre');
end
average_forces{2} = average_forces{2} / presentation;


%% Block 3
fprintf('Block 3: grip according to stimulation intensity\n');
% Stimulation
for i = 1:72
    fprintf('\n%d of %d\r', i, presentation);
    out(1) = 1; % start flag for Arduino
    out(2) = duration; % length of stimulation in sec
    out(3) = freq; % frequency of pulse in Hz
    out(4) = PW_sequence(3, i); % pulse width of stimulation in ms
    out(5) = sequence(3, i); % trigger type
    sensor.UserData = struct("data", [], "count", 1);
    write(sensor, sensor_out, 'uint16');
    pause(1);
    write(stimulator, out, 'single');
    jitter = (jitter_max - jitter_min) *rand() + jitter_min;         %add some jitter to the delay between stimulation presentations
    pause(duration + delay + jitter);
    forces{3, i} = sensor.UserData.data;
	if mod(i, 30) == 0
		% rest
		input('Please hit enter to continue: ');
	end
end
dimension = max(cellfun('length', forces(3, :)));
average_forces{3} = zeros(1, dimension);
for j = 1:presentation
    average_forces{3} = average_forces{3} + padarray(forces{3, j}, [0 dimension-size(forces{3,j},2)], 0, 'pre');
end
average_forces{3} = average_forces{3} / presentation;

%% Save data
save(strcat(folder_name, '/EEG_recording_forces.mat'), 'forces');
save(strcat(folder_name, '/EEG_recording_average_forces.mat'), 'average_forces');
save(strcat(folder_name, '/EEG_recording_stimulation.mat'), 'PW_sequence');
save(strcat(folder_name, '/EEG_recording_sequence.mat'), 'sequence');

fprintf('finished EEG recordings\n');
