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
%mask_fn = fullfile(roi_output_dir,'combRoi.nii')
mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis_18_3mm/mask.nii';

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
save('/Users/aidasaglinskas/Desktop/pre_stacked_scans.mat','all_scans');
%%
%ofn_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/RDMsForElisa/'
%% All Scans
%load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/all_scans_3mm_18s.mat');
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
model = 1-wikiClust.cmat;
%add_numbers_to_mat(model,wikiClust.lbls)

% REMEMBER TO CHANGE .cond_index mapping
change_all_scans
all_scans = cosmo_slice(all_scans,~isnan(all_scans.sa.cond_index2)); % drop leisure
all_scans = cosmo_slice(all_scans,~(all_scans.sa.cond_index==18)); % 
svec = unique(all_scans.sa.subID)';
%%
opt.radius = 2;
args.target_dsm = get_triu(model);
args.metric = 'Correlation'
args.type = 'Pearson'
args.center_data = 1;
measure = @cosmo_target_dsm_corr_measure;
%%
tic
for s_ind = 1:18;
subScans = cosmo_slice(all_scans,all_scans.sa.subID==svec(s_ind));
nbrhood=cosmo_spherical_neighborhood(subScans, 'radius',2);
for b_ind = 1:3
    clc; disp([s_ind b_ind])
    toc
this_DS = cosmo_slice(subScans,subScans.sa.b_ind==b_ind);
this_DS.sa.targets = this_DS.sa.cond_index2;

dataset = this_DS;

ds = this_DS;

[results_map,RDMs_cell] = cosmo_searchlight(this_DS, nbrhood, measure,args,'nproc',1);

RDM_map = results_map;
RDM_map.samples = [RDMs_cell{:}];

% Gives same number
%corr(RDM_map.samples(:,1),args.target_dsm')

    if b_ind == 1;
    subDS = results_map;
    RDM_map3d = RDM_map;
    else 
    subDS = cosmo_stack({subDS results_map})
    RDM_map3d.samples(:,:,b_ind) = RDM_map.samples;
    end

end % ends beta

%vx = 100;bt = 3;[subDS.samples(bt,vx) corr(RDM_map3d.samples(:,vx,bt),args.target_dsm')]
%[mean(subDS.samples(:,vx))] 
%corr(mean(RDM_map3d.samples(:,vx,1:3),3),args.target_dsm')
%mean(subDS.samples(:)) ./ std(subDS.samples(:));

ofn_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/RSA_searchlight3/';
    if ~exist(ofn_dir);mkdir(ofn_dir);end
    
save(fullfile(ofn_dir,[num2str(s_ind) '.mat']),'subDS','RDM_map3d');

% subDSavg = subDS;
% 
% subDSavg.sa = []
% subDSavg.sa.labels{1} = 'rho'
% 

% save(fullfile(ofn_dir,sprintf('%d.mat',s_ind)),'this_DS','subDS');
% cosmo_map2fmri(subDSavg,fullfile(ofn_dir,sprintf('%d_avg.nii',s_ind)));
% cosmo_map2fmri(subDS,fullfile(ofn_dir,sprintf('%d.nii',s_ind)));
% toc

end % ends sub
%%  Dump Big Files
for s_ind = 1:18;
    clc;disp(s)
fn = fullfile(ofn_dir,[num2str(s_ind) '.mat']);
[subDS, RDM_map3d] = deal([]);
load(fn,'RDM_map3d','subDS')

    RSA_ds = cosmo_slice(subDS,1); %  template
RSA_ds.samples = mean(subDS.samples); % mean RSA fit

    RSA_ffx = cosmo_slice(subDS,1);
    mn = mean(RDM_map3d.samples,3);
    ffx_dt = arrayfun(@(x) corr(mn(:,x),args.target_dsm'),1:length(mn));
RSA_ffx.samples = ffx_dt; % fit of mean RDM

RDM_map3d.samples = 1-mean(RDM_map3d.samples,3);
    RDM_map3d.sa = struct;
cosmo_map2fmri(RSA_ds,fullfile(ofn_dir,[num2str(s_ind) '_RSA_rfx.nii']));
cosmo_map2fmri(RSA_ffx,fullfile(ofn_dir,[num2str(s_ind) '_RSA_ffx.nii']));
cosmo_map2fmri(RDM_map3d,fullfile(ofn_dir,[num2str(s_ind) 'bigout.nii']));
end
%%
matlabbatch = {};
anal_dir = 'analFFX';
analysis_dir = fullfile(ofn_dir,anal_dir); 
if exist(analysis_dir)==0
    mkdir(analysis_dir);
else 
    delete([analysis_dir '/*'])
end
    fls = dir([ofn_dir '*ffx.nii']);
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
%%
delete([analysis_dir '/*']);
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);
%%

ofn_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/RSA_searchlight2/';
analysis_dir = fullfile(ofn_dir,'analFFX')
analysis_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/RSA_searchlight/anal/';
load([analysis_dir '/SPM.mat'])

xSPM = SPM;
xSPM=SPM;
xSPM.Ic=1;
xSPM.Im=0;
xSPM.Ex=0;
xSPM.Im=[];
xSPM.title='singleSubROI';
xSPM.thresDesc='none';
xSPM.u= .05;
xSPM.k = 15;

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
cmats = mean(cmats,5);
r = 6;
%cmat_3d = 1-squeeze(cmats(:,:,r,:));
cmat_3d = 1-squeeze(mean(cmats(:,:,r,:,:),5));

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
%save('/Users/aidasaglinskas/Desktop/mats/forElisa/forElisa/ROI_RDM.mat','ROI_RDM')
%%
load('/Users/aidasaglinskas/Desktop/mats/forElisa/forElisa/ROI_RDM.mat')
r = 1;
f = figure(4);
plot_mat2d = mean(mean(ROI_RDM.cmats(:,:,r,:,:),5),4);
plot_mat3d = squeeze(mean(ROI_RDM.cmats(:,:,r,:,:),5));

func_plot_dendMat(plot_mat2d,ROI_RDM.tlbls);

    mode_ev = func_fit_RSA_model(plot_mat3d,ROI_RDM.model);    
    [H,P,CI,STATS] = ttest(mode_ev);
    str = t_statement(STATS,P);

subplot(1,2,1);
ttl = {ROI_RDM.rlbls{r} t_statement(STATS,P)};
title(ttl,'fontsize',20)
saveas(f,['/Users/aidasaglinskas/Desktop/Work_Clutter/forElisa 2/' num2str(ROI_RDM.rlbls{r}) '.jpg'])
%%
