%% Block 1
figure();
hold on;
b = bar(Amp', 'FaceColor', 'flat');
for i = 1:3
	b(1).CData(i,:) = [1 0 0];
	b(2).CData(i,:) = [0 1 0];
	b(3).CData(i,:) = [0 0 1];
end
set(gca, 'XTick', [1 2 3])
set(gca, 'XTickLabel', {'CZ' 'CPZ' 'PZ'});
hold off;
xlabel('Location');
ylabel('Area (uV*ms)');
legend('Low', 'Medium', 'High');
ylim([0, 1.5]);
ax = gca;
ax.FontSize = 15;


%% Block 2 & 3
figure();
hold on;
b = bar(Amp', 'FaceColor', 'flat');
for i = 1:3
	b(1).CData(i,:) = [1 0 0];
	b(2).CData(i,:) = [0 1 0];
	b(3).CData(i,:) = [0 0 1];
	b(4).CData(i,:) = [1 0 1];
end
set(gca, 'XTick', [1 2 3])
set(gca, 'XTickLabel', {'CZ' 'CPZ' 'PZ'});
hold off;
xlabel('Location');
ylabel('Area (uV*ms)');
legend('Low', 'Medium', 'High', 'Highest');
ylim([0, 1.5]);
ax = gca;
ax.FontSize = 15;