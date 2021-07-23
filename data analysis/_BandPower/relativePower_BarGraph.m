%this script makes a bar graph

% close all

% load('A10_relAlpha_stats.mat');

% C1 = [580, 9.633];
% C3 = [450, 10.300];
% A3 = [0.4001, 0.5675];
% 
% C1_SEM = [47.56121283, 0.162];
% C3_SEM = [37.37046593, 0.128];
% A3_SEM = [0.0192, 0.0136];
% 
% A1_SEM = [0.1820, 0.2240];
% A2_SEM = [0.0997, 0.1262];
% A3_SEM = [0.1072, 0.0875];
% 
% p_value = [0.030, 0.00178];     %p-value 
% 
% total_acc = [C1; C3];
% total_SEM = [C1_SEM; C3_SEM];
% 
% total_TD = [C1(1), C3(1)];
% TD_SEM = [C1_SEM(1), C3_SEM(1)];
% total_nCT = [C1(2), C3(2)];
% nCT_SEM = [C1_SEM(2), C3_SEM(2)];

total_C = zeros(5,4);
total_C_sem = zeros(5,4);
C_pvalue = pCE;

for i = 1:4
    total_C(:,i) = semCE(:,1,i);
    total_C_sem(:,i) = semCE(:,2,i);
end

total_CP = zeros(5,4);
total_CP_sem = zeros(5,4);
CP_pvalue = pCPE;

for i = 1:4
    total_CP(:,i) = semCPE(:,1,i);
    total_CP_sem(:,i) = semCPE(:,2,i);
end
group = {[1,2],[1,3],[1,4],[2,3],[2,4],[3,4]};
%{
, [1,2],[1,3],[1,4],[2,3],...
    [2,4],[3,4], [1,2],[1,3],[1,4],[2,3],[2,4],[3,4], [1,2],[1,3],[1,4],...
    [2,3],[2,4],[3,4], [1,2],[1,3],[1,4],[2,3],[2,4],[3,4]};
%}
color = [0.49 0.49 0.49; 0.90 0.58 0.63; 0.64 0.08 0.18; 0.23 0.44 0.34]; 

Tick_L = 0.035;
namesC = {'C3';'C1';'Cz';'C2';'C4'};
namesCP = {'CP3';'CP1';'CPz';'CP2';'CP4'};
 %% plot absolute value difference
figure; hold on
% color = [0.23 0.44 0.34];
% abs_diff_acc = total_acc(:,2) - total_acc(:,1);
% abs_diff_SEM = (sqrt((3*total_SEM(:,1)).^2/3 + (3*total_SEM(:,2)).^2/3))/3; %calculate new SEM from diff of means
% abs_diff_SEM = sqrt(total_SEM(:,1).^2+total_SEM(:,2).^2);

% xa = [1 3];
b = bar(total_C);
%     b.LineWidth = 1;
%     b.FaceColor = 'flat';
%     for i = 1:length(total_C)
%         b.CData(i,:) = color(i,:);
%     end

for i = 1:length(b)
        b(i).FaceColor = color(i,:);
        b(i).LineWidth = 1;
        %if N is an even number, then make bar transparent (i.e. it's
        %ungrounded)

end

numgroups = size(total_C, 1);
numbars = size(total_C, 2);
groupwidth = min(0.8, numbars/(numbars+1.5));
% e = errorbar(1:4,total_C, total_C_sem, 'k', 'linestyle', 'none','LineWidth',2);

for i = 1:numbars
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      e = errorbar(x, total_C(:,i), total_C_sem(:,i), 'k', 'linestyle', 'none','LineWidth',2);
end

%add significance markers
% for i = 1:length(numgroups)
%     H=sigstar(group,C_pvalue(i,:));
%     set(H,'LineWidth',2);
% end

ax = gca;
ax.XTick = ([1 2 3 4 5]);
ax.XTickLabel = namesC;
xlabel('Electrodes');
ylim([0.17 0.4])
%     xlim([0 6.0])
ax.YTick = ([0.2 0.3 0.4]);
ylabel('Alpha Power','FontWeight','bold');
ax.TickLength = [Tick_L, Tick_L];
ax.FontSize = 18;
ax.FontWeight = 'bold';
ax.FontName = 'Myriad Pro';
ax.LineWidth = 2;
title({'A03: Central Electrodes'},'FontSize',22);
%     leg = legend('Pre-Stim','Post-Stim');
%     leg.Location = 'northwest';
%     legend boxoff
hold off;

% print('S2_PMv_TD','-dpng','-r300');
% print('C_A10_01','-dpdf','-painters');


 %% plot absolute value difference
figure; hold on
% color = [0.23 0.44 0.34];
% abs_diff_acc = total_acc(:,2) - total_acc(:,1);
% abs_diff_SEM = (sqrt((3*total_SEM(:,1)).^2/3 + (3*total_SEM(:,2)).^2/3))/3; %calculate new SEM from diff of means
% abs_diff_SEM = sqrt(total_SEM(:,1).^2+total_SEM(:,2).^2);

% xa = [1 3];
b = bar(total_CP);
%     b.LineWidth = 1;
%     b.FaceColor = 'flat';
%     for i = 1:length(total_C)
%         b.CData(i,:) = color(i,:);
%     end

for i = 1:length(b)
        b(i).FaceColor = color(i,:);
        b(i).LineWidth = 1;
        %if N is an even number, then make bar transparent (i.e. it's
        %ungrounded)

end

numgroups = size(total_CP, 1);
numbars = size(total_CP, 2);
groupwidth = min(0.8, numbars/(numbars+1.5));
% e = errorbar(1:4,total_C, total_C_sem, 'k', 'linestyle', 'none','LineWidth',2);

for i = 1:numbars
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      e = errorbar(x, total_CP(:,i), total_CP_sem(:,i), 'k', 'linestyle', 'none','LineWidth',2);
end

%add significance markers
% for i = 1:length(numgroups)
%     H=sigstar(group,C_pvalue(i,:));
%     set(H,'LineWidth',2);
% end

ax = gca;
ax.XTick = ([1 2 3 4 5]);
ax.XTickLabel = namesCP;
xlabel('Electrodes');
% ylim([0.14 0.35])
% %     xlim([0 6.0])
% ax.YTick = ([0.15 0.25 0.35]);
ylim([0.17 0.4])
%     xlim([0 6.0])
ax.YTick = ([0.2 0.3 0.4]);
ylabel('Alpha Power','FontWeight','bold');
ax.TickLength = [Tick_L, Tick_L];
ax.FontSize = 18;
ax.FontWeight = 'bold';
ax.FontName = 'Myriad Pro';
ax.LineWidth = 2;
title({'A03: Centro-Parietal Electrodes'},'FontSize',22);
%     leg = legend('Pre-Stim','Post-Stim');
%     leg.Location = 'northwest';
%     legend boxoff
hold off;
% print('CP_A10_01','-dpdf','-painters');
