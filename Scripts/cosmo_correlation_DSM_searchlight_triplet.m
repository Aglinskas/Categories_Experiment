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
%mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis_18_3mm/mask.nii';

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
save('/Users/aidasaglinskas/Desktop/pre_stacked_scans_tiny.mat','all_scans');
%%
%ofn_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/RDMsForElisa/'
%% All Scans
load('/Users/aidasaglinskas/Desktop/pre_stacked_scans_tiny.mat','all_scans')
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
model = 1-wikiClust.cmat;
%add_numbers_to_mat(model,wikiClust.lbls)

% REMEMBER TO CHANGE .cond_index mapping
change_all_scans
all_scans = cosmo_slice(all_scans,~isnan(all_scans.sa.cond_index2)); % drop leisure
all_scans = cosmo_slice(all_scans,~(all_scans.sa.cond_index==18)); % 
svec = unique(all_scans.sa.subID)';
pairs = nchoosek(1:16,2);
npairs = length(pairs);
%%
opt.radius = 2;
args.target_dsm = get_triu(model);
args.metric = 'Correlation'
args.type = 'Pearson'
args.center_data = 1;
measure = @cosmo_target_dsm_corr_measure;
%%

for s_ind = 2:18;
subScans = cosmo_slice(all_scans,all_scans.sa.subID==svec(s_ind));
nbrhood=cosmo_spherical_neighborhood(subScans, 'radius',2);

    ncenters = length(nbrhood.neighbors); % constant
    %res_simple = nan(npairs,ncenters); % pre-allocate
    %res_cross = nan(npairs,ncenters);% pre-allocate
tic
SubRes = nan(ncenters,npairs,3,3);
for p_ind = 1:npairs
    this_pair = pairs(p_ind,:);

%b_res = nan(ncenters,3,3);

    for b_ind1 = 1:3
    for b_ind2 = 1:3
    bool = (subScans.sa.cond_index2==this_pair(1) & subScans.sa.b_ind==b_ind1) | (subScans.sa.cond_index2==this_pair(2) & subScans.sa.b_ind==b_ind2);
    if sum(sum(bool))~=2;error('error slicing');end
    
    this_DS = cosmo_slice(subScans,bool);
    this_DS.sa.targets = this_DS.sa.cond_index2;
    clc; disp([s_ind p_ind b_ind1 b_ind2]);toc

    for center_id = 1:length(nbrhood.neighbors)
        sphere_ds=cosmo_slice(this_DS, nbrhood.neighbors{center_id}, 2);    
    samples=sphere_ds.samples;
    samples = samples - mean(samples,2); % hmm... centering?
    c = cosmo_corr(samples(1,:)',samples(2,:)');
    %b_res(center_id,b_ind1,b_ind2) = c;
    SubRes(center_id,p_ind,b_ind1,b_ind2) = c;
    end % center_id
    end % b_ind2
    end % b_ind2
    %pair_res_simple = mean([b_res(:,1,1) b_res(:,2,2) b_res(:,2,2)],2)';
    %pair_res_cross = mean(mean(b_res,3),2)';

