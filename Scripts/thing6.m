spm_mip_ui('setcoords',[-3	-64	31])
%%

mask = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/ROI_SFS1.nii';
dt_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/RSA_searchlight/';
fls = dir([dt_temp '*avg.nii']);
fls = {fls.name}';

dt = []
for s = 1:length(fls)
  clc;disp(s)
   ds = cosmo_fmri_dataset(fullfile(dt_temp,fls{s}),'mask',mask);
   dt(s) = mean(ds.samples);    
end

[H,P,CI,STATS] = ttest(dt);
t_statement(STATS,P);