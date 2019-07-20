spm_jobman('initcfg')

fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas:  Summaries & Analyses (WP 1.4)/Categories_Experiment/fMRI_Data/S%d/Functional/Sess%d/wrdata.nii'
for subID = 2:5;
for sess = 1:2;
clc
disp(input_fn)
input_fn = sprintf(fn_temp,subID,sess);
nvols = length(spm_vol(input_fn));
matlabbatch = [];
matlabbatch{1}.spm.spatial.smooth.data = arrayfun(@(x) [input_fn ',' num2str(x)],1:nvols,'UniformOutput',0)';
matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
spm_jobman('run',matlabbatch)
end
end
