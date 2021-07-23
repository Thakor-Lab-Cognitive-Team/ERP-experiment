%% Parameters
folder_name = '/Users/ze/Documents/Thakor Lab/ERP experiment/data/2021-07-13/AB04/';
event_type = {'B1'; 'B2'; 'B3'; 'B4'};
block = 3;
bins = 4;

%% import data
eventinfo = EEG.EVENTLIST.eventinfo;
binlabel = {eventinfo.binlabel}';
time = [eventinfo.time]';


%% calculate reaction time for each stim type
rt = cell(bins, 1);

for i = 1:length(time)
	if ~isequal(binlabel{i}, '""')
		for j = 1:bins
			if contains(binlabel{i}, event_type{j})
				rt{j}(end+1) = time(i+1) - time(i);
				break;
			end
		end
	end
end

%% Store data
save(strcat(folder_name, 'block', num2str(block), '_rt.mat'), 'rt');