%res_simple(p_ind,:) = pair_res_simple;
%res_cross(p_ind,:) = pair_res_cross;
%plot([pair_res_simple;pair_res_cross]');legend({'simple' 'cross'});drawnow;
end % ends pairs

%fit_simple = nan(1,ncenters);
%fit_cross = nan(1,ncenters);
%model_vec = 1-squareform(model)';
%for v = 1:ncenters
%fit_simple(v) = corr(res_simple(:,v),model_vec);
%fit_cross(v) = corr(res_cross(:,v),model_vec);
%end
%plot([fit_cross;fit_simple]');
%hist([fit_cross;fit_simple]');legend({'Cross' 'Simple'});drawnow;

% simpleDS = this_DS;
% simpleDS.samples = fit_simple;
% simpleDS.sa = struct;
% 
% crossDS = this_DS;
% crossDS.samples = fit_cross;
% crossDS.sa = struct;

    ofn_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/RSA_searchlight4/';
    if ~exist(ofn_dir);mkdir(ofn_dir);end
    
save(fullfile(ofn_dir,[num2str(s_ind) '.mat']));
%cosmo_map2fmri(simpleDS,fullfile(ofn_dir,[num2str(s_ind) '_simple.nii']));
%cosmo_map2fmri(crossDS,fullfile(ofn_dir,[num2str(s_ind) '_cross.nii']));

end % ends sub
%%
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat');
model = wikiClust.cmat;
ofn_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/RSA_searchlight4/';
model_vec = 1-squareform(1-model)';
model_ev = [];

e_ds = all_scans;
e_ds.samples = struct;
e_ds.sa = struct;


for s_ind = 1:18;
model_ev = [];
load(fullfile(ofn_dir,[num2str(s_ind) '.mat']));
    for b_ind1 = 1:3
    for b_ind2 = 1:3
ft = arrayfun(@(x) corr(squeeze(SubRes(x,:,b_ind1,b_ind2))',model_vec),1:size(SubRes,1));
model_ev(b_ind1,b_ind2,:) = ft;
    end
    end
    
simple = mean(squeeze([model_ev(1,1,:) model_ev(2,2,:) model_ev(3,3,:)]),1);
cross = squeeze(mean(mean(model_ev,2),1));

simpleDS.samples = simple;
crossDS.samples = cross';


cosmo_map2fmri(simpleDS,fullfile(ofn_dir,[num2str(s_ind) '_simple.nii']))
cosmo_map2fmri(crossDS,fullfile(ofn_dir,[num2str(s_ind) '_cross.nii']))
end


%%
%%  Dump Big Files
% for s_ind = 1:18;
%     clc;disp(s)
% fn = fullfile(ofn_dir,[num2str(s_ind) '.mat']);
% [subDS, RDM_map3d] = deal([]);
% load(fn,'RDM_map3d','subDS')
% 
%     RSA_ds = cosmo_slice(subDS,1); %  template
% RSA_ds.samples = mean(subDS.samples); % mean RSA fit
% 
%     RSA_ffx = cosmo_slice(subDS,1);
%     mn = mean(RDM_map3d.samples,3);
%     ffx_dt = arrayfun(@(x) corr(mn(:,x),args.target_dsm'),1:length(mn));
% RSA_ffx.samples = ffx_dt; % fit of mean RDM
% 
% RDM_map3d.samples = 1-mean(RDM_map3d.samples,3);
%     RDM_map3d.sa = struct;
% cosmo_map2fmri(RSA_ds,fullfile(ofn_dir,[num2str(s_ind) '_RSA_rfx.nii']));
% cosmo_map2fmri(RSA_ffx,fullfile(ofn_dir,[num2str(s_ind) '_RSA_ffx.nii']));
% cosmo_map2fmri(RDM_map3d,fullfile(ofn_dir,[num2str(s_ind) 'bigout.nii']));
% end
%%
%ofn_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/RSA_searchlight3/';
anal_dir = 'anal_simple';
analysis_dir = fullfile(ofn_dir,anal_dir); 

matlabbatch = {};
if exist(analysis_dir)==0
    mkdir(analysis_dir);
else 
    delete([analysis_dir '/*'])
end
    fls = dir([ofn_dir '*simple.nii']);
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
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = '1';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
%
delete([analysis_dir '/*']);
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);
%%

analysis_dir = fullfile(ofn_dir,'anal_simple')

load([analysis_dir '/SPM.mat'])
xSPM = SPM;
xSPM=SPM;
xSPM.Ic=1;
xSPM.Im=0;
xSPM.Ex=0;
xSPM.Im=[];
xSPM.title='singleSubROI';
xSPM.thresDesc='none';
xSPM.u= .1;
xSPM.k = 0;

[hReg,xSPM,SPM] = spm_results_ui('Setup',[xSPM])

img = '/Users/aidasaglinskas/Documents/MATLAB/spm12/canonical/single_subj_T1.nii';
spm_sections(xSPM,hReg,img)
%%
roi_input_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/';
dt_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/RSA_searchlight2/';
fls = dir([roi_input_dir '*.nii']);
fls = {fls.name}';
dt_fls = dir([dt_dir '*bigout.nii'])
dt_fls = {dt_fls.name}';

rlbls = fls;
rlbls = strrep(rlbls,'ROI_','');
rlbls = strrep(rlbls,'.nii','');

for s = 1:length(dt_fls);
for r = 1:length(fls)
    clc;disp([s r])
    mfn= fullfile(roi_input_dir,fls{r});
    dt_fn = fullfile(dt_dir,dt_fls{s});
    ds = cosmo_fmri_dataset(dt_fn,'mask',mfn);
    cmats(:,:,r,s) = 1-squareform(mean(ds.samples,2));
end
end
disp('done')
%%
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat');
model = wikiClust.cmat;
clbls = wikiClust.lbls;
r = 3;
cmat_3d = 1-squeeze(cmats(:,:,r,:));
cmat_2d = mean(cmat_3d,3);

[H,P,CI,STATS] = ttest(func_fit_RSA_model(cmat_3d,model));

func_plot_dendMat(cmat_2d,clbls);
title({rlbls{r} t_statement(STATS,P)},'fontsize',20)
%%
dt = [];
for r = 1:7
    dt(:,r) = func_fit_RSA_model(1-squeeze(cmats(:,:,r,:)),model);
end
func_plot_tbar_plot(dt,rlbls)

[H,P,CI,STATS] = ttest(dt);
t_statement(STATS,P);
%% Build Struct
ROI_RDM = struct;
ROI_RDM.cmats = 1-cmats;
ROI_RDM.legend = 'C1|C2|ROI|SUB';
ROI_RDM.tlbls = wikiClust.lbls;
ROI_RDM.rlbls = rlbls;
ROI_RDM.model = model;
save('/Users/aidasaglinskas/Desktop/mats/forElisa/forElisa/ROI_RDM.mat','ROI_RDM')