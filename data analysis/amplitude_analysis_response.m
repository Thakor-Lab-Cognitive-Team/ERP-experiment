function [mean_vector] = amplitude_analysis_response(subjID)

 rawDataFiles = dir('*.set');
 
    loadName = rawDataFiles(subjID).name;
    dataName = loadName(1:end-4);

    EEG = pop_loadset(loadName, 'D:\Docs\Singapore\Luke Osborne\data\Processed\2nd ICA Run');
    
events=[555 1968];

%For all channels
    for ch =  1:length(EEG.chanlocs)
    
% extract current channeldata
         data = EEG.data(ch,:);

% extract time windows as in Hartley et al, 2017 (400-852ms)
% Fs =  250Hz => 1 sample = 4ms;  113 samples = 452ms

        for j = 1 : length(events)
            if events(j)<EEG.pnts -251
                windowed_data(j,:) = data((events(j)): (events(j) + 250));
            end
        end
        data_vector{ch} = windowed_data;
    
       for k = length(events)
            min_ampl(k) = abs(min(windowed_data(k,:))); % maxmimum response (min amplitude) over the 452ms window 
       end
       min_ampl_chan(ch)=mean(min_ampl);		% average the vales of the maximum response over the events
       
    end


 mean_vector{subjID} = [min_ampl_chan];