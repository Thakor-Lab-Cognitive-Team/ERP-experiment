%% Parameters
file_path = '/Users/ze/Documents/Thakor Lab/ERP experiment/data/2021-07-13/AB04/';
file_name = 'block1_bpf0.1-30_rerefM_noEMG_elist_binsS_be_ar_icaRejected.set';
start = 232; % ms
finish = 386; % ms

%% Load dataset
EEG = pop_loadset('filename', file_name, 'filepath', file_path);

%% Initialization
start = (start / 1000 + 0.5)*EEG.srate+1;
finish = (finish / 1000+ 0.5)*EEG.srate+1;

%% Extract data from channels 
data = EEG.data();