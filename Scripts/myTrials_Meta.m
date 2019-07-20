myTrials_dir = '/Users/aidasaglinskas/Google Drive/Aidas:  Summaries & Analyses (WP 1.4)/Categories_Experiment/fMRI_Data/RAW_onsets_no_touch'
%%

fls = dir([myTrials_dir '/*wrkpsc.mat']);
fls = {fls.name}'
clc
a = {};
for i = 1:length(fls)
   myTrials_fn = fullfile(myTrials_dir,fls{i});
   exp_ended = [];
   load(myTrials_fn,'exp_Began','myTrials');
   a{i,1} = fls{i};
   a{i,2} = datestr(exp_Began);
   
   temp = dir(myTrials_fn);
   a{i,3} = length([myTrials.time_presented]);
end

T = cell2table(a)