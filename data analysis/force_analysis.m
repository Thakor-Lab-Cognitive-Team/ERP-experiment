%%
folder_prefix = '/Users/ze/Documents/Thakor Lab/ERP experiment/data/';
folder_names = {
	'2021-05-28/AB03/';
	'2021-07-13/AB04/';
	};


%% Psychophysics
for k = 1:length(folder_names)
	load(fullfile(folder_prefix, folder_names{k}, 'psychophysics.mat'));
	PW = [0.5 0.75 1 1.75 2];
	figure();
	plot(PW, percentage, '-*');
	xlabel('Pulse Width');
	ylabel('Percentage of Detection');
end


%% Part 3 force mapping force
forces_collection = {};

for k = 1:length(folder_names)
	load(fullfile(folder_prefix, folder_names{k}, 'sensory_feedback_average_forces.mat'));
	load(fullfile(folder_prefix, folder_names{k}, 'sensory_feedback_forces.mat'));
	S = cell(3, 1);

	figure();
	hold on;
	color = ['r', 'g', 'b'];
	for i = 1:3
		plot(0:0.01:(length(average_forces{i})-1)/100, average_forces{i}, color(i), 'LineWidth', 2);
	end


	legend('low', 'mid', 'high', 'AutoUpdate', 'off');

	for i = 1:3
		force = forces(i, :);
		emptyCells = cellfun(@isempty,force);
		force(emptyCells) = [];
		dimension = max(cellfun('length', force));
		for j = 1:length(force)
			force{j} = padarray(force{j}, [0 dimension-size(force{j},2)], 0, 'post');
		end
		force = cell2mat(force');
		S{i} = std(force);
		x = 0:0.01:(length(average_forces{i})-1)/100;
		x2 = [x, fliplr(x)];
		h = plot(x, average_forces{i}+S{i}, 'Color', color(i), 'LineWidth', 3);
		h.Color(4) = 0.1;
		inBetween = [average_forces{i}, fliplr(average_forces{i}+S{i})];
		h = fill(x2, inBetween, color(i));
		set(h,'facealpha',.1);
		h = plot(x, average_forces{i}-S{i}, 'Color', color(i), 'LineWidth', 3);
		h.Color(4) = 0.1;
		inBetween = [average_forces{i}, fliplr(average_forces{i}-S{i})];
		h = fill(x2, inBetween, color(i));
		set(h,'facealpha',.1);
	end


	xlabel('Time (s)');
	ylabel('Force (N)');
	ax = gca;
	ax.FontSize = 15;
	hold off;

	% Bar plot at 2 second

	target_forces = zeros(3, 1);
	target_variance = zeros(3, 1);
	start = 150;
	finish = 250;


	for i = 1:3
		temp = average_forces{i};
		target_forces(i) = mean(temp(start:finish));
		temp = S{i};
		target_variance(i) = mean(temp(start:finish));
	end
	figure();
	hold on;
	b = bar(target_forces, 'FaceColor', 'flat');
	b.CData(1,:) = [1 0 0];
	b.CData(2,:) = [0 1 0];
	b.CData(3,:) = [0 0 1];
	set(gca, 'XTick', [1 2 3])
	set(gca, 'XTickLabel', {'Low' 'Medium' 'High'});
	er = errorbar(1:3, target_forces, target_variance);
	er.Color = [0 0 0];                            
	er.LineStyle = 'none'; 
	hold off;
	xlabel('Stim Type');
	ylabel('Force (N)');
	ax = gca;
	ax.FontSize = 15;
end


%% One-way ANOVA

y = nan(30*length(file_names), 3);
for k = 1:length(file_names)
	for i = 1:3
		force = forces(i, :);
		emptyCells = cellfun(@isempty,force);
		force(emptyCells) = [];
		dimension = max(cellfun('length', force));
		for j = 1:length(force)
			force{j} = padarray(force{j}, [0 dimension-size(force{j},2)], 0, 'post');
		end
		force = cell2mat(force');
		temp = mean(force(:, start:finish), 2);
		y(1:length(temp), i) = temp;
	end
end

[p,~,stats] = anova1(y);
[results,means] = multcompare(stats,'CType','bonferroni');

%% Analyse Part 4 EEG recording Forces
load(fullfile(folder_name, 'EEG_recording_forces.mat'));
load(fullfile(folder_name, 'EEG_recording_sequence.mat'));
load(fullfile(folder_name, 'EEG_recording_stimulation.mat'));

block = 3;
color = ['r', 'g', 'b', 'm'];
PW = unique(PW_sequence(block, :));
if block ~=3
	average_forces = cell(3, 1);
else
	average_forces = cell(4, 1);
end
figure();
hold on;
for i = 1:length(PW)
    force = forces(block, PW_sequence(block, :) == PW(i));
	emptyCells = cellfun(@isempty,force);
	force(emptyCells) = [];
    dimension = max(cellfun('length', force(1, :)));
    average_forces{i} = zeros(1, dimension);
    for j = 1:length(force)
        average_forces{i} = average_forces{i} + padarray(force{1, j}, [0 dimension-size(force{1,j},2)], 0, 'post');
    end
    average_forces{i} = average_forces{i} / length(force);
    plot(0:0.01:(length(average_forces{i})-1)/100, average_forces{i}, color(i), 'LineWidth', 2);
end

if block ~= 3
	legend('low', 'mid', 'high', 'AutoUpdate', 'off');
	S = cell(3, 1);
else
	legend('low', 'mid', 'high', 'highest', 'AutoUpdate', 'off');
	S = cell(4, 1);
end
	

for i = 1:length(PW)
    force = forces(block, PW_sequence(block, :) == PW(i));
	emptyCells = cellfun(@isempty,force);
	force(emptyCells) = [];
	dimension = max(cellfun('length', force));
	for j = 1:length(force)
        force{j} = padarray(force{j}, [0 dimension-size(force{j},2)], 0, 'post');
    end
	force = cell2mat(force');
	S{i} = std(force);
	x = 0:0.01:(length(average_forces{i})-1)/100;
	x2 = [x, fliplr(x)];
	h = plot(x, average_forces{i}+S{i}, 'Color', color(i), 'LineWidth', 3);
	h.Color(4) = 0.1;
	inBetween = [average_forces{i}, fliplr(average_forces{i}+S{i})];
	h = fill(x2, inBetween, color(i));
	set(h,'facealpha',.1);
	h = plot(x, average_forces{i}-S{i}, 'Color', color(i), 'LineWidth', 3);
	h.Color(4) = 0.1;
	inBetween = [average_forces{i}, fliplr(average_forces{i}-S{i})];
	h = fill(x2, inBetween, color(i));
	set(h,'facealpha',.1);
end
xlabel('Time (s)');
ylabel('Force (N)');
ax = gca;
ax.FontSize = 15;
hold off;

% Bar plot at 2 second

target_forces = zeros(4, 1);
target_variance = zeros(4, 1);
start = 100;
finish = 200;


for i = 1:4
	temp = average_forces{i};
	target_forces(i) = mean(temp(start:finish));
	temp = S{i};
	target_variance(i) = mean(temp(start:finish));
end
figure();
hold on;
b = bar(target_forces, 'FaceColor', 'flat');
b.CData(1,:) = [1 0 0];
b.CData(2,:) = [0 1 0];
b.CData(3,:) = [0 0 1];
b.CData(4,:) = [1 0 1];
set(gca, 'XTick', [1 2 3 4]);
set(gca, 'XTickLabel', {'Low' 'Medium' 'High' 'Highest'});
er = errorbar(1:4, target_forces, target_variance);
er.Color = [0 0 0];                            
er.LineStyle = 'none'; 
hold off;
xlabel('Stim Type');
ylabel('Force (N)');
ax = gca;
ax.FontSize = 15;

% One-way ANOVA

start = 100;
finish = 200;

if block == 1
	y = nan(144, 3);
else
	y = nan(144, 4);
end
for i = 1:length(PW)
    force = forces(block, PW_sequence(block, :) == PW(i));
	emptyCells = cellfun(@isempty,force);
	force(emptyCells) = [];
	dimension = max(cellfun('length', force));
	for j = 1:length(force)
        force{j} = padarray(force{j}, [0 dimension-size(force{j},2)], 0, 'post');
    end
	force = cell2mat(force');
	temp = mean(force(:, start:finish), 2);
	y(1:length(temp), i) = temp;
end

[p,~,stats] = anova1(y);
[results,means] = multcompare(stats,'CType','bonferroni');