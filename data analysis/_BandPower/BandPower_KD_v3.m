% 111520

%close all
% clear all
% clc
band = {'Delta' 'Theta' 'Alpha' 'Beta' 'Gamma'};
fileNames = string(); idx = 1; 
s1 = 'ica.set';
subjectid = input('Enter subject ID:  ');
if subjectid == 4
    for flag = [6 7 9]
        for i = 1:2
            fileNames(idx+i-1) = sprintf('%d_%d_%s', flag, i, s1);
        end
        idx = idx +2;
    end
elseif subjectid == 10    
    for flag = [2 3]
        for i = 1:3
            fileNames(idx+i-1) = sprintf('%d_%d_%s', flag, i, s1);
        end
        idx = idx +3;
    end
end
% fpath = '/Users/kqding/Desktop/LAB/PowerAnalysis/BandPower/';
% fpath = '/Volumes/kding/LAB/PowerAnalysis/A4_PSD/';
% fpath = sprintf('/Users/kqding/Desktop/PowerAnalysis/A%d_PSD/',subjectid);
fpath = sprintf('/C:\Users\Ze\Desktop\Research\Thakor Lab\_BandPower\A10_PSD');
CAlpha=zeros(60,4,5);
CPAlpha=zeros(60,4,5);
%% Check conditions to specify data folder name

%These conditions are for experiment stages 2, 3, 4, where each stim
%condition has 2 trials
condition = input('Enter condition number (1-Pre_Stim, 2-StimNoMove, 3-StimMove, 4-PostStim): ');
if condition == 1
    stage = 'Pre_Stimulation-Movement/';
elseif condition == 2
    stage = 'Stimulation-NoMovements/';
elseif condition == 3
    stage = 'Stimulation-Movements/';
elseif condition == 4
    stage = 'Post Stimulation-Movement/';
else
    error('Error: Condition not correctly identified')
end



% m = 1; %stage 1 A04
%band power calculation for each condition each trial
idx = 0; %idx = n-1
for n = 1:6
%     
% for flag = [6 7 9] % stimulation stage 1
%    flag
    % stimulation stage 1
%     EEG=pop_loadset(strcat('/Users/kqding/Desktop/LAB/PowerAnalysis/BandPower/Pre_Stimulation-Movement/',num2str(flag),'_ica.set'));
%     EEG=pop_loadset(strcat(fpath,stage,num2str(flag),'_ica.set'));
    
    % stimulation stage 2,3,4
    fname = strcat(fpath,stage,char(fileNames(n)));
    EEG=pop_loadset(char(fname));
    
    winlen=0.25; %window length
    SR=500; %sampling rate
    
    FreqBand=[1 4; 4 8; 8 12; 12 30; 30 40];
    BandName={'Delta','Theta','Alpha','Beta','Gamma','RelativeDelta','RelativeTheta','RelativeAlpha','RelativeBeta','RelativeGamma'};

    data1 = EEG.data(1:62,725:925,:); %channel*datapoint*epoch
    data1 = double(data1);
    
    % data1(:,:,[bad_epochs(abc,:)==1])=[];
    for i=1:size(data1,3)
        data=data1(:,:,i);
        [Spectra,F,T]=getspectralpower(double(data),winlen*SR,0,winlen*SR,SR);%chan*freq*time
        [nc,nf,nt]=size(Spectra); %spectra is power
        bandnum=size(FreqBand,1);
        
        for c=1:nc
            for b=1:bandnum
                %chan*band*time
                BandPower(c,b,:)= squeeze(mean(Spectra(c,F>=FreqBand(b,1) & F<=FreqBand(b,2),:),2));
%                 BandPower(c,b,:)= squeeze(max(Spectra(c,F>=FreqBand(b,1) & F<=FreqBand(b,2),:),[],2));
            end
        end
        %power sum
        BandPowerSum=sum(BandPower,2);
        
        %Relative power
        for c=1:nc
            ind=6;
            for b=1:5
                BandPower(c,ind,:)=BandPower(c,b,:)./BandPowerSum(c,1,:);
                ind=ind+1;
            end
        end
        
        A = idx*10 + i; %marker for idx*10 + i
        
        C = [26:30]; %channel number
        CP = [35:39]; %channel number
        for j = 1:5 %take the alpha band out for these channels
            CAlpha(A,condition,j) = BandPower(C(j),8); 
            CPAlpha(A,condition,j) = BandPower(CP(j),8);
        end
        
