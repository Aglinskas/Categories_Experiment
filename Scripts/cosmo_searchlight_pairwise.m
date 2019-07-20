%% Load The data 
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/mats/all_scans.mat');
%% Searchlight parameters
ofn_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_pair/';
if ~exist(ofn_dir);mkdir(ofn_dir);end
subID = 1;
slice_inds = all_scans.sa.subID==subID & ismember(all_scans.sa.cond_index,[1 2]);
ds = cosmo_slice(all_scans,slice_inds);

nvoxels_per_searchlight=100;
nbrhood=cosmo_spherical_neighborhood(ds,'count',nvoxels_per_searchlight);
measure=@cosmo_crossvalidation_measure;
measure_args=struct();
measure_args.partitions=cosmo_nfold_partitioner(ds.sa.b_ind);
measure_args.classifier=@cosmo_classify_lda;

conds = find([1:17]~=5);
pairs = nchoosek(conds,2);
%% Actual, Time Consuming Loop
for subID = 1;
for p_ind = 2:length(pairs)
%slice_inds = all_scans.sa.subID==subID & ismember(all_scans.sa.cond_index,find(~ismember([1:18],[5 18])));
disp([subID pairs(p_ind,:)])
tic
slice_inds = all_scans.sa.subID==subID & ismember(all_scans.sa.cond_index,pairs(p_ind,:));
ds = cosmo_slice(all_scans,slice_inds);
ds.sa.targets = ds.sa.cond_index;
ds.sa.chunks = ds.sa.b_ind;
ds_cfy=cosmo_searchlight(ds,nbrhood,measure,measure_args,'nproc',2);
toc
%ofn_nm = ['S' num2str(subID) '_' num2str(pairs(p_ind,1)) num2str(pairs(p_ind,2)) '.nii'];
end

if p_ind==1;
    subDS = ds_cfy;
else
    subDS = cosmo_stack({subDS ds_cfy});
end

ofn_nm = ['S' num2str(subID) '.nii'];
cosmo_map2fmri(subDS,fullfile(ofn_dir,ofn_nm));
end
%% Subtract Chance, Smooth
%fls = dir([ofn_dir '*.nii']);
%fls = {fls.name}';
chance = 1/16;
for i = find([1:20]~=12);
fn = fullfile(ofn_dir,[num2str(i) '.nii']);
dt = load_nii(fn);
dt.img = dt.img - chance;
ofnc = fullfile(ofn_dir,['c' num2str(i) '.nii']);
ofns = fullfile(ofn_dir,['sc' num2str(i) '.nii']);
save_nii(dt,ofnc);
spm_smooth(ofnc,ofns,[6 6 6])
end
%%
matlabbatch = {};
analysis_dir = ['/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way/anal/'];
    fls = dir([ofn_dir 'sc*.nii']);
    fls = {fls.name}';
scans = cellfun(@(x) [fullfile(ofn_dir,x) ',1'],fls,'UniformOutput',0);

matlabbatch{1}.spm.stats.factorial_design.dir = {analysis_dir};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = scans;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
%%
delete([analysis_dir '*']);
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);
%%

