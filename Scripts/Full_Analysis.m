clear all
%close all
% voxel data
load('/Users/aidasaglinskas/Desktop/mats/detrend_voxel_data.mat')
% ROI data
load('/Users/aidasaglinskas/Desktop/mats/detrend_roi_data.mat')
roi_raw = roi_data;
% tlbls
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat');
tlbls_raw = tlbls
% wiki Model
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/mats/wikiClust.mat')
% combData;
comb = load('/Users/aidasaglinskas/Desktop/mats/comb_voxel_data.mat');
comb = comb.voxel_data;
%
model = wikiClust.cmat; model(5,:) = [];model(:,5) = [];
wikiClust.cmat;wikiClust.cmat(:,5) = [];wikiClust.cmat(5,:) = [];wikiClust.lbls(5) = [];
%model = wikiClust;
roi_data.leg = 'ROI|CONDS|SUBS';
rlbls = voxel_data.mat_files; 

roi_data.tlbls = tlbls
roi_data.rlbls = rlbls
%% restrict tasks 
bool_restrict_tasks = 1;
if bool_restrict_tasks
    t_drop = [5];
roi_data.mat(:,t_drop,:)= [];
voxel_data.dt(:,t_drop,:) = [];
comb.dt(:,t_drop,:) = [];
tlbls(t_drop) = [];
end
%% Subtract CC
bool_subCC = 1;
if bool_subCC
roi_data.mat = roi_data.mat - roi_data.mat(:,end,:);

for r = 1:size(voxel_data.dt,1);
for c = 1:size(voxel_data.dt,2);
for s = 1:size(voxel_data.dt,3);
voxel_data.dt{r,c,s} = voxel_data.dt{r,c,s}-voxel_data.dt{r,end,s};
%voxel_data.dt{r,c,s} = zscore(voxel_data.dt{r,c,s});
end
end
end