%         BandPowerAvg1(:,:,i,m)=squeeze(mean(BandPower,3)); %For stage 1
        BandPowerAvg1(:,:,i,n,condition)=squeeze(mean(BandPower,3)); %For stage 2-4
    end
%     m = m+1; %stage 1
    idx = idx +1;
end
%BandPowerAvgDB=pow2db(BandPowerAvg1);
%% PLOTS
% Overall plot
% totalBPAvg1 = mean(BandPowerAvg1,4);
% totalBPAvg = mean(totalBPAvg1,3);

%chanlocs(64) = [];
%chanlocs(63) = [];

chanlocs = EEG.chanlocs;

% to plot PSD trial wise
totalBPAvg1 = mean(BandPowerAvg1, 3);
totalBPAvg = squeeze(totalBPAvg1);

% figure
% for i = 1:6
%     subplot(2,3,i)
%     topoplot(totalBPAvg(:,8,i), chanlocs, 'maplimits','maxmin');
%     caxis([0.09 0.31])
%     colorbar
%     title(sprintf('Trial %d',i));
% end
% print('A10_cond1_trial','-dpdf','-painters');

% plot PSD epoch wise
for cond = 1:4
    for i = 1:6
        h = figure('position',[0 600 1400 800])%, 'Visible','Off')
        for j = 1:10
            subplot(2,5,j)
            topoplot(BandPowerAvg1(:,8,j,i,cond), chanlocs, 'maplimits','maxmin');
            caxis([0 0.5])
            colorbar
            title(sprintf('Epoch %d',j));
        end
        print(h, strcat(fpath,sprintf('Cond_%d_Trial%d_A10',cond,i)),'-dpng','-r300');
    end
end

%{
% figure
% suptitle('Power Plot: Pre\_Stimulation-Movement')
% suptitle('Power Plot: Stimulation No Movements')
% suptitle('Power Plot: Stimulation Movements')
% suptitle('Power Plot: Post Stimulation Movements')
% for i = 1:5
%     subplot(2,3,i)
%     topoplot(totalBPAvg(:,i), chanlocs,'maplimits','maxmin');
%     caxis([300 3e5])
%     colorbar
%     title(sprintf('%s',BandName{i}));
% end
%saveas(gcf, '/Users/kqding/Desktop/LAB/PowerAnalysis/pre_stim_move.png');
%saveas(gcf, '/Users/kqding/Desktop/LAB/PowerAnalysis/stim_noMove.png');
%saveas(gcf, '/Users/kqding/Desktop/LAB/PowerAnalysis/stim_move.png');
%saveas(gcf, '/Users/kqding/Desktop/LAB/PowerAnalysis/postStim_move.png');
%}

% % figure
%suptitle('Relative Power Plot: Pre\_Stimulation-Movement')
%suptitle('Relative Power Plot: Stimulation No Movements')
% suptitle('Relative Power Plot: Stimulation Movements')
%suptitle('Relative Power Plot: Post Stimulation Movements')
% for i = 6:10
%     subplot(2,3,i-5)
% %     topoplot(totalBPAvg(:,8), chanlocs,'maplimits','maxmin');
%     caxis([0.18 0.35]) 
% %     caxis([0.14 0.31]) 
% %     colorbar
%     title(sprintf('%s',BandName{8}));
% end
% print('A10_cond3_colorbar','-dpdf','-painters');
%saveas(gcf, '/Users/kqding/Desktop/LAB/PowerAnalysis/R_pre_stim_move.png');
%saveas(gcf, '/Users/kqding/Desktop/LAB/PowerAnalysis/R_stim_noMove.png');
%saveas(gcf, '/Users/kqding/Desktop/LAB/PowerAnalysis/R_stim_move.png');
%saveas(gcf, '/Users/kqding/Desktop/LAB/PowerAnalysis/R_postStim_move.png');

