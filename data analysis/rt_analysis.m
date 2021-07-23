%% import block 1 data
eventinfo = EEG.EVENTLIST.eventinfo;
binlabel = {eventinfo.binlabel}';
time = [eventinfo.time]';

%% event type
event_type = {'B1'; 'B2'; 'B3'; 'B4'};

%% calculate reaction time for each stim type
bins = 4;
rt2 = cell(bins, 1);

for i = 1:length(time)
	if ~isequal(binlabel{i}, '""')
		for j = 1:bins
			if contains(binlabel{i}, event_type{j})
				rt2{j}(end+1) = time(i+1) - time(i);
				break;
			end
		end
	end
end

%% mean and std
mean_rt = zeros(bins, 1);
std_rt = zeros(bins, 1);

for i = 1:bins
	temp = rt2{i};
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