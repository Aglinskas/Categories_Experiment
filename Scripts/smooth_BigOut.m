%% Smooth
tic
clc;
dr = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_2mm/BigOut/';
fls = [dir([dr 'd*_out.nii'])];
fls = {fls.name}';

for i = 1:length(fls)
clc;
disp('smoothing')
disp(i)
fn =  fullfile(dr,fls{i});
ofn =  fullfile(dr,['s' fls{i}]);

P = fn; % input
Q = ofn; % output
s = [3 3 3.6]*1; % kernel
spm_smooth(P,Q,s);
end
clc;disp('done smooothing');
%% Mean
pairs = nchoosek(1:18,2);
wh_pairs = logical(sum(~ismember(pairs,[5 18]),2)==2);

sfls = dir([dr 's*.nii']);
sfls = {sfls.name}';
for i = 1:length(sfls);
    clc;
    disp('meaning')
    disp(i)
fn = fullfile(dr,sfls{i});
ofn = fullfile(dr,['m' sfls{i}]);
ds = cosmo_fmri_dataset(fn);
ds = cosmo_slice(ds,wh_pairs);
ds.samples = mean(ds.samples);
ds.samples = ds.samples - .5;
cosmo_map2fmri(ds,ofn);
end
disp('done')
%%
ofn_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_2mm/'
matlabbatch = {};
anal_dir = 'Sanal3m';
analysis_dir = fullfile(ofn_dir,anal_dir); 
if exist(analysis_dir)==0
    mkdir(analysis_dir);
else 
    delete([analysis_dir '/*'])
end
fls = dir([dr 'm*.nii']);
fls = {fls.name}';
    
scans = cellfun(@(x) [fullfile(dr,x) ',1'],fls,'UniformOutput',0);

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
matlabbatch{3}.spm.stats.con.spmmat = {fullfile(analysis_dir,'SPM.mat')};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = '1';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 1;

delete([analysis_dir '/*']);
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);
%
SPM_fn = fullfile(analysis_dir,'SPM.mat');
load(SPM_fn)
xSPM = SPM;
    xSPM.Ic = 1;
    xSPM.k = 0;
    xSPM.Im = [];
    xSPM.pm= [];
    xSPM.u = .001;
    xSPM.thresDesc = 'none';
[hReg,xSPM,SPM] = spm_results_ui('setup',xSPM);

img = '/Users/aidasaglinskas/Documents/MATLAB/spm12/canonical/single_subj_T1.nii'
spm_sections(xSPM,hReg,img)
toc