for r = 1:size(comb.dt,1);
for c = 1:size(comb.dt,2);
for s = 1:size(comb.dt,3);
comb.dt{r,c,s} = comb.dt{r,c,s} - comb.dt{r,end,s};
comb.dt{r,c,s} = zscore(comb.dt{r,c,s});
end
end
end
roi_data.mat(:,17,:) = [];
voxel_data.dt(:,17,:) = [];
comb.dt(:,17,:) = [];
tlbls(17) = [];
end
%% Retrict ROIs
bool_rois = 0;
if bool_rois
wh_rois = ~ismember(1:length(rlbls),[1 2 3 6]);
rlbls_leg = arrayfun(@(x) [num2str(x,'%.2i') ' : ' rlbls{x}],1:length(rlbls),'UniformOutput',0)';
roi_data.mat = roi_data.mat(wh_rois,:,:);
voxel_data.dt = voxel_data.dt(wh_rois,:,:);
rlbls = rlbls(wh_rois);
end
%%
%%%%%%%%%%%% Analysis %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NetRSA
lbls = {tlbls rlbls};
f = figure(1);
clear tcmats rcmats
for s = 1:size(roi_data.mat,3)
tcmats(:,:,s) = corr(roi_data.mat(:,:,s));
rcmats(:,:,s) = corr(roi_data.mat(:,:,s)');
end
NetRSA_tcmats = tcmats;
NetRSA_rcmats = rcmats;
tcmat = mean(tcmats,3);
rcmat = mean(rcmats,3);

mats = {tcmat rcmat};

% Plot
func_plot_dendMat(mats,lbls)

% Stats
subCmats = tcmats;
w_t = 1:16;
for s = 1:size(subCmats,3);
dt(s) = corr(get_triu(subCmats(w_t,w_t,s))',get_triu(model)');
end
[H,P,CI,STATS] = ttest(dt);

f.CurrentAxes.TickDir = 'out'
subplot(2,2,2);box off
subplot(2,2,4);box off
%%
txt = sprintf('Model fit T=%.2f, p=%.4f',STATS.tstat,P);
title({'NetRSA' txt},'fontsize',20)
NetRSA_fit = dt;
%% Voxel RSA
figure(2)

clear mat cmat
for s = 1:size(voxel_data.dt,3)
for r = 1:size(voxel_data.dt,1)
    mat = cell2mat(voxel_data.dt(r,:,s)');
    tcmat(:,:,r,s) = corr(mat');
end
end

rcmat = [];
for s = 1:size(tcmat,4);
for r1 = 1:size(tcmat,3);
for r2 = 1:size(tcmat,3);
    rcmat(r1,r2,s) = corr(get_triu(tcmat(:,:,r1,s))',get_triu(tcmat(:,:,r2,s))');
end
end
end
mtcmat = mean(mean(tcmat,4),3);
mrcmat = mean(rcmat,3);

mats = {mtcmat mrcmat};
func_plot_dendMat(mats,lbls)

% Stats RSA
subCmats = squeeze(mean(tcmat,3));
for s = 1:size(subCmats,3);
dt(s) = corr(get_triu(subCmats(w_t,w_t,s))',get_triu(model)');
end
[H,P,CI,STATS] = ttest(dt);
txt = sprintf('Model fit T=%.2f, p=%.4f',STATS.tstat,P);
title({'RSA' txt},'fontsize',20)
%% CombROI
figure(3);
% CombROI matrix
scmat = [];
for s = 1:18;
smat = cell2mat(comb.dt(1,:,s)');
scmat(:,:,s) = corr(smat');
end
CombROI_tcmats = scmat;
mscmat = mean(scmat,3);

func_plot_dendMat(mscmat,lbls{1})

% Stats RSA
subCmats = scmat;
dt = [];
for s = 1:size(subCmats,3);
dt(s) = corr(get_triu(subCmats(:,:,s))',get_triu(model)');
end
[H,P,CI,STATS] = ttest(dt);
txt = sprintf('Model fit T=%.2f, p=%.4f',STATS.tstat,P);
title({'CombROI' txt},'fontsize',20)
combROI_fit = dt;
%% Fit Models;
%figure(4);
data = tcmat;
dtlbls = rlbls;
data(:,:,end+1,:) = scmat;
dtlbls{end+1} = 'CombROI';

model = wikiClust.cmat;
%model(5,:) = [];model(:,5) = [];
semModel = model;
    model = wikiClust.word_freq_model;
    model(5,:) = [];model(:,5) = [];
    freqModel = model;
model = wikiClust.word_length_model;
model(5,:) = [];model(:,5) = [];
lengthModel = model;

all_models = {semModel freqModel lengthModel};
all_model_names = {'Semantic' 'Frequency' 'Word Length'};
cdata = []
for r = 1:size(data,3);
for s = 1:size(data,4);
for m = 1:length(all_models);
    v1 = get_triu(data(:,:,r,s))';
    v2 = get_triu(all_models{m})';
   cdata(r,s,m) = corr(v1,v2); 
end
end
end
%%
m = squeeze(mean(cdata,2));
sd = squeeze(std(cdata,[],2)) ./ sqrt(18);
for model_ind = 1:3;

figure(4+model_ind)
subplot(2,1,1)

bar(m(:,model_ind));hold on;errorbar(m(:,model_ind),sd(:,model_ind),'r.');hold off;
xticks(1:length(m));xticklabels(dtlbls);xtickangle(45);
xlim([0 length(dtlbls)+1])
title(all_model_names{model_ind},'fontsize',20)

sp = subplot(10,1,6);
[H,P,CI,STATS] = ttest(cdata(:,:,model_ind)');
add_numbers_to_mat(STATS.tstat)
xlim([0 length(dtlbls)+1]);
sp.YTick = [];sp.XTick = [];
sp.CLim = [1.95 1.96];
end
%% Univariate responses;
f = figure(10);
f.Color = [1 1 1];
roi_raw;
roi_raw.mat = roi_raw.mat - roi_raw.mat(:,end,:);
roi_raw.mat(:,5,:) = [];tlbls_raw(5) = [];
for r = 1:size(roi_raw.mat,1)
mat = squeeze(roi_raw.mat(r,:,:));   

m = mean(mat,2);
sd = std(mat,[],2) ./ sqrt(size(mat,2));

sp = subplot(5,4,r);
bar(m); hold on;
errorbar(m,sd,'r.');hold off

sp.XTick = 1:size(roi_raw.mat,2);
sp.XTickLabel = tlbls_raw;
sp.XTickLabelRotation = 60;
title(roi_raw.lbls{r},'fontsize',14)    
end
%%

f = figure(2);
sp = subplot(2,2,3);
%sp.XTickLabel
%%
clust{1} = [{'RSc-L'}    {'RSc-R'}    {'Prec-M'}    {'vmPFC-M'}    {'PHG-L'}    {'PHG-R'}];
clust{2} = [  {'IPL-L'}    {'IPL-R'}    {'pMTG-L'}    {'pMTG-R'}    {'OFC-L'}    {'OFC-R'}];

for clust_ind = 1:length(clust);
figure(11+clust_ind);clf
inds = ismember(lbls{2},clust{clust_ind});
inds = find(inds);

clust_data = []; scmat = [];
% collect data
for s = 1:size(voxel_data.dt,3)
s_voxelMat = [];
for c = 1:size(voxel_data.dt,2)
    %clust_data(:,c,s) = [voxel_data.dt{inds,c,s}];
    s_voxelMat(:,c) = [voxel_data.dt{inds,c,s}];
end
scmat(:,:,s) = corr(s_voxelMat);
end


% cmat
for s = 1:size(voxel_data.dt,3)
   dt(s) = corr(get_triu(semModel)',get_triu(scmat(:,:,s))');
   adts(s,clust_ind) = dt(s)
end

[H,P,CI,STATS] = ttest(dt);
txt = sprintf('T:%.2f,p=%.4f',STATS.tstat,P)

func_plot_dendMat(mean(scmat,3),lbls{1})
ttl = {'sub clust' strjoin(clust{clust_ind},', ') 'Semmodel fit' txt}
title(ttl,'fontsize',20)
end
[H,P,CI,STATS] = ttest(NetRSA_fit,combROI_fit);

%[H,P,CI,STATS] = ttest(adts(:,2),adts(:,1))
%% ROI Data
clust{1} = [{'RSc-L'}    {'RSc-R'}    {'Prec-M'}    {'vmPFC-M'}    {'PHG-L'}    {'PHG-R'}];
clust{2} = [  {'IPL-L'}    {'IPL-R'}    {'pMTG-L'}    {'pMTG-R'}    {'OFC-L'}    {'OFC-R'}];
clust_ind = 1;
inds = ismember(lbls{2},clust{clust_ind});

for s = 1:18
scmat(:,:,s) = corr(roi_data.mat(inds,:,s));
end

for s = 1:size(voxel_data.dt,3)
   dt(s) = corr(get_triu(semModel)',get_triu(scmat(:,:,s))');
   dts(s,clust_ind) = dt(s);
end

%[H,P,CI,STATS] = ttest(dts(:,2),dts(:,1)) % model fit to elements
[H,P,CI,STATS] = ttest(dt);
txt = sprintf('T:%.2f,p=%.4f',STATS.tstat,P)

func_plot_dendMat(mean(scmat,3),lbls{1})
ttl = {'sub clust' strjoin(clust{clust_ind},', ') 'Semmodel fit' txt}
title(ttl,'fontsize',20)
%% netRSA vs RSA method
dt = [];
for s = 1:size(NetRSA_tcmats,3)
    v1 = get_triu(NetRSA_tcmats(:,:,s))';
    v2 = get_triu(CombROI_tcmats(:,:,s))'; 
dt(s) = corr(v1,v2);
end
ttest(dt,1)
%% Regional Models 

mat_lbls = lbls{2};
clust_data = {};
clust_data{end+1} = {'IPL-L'    'IPL-R' 'pMTG-L'    'pMTG-R'  'OFC-L'    'OFC-R'}
clust_data{end+1} = {'PHG-L'    'PHG-R' 'Prec-M'    'RSc-L'    'RSc-R' 'vmPFC-M'}

model_data = func_made_RSA_model(mat_lbls,clust_data,1,'observed clustering model');

clust_sem = {};
clust_sem{end+1} = {'OFC-L'    'OFC-R' 'PHG-L'    'PHG-R' 'pMTG-L'    'pMTG-R' 'vmPFC-M' 'Prec-M'}
clust_sem{end+1} = {'IPL-L'    'IPL-R' 'RSc-L'    'RSc-R'}


clust_binder = {};
clust_binder{end+1} = {'OFC-L'    'OFC-R' 'PHG-L'    'PHG-R' 'pMTG-L'    'pMTG-R' 'vmPFC-M' 'Prec-M'}

model_binder = func_made_RSA_model(mat_lbls,clust_binder,'Binder model');

models = {model_data model_sem model_binder};
rdata = NetRSA_rcmats;
%% Fit against zero
model_fit = []
for m_ind = 1:length(models)
for s = 1:size(rdata,3)
    v1 = get_triu(rdata(:,:,s))';
    v2 = get_triu(models{m_ind})';
model_fit(m_ind,s) = corr(v1,v2);
end
end
[H,P,CI,STATS] = ttest(model_fit');
tvals = STATS.tstat
[H,P,CI,STATS] = ttest(model_fit(1,:)',model_fit(2,:)');
%% Cognitive Models
clust_data = {};
clust_data{end+1} = {'Animals-Insects'    'Animals-Domestic'    'Animals-Wild' 'Animals-Birds' }
clust_data{end+1} = {'Fruits & Veg'    'Food & Drink'}

model_animalsVsfood = func_made_RSA_model(lbls{1},clust_data,1,'Animals');

models = {model_animalsVsfood}
data = NetRSA_tcmats
%% Fit Models
model_fit = []
for m_ind = 1:length(models)
for s = 1:size(rdata,3)
    v1 = get_triu(data(:,:,s))';
    v2 = get_triu(models{m_ind})';
model_fit(m_ind,s) = corr(v1,v2);
end
end
[H,P,CI,STATS] = ttest(model_fit');
%% Wiki model
figure(19)

func_plot_dendMat(wikiClust.cmat,wikiClust.lbls)
%% Polar Plot 
clust_data = {}
clust_data{end+1} = {'IPL-L'    'IPL-R' 'pMTG-L'    'pMTG-R'  'OFC-L'    'OFC-R'}
clust_data{end+1} = {'PHG-L'    'PHG-R' 'Prec-M'    'RSc-L'    'RSc-R' 'vmPFC-M'}
clust_inds{1} = find(ismember(lbls{2},clust_data{1}));
clust_inds{2} = find(ismember(lbls{2},clust_data{2}));


use_roi_data.mat = roi_data.mat;
use_roi_data.mat = zscore(use_roi_data.mat,[],2)
dt1 = mean(mean(use_roi_data.mat(clust_inds{1},:,:),3));
dt2 = mean(mean(use_roi_data.mat(clust_inds{2},:,:),3));

f = figure(20);clf
polarplot(dt1)
hold on
polarplot(dt2)

f.CurrentAxes.RLim = [min([dt1 dt2]) max([dt1 dt2])];
%f.CurrentAxes.ThetaTick = rad2deg(angle);
f.CurrentAxes.ThetaTickLabel = lbls{1};
f.CurrentAxes.ThetaGrid = 'on';
f.CurrentAxes.FontSize = 15;
f.CurrentAxes.FontWeight = 'bold';
%% Tmat show

f = figure(7)
size(aBeta.fmat)

[H,P,CI,STATS] = ttest(permute(aBeta.fmat,[3 1 2]));

add_numbers_to_mat(squeeze(STATS.tstat),aBeta.t_lbls(1:10),aBeta.r_lbls);
f.CurrentAxes.CLim = [2.089 2.09];
title('T values','fontsize',20)



%%
clc;disp('Full analysis done');