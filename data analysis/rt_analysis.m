%% Parameters
folder_prefix = '/Users/ze/Documents/Thakor Lab/ERP experiment/data/';
folder_names = {
	'2021-05-28/AB03/';
	'2021-07-13/AB04/';
	};
event_type = {'B1'; 'B2'; 'B3'; 'B4'};
block = 3;
bins = 4;

%% Load data
rt_collection = {};
for k = 1:length(folder_names) 
	load(strcat(folder_prefix, folder_names{k}, 'block', num2str(block), '_rt.mat'));
	rt_collection(1:bins, end+1) = rt;
end

rt = cell(4, 1);
for i = 1:bins
	rt{i, 1} = cat(2, rt_collection{i, :});
end

%% mean and std
mean_rt = zeros(bins, 1);
std_rt = zeros(bins, 1);

for i = 1:bins
	temp = rt{i};
	mean_rt(i) = mean(temp);
	std_rt(i) = std(temp);
end
mean_rt = mean_rt * 1000;
std_rt = std_rt * 1000;

%% plot
figure();
hold on;
b = bar(mean_rt, 'FaceColor', 'flat');
b.CData(1,:) = [1 0 0];
b.CData(2,:) = [0 1 0];
b.CData(3,:) = [0 0 1];
b.CData(4,:) = [1 0 1];
set(gca, 'XTick', [1 2 3 4])
set(gca, 'XTickLabel', {'Low' 'Medium' 'High' 'Highest'});
% set(gca, 'XTick', [1 2 3])
% set(gca, 'XTickLabel', {'Low' 'Medium' 'High'});
er = errorbar(1:bins, mean_rt, std_rt);
er.Color = [0 0 0];                            
er.LineStyle = 'none'; 
hold off;
xlabel('Stim Type');
ylabel('Reaction Time (ms)');
ax = gca;
ax.FontSize = 15;

%% Linear Regression
X = [];
Y = [];
for k = 1:length(folder_names) 
	load(fullfile(folder_prefix, folder_names{k}, 'EEG_recording_stimulation.mat'));
	PW = unique(PW_sequence(block, :));
	for i = 1:bins
		Y = [Y; rt_collection{i, k}'];
		X = [X; ones(length(rt_collection{i, k}), 1)*PW(i)];
	end
end

mdl = fitlm(X,Y, 'VarNames',{'Intensity','RT'})

%% One-way ANOVA


for k = 1:length(folder_names)
	forces = forces_collection{k};
	PW_sequence = PW_collection{k};
	PW = unique(PW_sequence(block, :));
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
		y(144*(k-1)+(1:length(temp)), i) = temp;
	end
end

[p,~,stats] = anova1(y);
[results,means] = multcompare(stats,'CType','bonferroni');


%% Two-way ANOVA

rt = [cell2mat(rt1'), cell2mat(rt2')]';
block1_size = [0; cellfun('length', rt1)];
block1_order = cumsum(block1_size);
block3_size = [0; cellfun('length', rt2)];
block3_order = cumsum(block3_size) + sum(block1_size);
condition = nan(length(rt), 1);

for i = 1:3
	for j = block1_order(i)+1:block1_order(i+1)
		condition(j) = i;
	end
	for j = block3_order(i)+1:block3_order(i+1)
		condition(j) = i;
	end
end

block = nan(length(rt), 1);
block(1:sum(block1_size)) = 1;
block(sum(block1_size)+1:end) = 3;

[p,~,stats] = anovan(rt,{condition block},'model',2,'varnames',{'condition','block'});
[results,means] = multcompare(stats,'CType','bonferroni', 'Dimension',[1 2]);