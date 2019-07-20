%% Smooth Masks
roi_input_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/';
roi_output_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/smoothedROIs/';
fls = dir([roi_input_dir '*.nii']);
fls = {fls.name}'

for r = 1:length(fls)
    in_fn = fullfile(roi_input_dir,fls{r});
    out_fn = fullfile(roi_output_dir,['s' fls{r}]);
    P = in_fn;
    Q = out_fn;
   spm_smooth(P,Q,[12 12 12],0) 
   
   dt = load_nii(Q);
   dt.img(dt.img(:)>=.1) = 1;
   dt.img(dt.img(:)<.1) = 0;
   if r == 1;
       adt = dt
   else
       adt.img(:,:,:,r) = dt.img;
   end
   save_nii(dt,Q)
end

sum(adt.img(:))

adt.img = sum(adt.img,4);
adt.img(adt.img(:)>=1) = 1;
%adt.img(adt.img(:)<.9) = 0;
save_nii(adt,fullfile(roi_output_dir,'combRoi.nii'));
tabulate(adt.img(:));
%% Stack Scans 
all_scans = []

mask_fn = fullfile(roi_output_dir,'combRoi.nii')

load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/mats/cat_names.mat');
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat')
cat_lbls = [cat_names tlbls'];
subvec = 1:20;
subvec([9 12]) = [];
all_scans = [];
spm_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/Analysis3/';

for s = 1:length(subvec);
    subID = subvec(s);
    spm_fn = [sprintf(spm_fn_temp,subID)];
    SPM = [];load([spm_fn 'SPM.mat']);
    if isempty(SPM);error('no SPM');end
    for cat_ind = 1:18;
        inds = find(~cellfun(@isempty,strfind({SPM.Vbeta.descrip}',cat_lbls{cat_ind,1})));
        if length(inds) ~= 3;error('not 3 betas');end
        for b_ind = 1:3; 
            
            clc
            disp(sprintf('S:%d/%d, C:%d/%d, B:%d/%d',s,length(subvec),cat_ind,18,b_ind,3));
            disp(all_scans)
            
            wh = inds(b_ind);
            descrip = SPM.Vbeta(wh).descrip;
            fn = SPM.Vbeta(wh).fname;
            % Gets run index
            tag = ' - Sn(';
            pos = strfind(descrip,tag)+length(tag);
            run_ind = str2num(descrip(pos)); if isempty(run_ind);error('error retrieving run ind');end
            
            data_fn = fullfile(spm_fn,fn);
            
            ds = cosmo_fmri_dataset(data_fn,'mask',mask_fn);
            
            ds.sa.descrip = {descrip};
            ds.sa.subID = subID;
            ds.sa.b_ind = b_ind;
            ds.sa.cond_index = cat_ind;
            ds.sa.run_ind = run_ind;
            ds.sa.cond_lbl_it = cat_lbls(cat_ind,1);
            ds.sa.cond_lbl_en = cat_lbls(cat_ind,2);
            
            if isempty(all_scans);
                all_scans = ds;
            else
                all_scans = cosmo_stack({all_scans ds});
            end
            
        end
    end
end
all_scans = cosmo_remove_useless_data(all_scans);
%%
ofn_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/RDMsForElisa/'
%% Searchlight parameters / Set up 
if ~exist(ofn_dir);mkdir(ofn_dir);end
subID = 1;
slice_inds = all_scans.sa.subID==subID & ismember(all_scans.sa.cond_index,[1 2]);
ds = cosmo_slice(all_scans,slice_inds);

nbrhood=cosmo_spherical_neighborhood(ds,'radius',2);

conds = 1:18;
pairs = nchoosek(conds,2);
svec = unique(all_scans.sa.subID);
%% Actual, Time Consuming Loop
tic
for s = 1:length(svec);
subID = svec(s);

subDS = [];
for p_ind = 1:length(pairs)
clc;
disp(sprintf('%d/%d pair: %d/%d',s,length(svec),p_ind,length(pairs)));
toc
bres = nan(3,size(all_scans.samples,2));
for b_ind = 1:3
slice_inds = (all_scans.sa.subID==subID) & (ismember(all_scans.sa.cond_index,pairs(p_ind,:))) & (all_scans.sa.b_ind == b_ind);
ds = cosmo_slice(all_scans,slice_inds);
    res_ds = cosmo_slice(ds,1);
    res_ds.samples = [];
    res_ds.sa = [];
    res_ds.sa.pair = pairs(p_ind,:);
    res_ds.sa.sub = subID;

neighbors=nbrhood.neighbors;
ncenters=numel(nbrhood.neighbors);
for center_id=1:ncenters;
    
neighbor_feature_ids=neighbors{center_id};
sphere_ds=cosmo_slice(ds, neighbor_feature_ids,2,1);

sphere_ds.samples = sphere_ds.samples - mean(sphere_ds.samples,2);

c = corr(sphere_ds.samples(1,:)',sphere_ds.samples(2,:)');
bres(b_ind,center_id) = c;
end % ends centers
 
 
end  %ends beta
    if any(isnan(bres(:)));error('nans');end
    
res_ds.samples = mean(bres);

if p_ind == 1
subDS = res_ds;
else
    subDS = cosmo_stack({subDS res_ds});
end

end % ends sub loop

save([ofn_dir sprintf('%d.mat',s)],'subDS');
cosmo_map2fmri(subDS,[ofn_dir sprintf('%d.nii',s)]);
end %ends sub
%% Extract
out_fls = dir([ofn_dir '*.nii']);
out_fls = {out_fls.name}';

disp('extracting')
for s = 1:length(out_fls);
for r = 1:length(fls);
    clc;disp([s r]);
dt_fn = fullfile(ofn_dir,out_fls{s});
mask_fn = fullfile(roi_input_dir,fls{r});
ds = cosmo_fmri_dataset(dt_fn,'mask',mask_fn);

for p = 1:length(pairs)
    cmat(pairs(p,1),pairs(p,2),r,s) = mean(ds.samples(p,:));
    cmat(pairs(p,2),pairs(p,1),r,s) = mean(ds.samples(p,:));
end

end
end
disp('done')
cmat_raw = cmat;
save('/Users/aidasaglinskas/Desktop/cmat_elisa.mat','cmat','fls')
%% Singnle RDMs
load('/Users/aidasaglinskas/Desktop/cmat_elisa.mat')
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat')
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
model = wikiClust.cmat;
drop = [5 18];
tlbls(drop) = [];
cmat(drop,:,:,:) = [];
cmat(:,drop,:,:) = [];

rlbls = fls;
rlbls = strrep(rlbls,'ROI_','');
rlbls = strrep(rlbls,'.nii','');
r = 1;

figure(1)
mc2d = mean(cmat(:,:,r,:),4);
mc3d = squeeze(cmat(:,:,r,:));

func_plot_dendMat(mc2d,tlbls);
%func_plot_dendMat(model,tlbls);
%%
model_ev = func_fit_RSA_model(mc3d,model);
[H,P,CI,STATS] = ttest(model_ev);

title({rlbls{r} t_statement(STATS,P)},'fontsize',20)
%% Bar Plot
clf
dt = [];
for r = 1:length(rlbls)
   dt(:,r) = func_fit_RSA_model(squeeze(cmat(:,:,r,:)),model);
   %[H,P,CI,STATS] = ttest(
end
func_plot_tbar_plot(dt,rlbls)
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
