%% Load The data 
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/all_scans_3mm_18s.mat')
%load('/Users/aidasaglinskas/Google Drive/Aida s/Categories_Experiment/all_scans.mat')
ofn_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_2mm/';
%% Searchlight parameters / Set up 
if ~exist(ofn_dir);mkdir(ofn_dir);end
subID = 1;
slice_inds = all_scans.sa.subID==subID & ismember(all_scans.sa.cond_index,[1 2]);
ds = cosmo_slice(all_scans,slice_inds);

%nvoxels_per_searchlight= 2;
%nbrhood=cosmo_spherical_neighborhood(ds,'count',nvoxels_per_searchlight);
nbrhood=cosmo_spherical_neighborhood(ds,'radius',2);
measure=@cosmo_crossvalidation_measure;
measure_args=struct();
measure_args.partitions=cosmo_nfold_partitioner(ds.sa.b_ind);
measure_args.classifier=@cosmo_classify_lda;
%conds = find(~ismember(1:18,[5 18]))% ignore leisure, control condition
conds = 1:18;
pairs = nchoosek(conds,2);
svec = unique(all_scans.sa.subID);
%% Actual, Time Consuming Loop
for subID = svec(1:end)';
tic
for p_ind = 1:length(pairs)
clc;
disp([subID p_ind]);
%slice_inds = all_scans.sa.subID==subID & ismember(all_scans.sa.cond_index,find(~ismember([1:18],[5 18])));
slice_inds = all_scans.sa.subID==subID & ismember(all_scans.sa.cond_index,pairs(p_ind,:));
ds = cosmo_slice(all_scans,slice_inds);
ds.sa.targets = ds.sa.cond_index;
ds.sa.chunks = ds.sa.b_ind;
 
ds_cfy=cosmo_searchlight(ds,nbrhood,measure,measure_args,'nproc',2);
%ds_cfy=cosmo_searchlight(ds,nbrhood,measure,measure_args);
toc

if p_ind == 1;subDS = ds_cfy;else;subDS = cosmo_stack({subDS ds_cfy});end

end % ends pair loop
toc
ofn_fn_mat = [num2str(subID) '.mat'];
save(fullfile(ofn_dir,ofn_fn_mat));
end % ends sub loop
% f = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_norm/test.nii'
% cosmo_map2fmri(subDS,f)
% %% Subtract Chance, Smooth
% for i = find([1:20]~=12);
% fn = fullfile(ofn_dir,[num2str(i) '.nii']);
% dt = load_nii(fn);
% dt.img = dt.img - chance;
% ofnc = fullfile(ofn_dir,['c' num2str(i) '.nii']);
% ofns = fullfile(ofn_dir,['sc' num2str(i) '.nii']);
% save_nii(dt,ofnc);
% spm_smooth(ofnc,ofns,[6 6 6])
% end
%% Save big nii's 
mat_fn_temp = '%d.mat';
for subID = svec'
mat_fn = sprintf(mat_fn_temp,subID);
subDS = [];
load(fullfile(ofn_dir,mat_fn))

ofn_temp = fullfile(ofn_dir,'BigOut','%d_out.nii');
ofn = sprintf(ofn_temp,subID);
cosmo_map2fmri(subDS,ofn)
end
%%
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat');
mat_fn_temp = '%d.mat';
ofn_nii_fn_temp = '%d_AvT.nii';
ofn_nii_fn_temp_smooth = '%dms.nii';

% drop_tasks = {'Leisure' 'control task'};
% wh_tasks = sum(~ismember(pairs,find(ismember(tlbls,drop_tasks))),2)==2;
% wh_tasks = sum(pairs==18,2) & sum(pairs~=5,2)==2;


clust{1} = { 'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials'};
clust{2} = {'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds'};

inds{1} = find(ismember(tlbls,clust{1}));
inds{2} = find(ismember(tlbls,clust{2}));

slice_inds = (ismember(pairs(:,1),inds{1}) & ismember(pairs(:,2),inds{2})) | (ismember(pairs(:,1),inds{2}) & ismember(pairs(:,2),inds{1}));
wh_tasks = slice_inds;

for subID = svec'
    clc;disp(subID);
mat_fn = sprintf(mat_fn_temp,subID);
chance = .5;

load(fullfile(ofn_dir,mat_fn))

subDS = cosmo_slice(subDS,wh_tasks);
subDS.samples = subDS.samples - chance;
subDS.samples = mean(subDS.samples);
subDS.sa.labels = subDS.sa.labels(1);
ofn = fullfile(ofn_dir,sprintf(ofn_nii_fn_temp,subID));
ofns = fullfile(ofn_dir,sprintf(ofn_nii_fn_temp_smooth,subID));
cosmo_map2fmri(subDS,ofn);
%spm_smooth(ofn,ofns,[6 6 6]);
end
disp('done')
%% Smooth
matlabbatch = {};
anal_dir = 'analAvT';
analysis_dir = fullfile(ofn_dir,anal_dir); 
if exist(analysis_dir)==0
    mkdir(analysis_dir);
else 
    delete([analysis_dir '/*'])
end
    fls = dir([ofn_dir '*_AvT.nii']);
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
delete([analysis_dir '/*']);
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);
%%

load([analysis_dir '/SPM.mat'])

xSPM = SPM;
xSPM.Ic=1;
xSPM.Im=0;
xSPM.Ex=0;
xSPM.Im=[];
xSPM.title='singleSubROI';
xSPM.thresDesc='none';
xSPM.u= .001;
xSPM.k= 15;

[hReg,xSPM,SPM] = spm_results_ui('Setup',[xSPM])
img = '/Users/aidasaglinskas/Documents/MATLAB/spm12/canonical/single_subj_T1.nii';
spm_sections(xSPM,hReg,img)
