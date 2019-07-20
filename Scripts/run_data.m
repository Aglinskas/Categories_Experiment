clear;close
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Data2.mat');
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat');
load('/Users/aidasaglinskas/Downloads/It_RDM_4AIDAS.mat');
%
sd.mat(end,:,:,:) = [];
sd.mat(:,end,:,:) = [];
sd.tlbls(end) = [];
tlbls = sd.tlbls;

rlbls = sd.rlbls;
rlbls = strrep(rlbls,'ROI_','');
model = wikiClust.cmat;
%Subtract CC from voxel_data
for s = 1:size(voxel_data.dt,3)
for r = 1:size(voxel_data.dt,1)
for c = 1:size(voxel_data.dt,2)
%voxel_data.dt{r,c,s} = voxel_data.dt{r,c,s} - voxel_data.dt{r,17,s};
end
end
end
voxel_data.dt(:,17,:) = [];
% sub CC from Roi_data
roi_data.mat = roi_data.mat - roi_data.mat(:,17,:);
roi_data.mat(:,17,:) = [];
roi_data.tlbls = tlbls;
func_plot_dendMat(model,tlbls)
%% Decoding model fit
model = catMat;
%model = 1-wikiClust.cmat;
dt = [];
for r = 1:size(sd.mat,3)
    cmat = squeeze(sd.mat(:,:,r,:));
    if cmat(1,1)~=model(1,1); error('sim not sim matrix error');end
   dt(:,r) = func_fit_RSA_model(cmat,model) ;
end
func_plot_tbar_plot(dt,rlbls)
%% Show Decoding RDM
func_plot_dendMat(1-mean(sd.mat(:,:,2,:),4),tlbls)
%% Voxel model fit
model = wikiClust.cmat;
%model = 1-catMat
dt = [];
for r = 1:size(voxel_data.dt,1)
cmats = func_combroi(voxel_data.mat_files(r),voxel_data);

if cmats(1,1)~=model(1,1); error('Sim-Dissim error');end
dt(:,r) = func_fit_RSA_model(cmats,model);
end
func_plot_tbar_plot(dt,rlbls)

[H,P,CI,STATS] = ttest(dt(:,find(strcmp(rlbls,'AG'))),0,'tail','both');
t_statement(STATS,P)
%%
% Show AG corrRDM
func_plot_dendMat(mean(func_combroi(voxel_data.mat_files(4),voxel_data),3),tlbls)
%% netRSA
tcmat = [];rcmat = [];
for s = 1:size(roi_data.mat,3)
tcmat(:,:,s) = corr(roi_data.mat(:,:,s));
rcmat(:,:,s) = corr(roi_data.mat(:,:,s)');    
end
func_plot_dendMat({tcmat rcmat},{roi_data.tlbls rlbls})
%% Precuneus jNeuro
targ_tasks = {'Animals-Wild' 'Animals-Birds' 'Fruits & Veg' 'Clothes' 'Tools'};
targ_tasks_inds = find(ismember(tlbls,targ_tasks));
%tinyModel = 1-catMat(targ_tasks_inds,targ_tasks_inds);
tinyModel = wikiClust.cmat(targ_tasks_inds,targ_tasks_inds)
roi_lbl = 'pMTG';
roi_ind = find(strcmp(rlbls,roi_lbl));

roi.RDM = sd.mat(targ_tasks_inds,targ_tasks_inds,roi_ind,:);
func_plot_dendMat(1-mean(roi.RDM,4),targ_tasks);

vx = voxel_data;
vx.dt = voxel_data.dt(:,targ_tasks_inds,:);
cmats = func_combroi(voxel_data.mat_files((roi_ind)),vx);
% Show CorrRDM
func_plot_dendMat(mean(cmats,3),targ_tasks);
%
% Show model
func_plot_dendMat(tinyModel,targ_tasks);
% All regions, jNeuro
sd_tiny = sd;
sd_tiny.mat = sd_tiny.mat(targ_tasks_inds,targ_tasks_inds,:,:);

clf
dt = [];
for r = 1:size(sd_tiny.mat,3)
   %cmats = 1-squeeze(sd_tiny.mat(:,:,r,:));
   cmats = func_combroi(vx.mat_files(r),vx);
dt(:,r) = func_fit_RSA_model(cmats,tinyModel);  
end
func_plot_tbar_plot(dt,vx.mat_files)
%% Animate / inanimate

clust{1} = {'Clothes'
'Musical ins'
'Tools'
'Household'
'Materials'}


clust{2} = {
'Animals-Water'
'Animals-Insects'
'Animals-Domestic'
'Animals-Wild'
'Animals-Birds'}

ttls = {'Sensitive to Tool Similarity' 'Sensitive to Animal Similarity'};

clf;
for p = 1:2
subplot(1,2,p);
inds = ismember(tlbls,clust{p});

model = wikiClust.cmat(inds,inds);

vx = voxel_data;
vx.dt = vx.dt(:,inds,:);
vx.mat_files = voxel_data.mat_files

dt = [];
for r = 1:size(sd_tiny.mat,3)
    cmats = squeeze(sd.mat(inds,inds,r,:))
for s = 1:18
    %cmats = func_combroi(vx.mat_files(r),vx); 
%dt(:,r) = func_fit_RSA_model(cmats,model);  
dt(s,r) = mean(get_triu(cmats(:,:,s)));
new(s,r,p) = dt(s,r);
end
end
func_plot_tbar_plot(dt-.5,vx.mat_files)
title(ttls{p},'fontsize',20)
end
%% Partial Corr

func_plot_tbar_plot(new(:,:,1) - new(:,:,2),vx.mat_files)


