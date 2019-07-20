spm_jobman('initcfg')
tic
subvec = 1:20;
subvec([12 9]) = [];
for s = 2:length(subvec);
subID = subvec(s);
n_sess = 2;
%% fn temps
analysis_fldr_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/Analysis3'
data_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/nifti/Sess%d/s6wrdata.nii'
multicond_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/An_3B_S%d-Run%d.mat'
rp_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/nifti/Sess%d/rp_data.txt';
%%
matlabbatch = [];
analysis_fldr = sprintf(analysis_fldr_temp,subID)

if exist(analysis_fldr)==7
    delete(fullfile(analysis_fldr,'*'));
end
matlabbatch{1}.spm.stats.fmri_spec.dir = {analysis_fldr};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
%%
for sess = 1:2
data_fn = sprintf(data_fn_temp,subID,sess);
multicond_fn = sprintf(multicond_fn_temp,subID,subID,sess);
rp_fn = sprintf(rp_fn_temp,subID,sess);

if ~all(cellfun(@exist,{rp_fn multicond_fn data_fn})); error('not all files found');end

n_vols = length(spm_vol(data_fn));
sess_scans = arrayfun(@(x) [data_fn ',' num2str(x)],1:n_vols,'UniformOutput',0)';

matlabbatch{1}.spm.stats.fmri_spec.sess(sess).scans = sess_scans;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
matlabbatch{1}.spm.stats.fmri_spec.sess(sess).multi = {multicond_fn};
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).multi_reg = {rp_fn};
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).hpf = 128;
end
%%
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.9;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
%%
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
%%
spm_jobman('run',matlabbatch)
toc
end
disp('all done')
toc