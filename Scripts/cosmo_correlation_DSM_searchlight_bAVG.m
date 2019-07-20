%% All Scans
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/all_scans_3mm_18s.mat');
all_scans_raw = all_scans;
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
model = 1-wikiClust.cmat;
%add_numbers_to_mat(model,wikiClust.lbls)

% REMEMBER TO CHANGE .cond_index mapping
change_all_scans

all_scans = cosmo_slice(all_scans,~isnan(all_scans.sa.cond_index2)); % drop leisure
all_scans = cosmo_slice(all_scans,~(all_scans.sa.cond_index==18)); % 
svec = unique(all_scans.sa.subID)';
%% Define Parameters

opt.radius = 2;
nbrhood=cosmo_spherical_neighborhood(all_scans, 'radius',2)

args.target_dsm = get_triu(model);
args.metric = 'Correlation'
args.type = 'Pearson'
args.center_data = 1;
measure = @cosmo_target_dsm_corr_measure;
%% 
for s_ind = 1:18;
tic
samples = [];
CCsamples = [];

for b_ind = 1:3
    clc; disp([s_ind b_ind])
this_DS = cosmo_slice(all_scans,all_scans.sa.subID==svec(s_ind));
this_DS = cosmo_slice(this_DS,this_DS.sa.b_ind==b_ind);
this_DS.sa.targets = this_DS.sa.cond_index2;


end



results_map = cosmo_searchlight(this_DS, nbrhood, measure,args)

ofn_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/RSA_searchlight_CC/';
save(fullfile(ofn_dir,sprintf('%d.mat',s_ind)),'this_DS','results_map');
cosmo_map2fmri(results_map,fullfile(ofn_dir,sprintf('%d.nii',s_ind)));
end % ends sub
toc
%%
matlabbatch = {};
anal_dir = 'anal';
analysis_dir = fullfile(ofn_dir,anal_dir); 
if exist(analysis_dir)==0
    mkdir(analysis_dir);
else 
    delete([analysis_dir '/*'])
end
    fls = dir([ofn_dir '*.nii']);
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