%% Plot movement specific power
%{
mBPAvg = zeros(62,10,3); move = 1;
for i = [1 3 5]
    x_i = mean(BandPowerAvg1(:,:,:,i:i+1),4);
    mBPAvg(:,:,move) = mean(x_i,3);
    move = move + 1;
end


mBPAvg = BandPowerAvg1;

figure
%suptitle('Relative Alpha Power, Movement Specific: Pre\_Stimulation-Movement')
%suptitle('Relative Alpha Power, Movement Specific: Stimulation No Movements')
%suptitle('Relative Alpha Power, Movement Specific: Stimulation Movements')
%suptitle('Relative Alpha Power, Movement Specific: Post Stimulation Movements')
for i = 1:3
    subplot(1,3,i)
    topoplot(mBPAvg(:,8,i), chanlocs,'maplimits','maxmin');
    %caxis([0 0.5]) 
    caxis([0.18 0.4]) 
    colorbar
    if i == 1
        movement = 6;
    elseif i == 2
        movement = 7;
    elseif i == 3
        movement =9;
    end
    title(sprintf('Grip: %d',movement));
end
%saveas(gcf, '/Users/kqding/Desktop/LAB/PowerAnalysis/M_pre_stim_move.png');
%saveas(gcf, '/Users/kqding/Desktop/LAB/PowerAnalysis/M_stim_noMove.png');
%saveas(gcf, '/Users/kqding/Desktop/LAB/PowerAnalysis/M_stim_move.png');
%saveas(gcf, '/Users/kqding/Desktop/LAB/PowerAnalysis/M_postStim_move.png');


%}

%% ANOVA
C3 = CAlpha(:,:,1);
C1 = CAlpha(:,:,2);
Cz = CAlpha(:,:,3);
C2 = CAlpha(:,:,4);
C4 = CAlpha(:,:,5);

CP3 = CPAlpha(:,:,1);
CP1 = CPAlpha(:,:,2);
CPz = CPAlpha(:,:,3);
CP2 = CPAlpha(:,:,4);
CP4 = CPAlpha(:,:,5);

[~,~,C3stats] = anova1(C3,1:4,'off');
[cC3, semC3] = multcompare(C3stats, 'Display','off');
[~,~,C1stats] = anova1(C1,1:4,'off');
[cC1, semC1] = multcompare(C1stats, 'Display','off');
[~,~,Czstats] = anova1(Cz,1:4,'off');
[cCz, semCz] = multcompare(Czstats, 'Display','off');
[~,~,C2stats] = anova1(C2,1:4,'off');
[cC2,semC2] = multcompare(C2stats, 'Display','off');
[~,~,C4stats] = anova1(C4,1:4,'off');
[cC4, semC4] = multcompare(C4stats, 'Display','off');
pCE = [cC3(:,6)'; cC1(:,6)'; cCz(:,6)'; cC2(:,6)'; cC4(:,6)'];


[~,~,CP3stats] = anova1(CP3,1:4,'off');
[cCP3, semCP3] = multcompare(CP3stats, 'Display','off');
[~,~,CP1stats] = anova1(CP1,1:4,'off');
[cCP1, semCP1] = multcompare(CP1stats, 'Display','off');
[~,~,CPzstats] = anova1(CPz,1:4,'off');
[cCPz, semCPz] = multcompare(CPzstats, 'Display','off');
[~,~,CP2stats] = anova1(CP2,1:4,'off');
[cCP2, semCP2] = multcompare(CP2stats, 'Display','off');
[~,~,CP4stats] = anova1(CP4,1:4,'off');
[cCP4, semCP4] = multcompare(CP4stats, 'Display','off');
pCPE = [cCP3(:,6)'; cCP1(:,6)'; cCPz(:,6)'; cCP2(:,6)'; cCP4(:,6)'];


semCE = zeros(5,2,4);
semCPE = zeros(5,2,4);

for i = 1:5
    for k = 1:4
        [semCE(i,1,k),semCE(i,2,k)] = SEM(CAlpha(:,k,i));
        [semCPE(i,1,k),semCPE(i,2,k)] = SEM(CPAlpha(:,k,i));
    end
end

