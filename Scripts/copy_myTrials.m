my_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas:  Summaries & Analyses (WP 1.4)/Categories_Experiment/fMRI_Data/RAW_onsets_no_touch/S%.2d_P1_myTrials.mat';
dest_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas:  Summaries & Analyses (WP 1.4)/Categories_Experiment/fMRI_Data/S%d/S%.2d_P1_myTrials.mat';
subvect = 1:20;subvect(12) = [];
for subID = subvect
my_fn = sprintf(my_fn_temp,subID);
dest_fn = sprintf(dest_fn_temp,subID,subID);
copyfile(my_fn,dest_fn)
end