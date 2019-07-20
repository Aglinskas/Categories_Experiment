load('/Volumes/External_2TB/LastCleanWorkHDD/Desktop/mats/netRSA_data.mat');
load('/Users/aidasaglinskas/Desktop/Categories_Experiment/Files/netRSA_data3.mat')
%a = load('/Volumes/External_2TB/LastCleanWorkHDD/Desktop/mats/netRSA_data2.mat');
%     netRSA_data.rlbs = netRSA_data.rlbls
%     load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
%     netRSA_data.model = wikiClust.cmat
%% 
addpath('/Volumes/External_2TB/PhD_Data/fMRI_Projects/Data_words/Scripts/fMRI-person-knowledge-names/')
addpath('/Volumes/External_2TB/PhD_Data/fMRI_Projects/Categories_Experiment/Scripts/')
addpath('/Volumes/External_2TB/PhD_Data/Other_Scripts/')
%% Make messy figure
mat = netRSA_data.mat;
mat(:,5,:,:) = []; % drop leisure;
mat = mat - mat(:,end,:,:); % sub CC
mat = mean(mat,4); % mean across runs 
mat(:,end,:) = [];

rlbls = netRSA_data.rlbls;
tlbls = netRSA_data.tlbs;
tlbls(5) = [];
tlbls(end) = [];

m = mean(mat,3) % mean across subs;
percmat = [];

for col = 1:size(mat,1);
    m(col,:) = m(col,:) - min(m(col,:))+.1;
end

for c = 1:16
for r = 1:size(mat,1)
val = m(r,c);
percmat(r,c) = val ./ sum(m(r,:),2);
end
end

% For ordering
figure(2)
    cmats = func_make_cmat(mat);
    to_plot = {mean(cmats{1},3) mean(cmats{2},3)};
    a = func_plot_dendMat(to_plot,{rlbls tlbls});
    r_ord = a.ord{1};
    t_ord = a.ord{2};

tlbls = netRSA_data.tlbs(~ismember(1:18,[5 18]));
rlbls = netRSA_data.rlbls;

[H,P,CI,STATS] = ttest(mat,0,'dim',3)
tmat = STATS.tstat;
figure(1)
add_numbers_to_mat(tmat,tlbls,rlbls);
f.CurrentAxes.CLim = [0 2];
%% Univariate response
clf
mat = netRSA_data.mat;
mat(:,5,:,:) = []; % drop leisure;
mat = mat - mat(:,end,:,:); % sub CC
mat = mean(mat,4); % mean across runs 
mat(:,end,:) = [];

figure(1)
func_plot_tbar_plot(squeeze(mean(mat,2))',netRSA_data.rlbs);
%% Regional Fit 
mat = netRSA_data.mat;
mat(:,5,:,:) = []; % drop leisure;
mat = mat - mat(:,end,:,:); % sub CC
mat = mean(mat,4); % mean across runs 
mat(:,end,:) = [];
%% Some regions fit 
addpath('/Users/aidasaglinskas/Google Drive/Aidas/Data_words/Scripts/fMRI-person-knowledge-names/')
mat = netRSA_data.mat;
mat(:,5,:,:) = []; % drop leisure;
mat = mat - mat(:,end,:,:); % sub CC
mat = mean(mat,4); % mean across runs 
mat(:,end,:) = [];

%wh_rois = {'AG-L' 'IPL-L' 'IPL-R' 'OFC-L' 'OFC-R' 'PHG-L' 'PHG-R' 'Prec.-M' 'RSC-L' 'RSC-R' 'pMTG-L' 'pMTG-R' 'vmPFC-L'};
wh_rois = {'AG-L' 'OFC-L' 'OFC-R' 'PHG-L' 'PHG-R' 'Prec.-M' 'pMTG-L' 'pMTG-R' 'vmPFC-L'}
slice = ismember(netRSA_data.rlbs,wh_rois);
cmats = func_make_cmat(mat(slice,:,:));
data = cmats{2};

model_fit = func_fit_RSA_model(data,netRSA_data.model);
[H,P,CI,STATS] = ttest(model_fit);
t_statement(STATS,P);
%%
mat = netRSA_data.mat;
mat(:,5,:,:) = []; % drop leisure;
mat = mat - mat(:,end,:,:); % sub CC
mat = mean(mat,4); % mean across runs 
mat(:,end,:) = [];

i = 7;
func_plot_tbar_plot(squeeze(mat(i,:,:)),netRSA_data.tlbs);
title(netRSA_data.rlbs(i),'fontsize',20);

[H,P,CI,STATS] = ttest(mat,0,'dim',3);
f = figure(1);
%%
add_numbers_to_mat(STATS.tstat,netRSA_data.rlbs,tlbls);
f.CurrentAxes.CLim = [2 4]
%%

f = figure(1);clf;add_numbers_to_mat(percmat(r_ord,t_ord),tlbls(t_ord),rlbls(r_ord),'num');colorbar
f.Color = [1 1 1];
f.CurrentAxes.FontSize = 14;
f.CurrentAxes.FontWeight = 'bold';
f.CurrentAxes.XTickLabelRotation = 45;
%% Nice pcolor
f = figure(2);
r_rev= r_ord(end:-1:1);
cmat = percmat(r_rev,t_ord);
cmat = [cmat;cmat(1,:)];
cmat = [cmat cmat(:,1)];

pcolor(cmat)
xticks(1.5:1:16.5);
xticklabels(tlbls(t_ord))
xtickangle(45)

yticks(1.5:1:13.5);
yticklabels(rlbls(r_ord(end:-1:1)))


f.Color = [1 1 1];
f.CurrentAxes.FontSize = 14;
f.CurrentAxes.FontWeight = 'bold';
f.CurrentAxes.XTickLabelRotation = 45;
%f.CurrentAxes.CLim = [.01 0.1]
%% Task Perc
bar(percmat,'stacked');ylim([0 1])
%%
mat = netRSA_data.mat;
mat(:,5,:,:) = []; % drop leisure;
mat = mat - mat(:,end,:,:); % sub CC
mat = mean(mat,4); % mean across runs 
mat(:,end,:) = [];

m = mean(mat,3) % mean across subs;


% no negative numbers
for col = 1:size(mat,2);
    m(:,col) = m(:,col) - min(m(:,col))+.1;
end

percmat = [];
for c = 1:16
for r = 1:size(mat,1)
val = m(r,c);
percmat(r,c) = val ./ sum(m(:,c));
end
end



% For ordering
    cmats = func_make_cmat(mat);
    to_plot = {mean(cmats{1},3) mean(cmats{2},3)};
    a = func_plot_dendMat(to_plot,{rlbls tlbls});
    r_ord = a.ord{1};
    t_ord = a.ord{2};

tlbls = netRSA_data.tlbs(~ismember(1:18,[5 18]));
rlbls = netRSA_data.rlbs;
f = figure(1);clf;add_numbers_to_mat(percmat(r_ord,t_ord),tlbls(t_ord),rlbls(r_ord));
%% NetRSA
%(r,cat_ind,s,b_ind)
data = netRSA_data;
data.leg = 'ROI|cat_ind|SUB|b_ind';
%data.model = wikiClust.cmat;
%data.mat = data.mat - data.mat(:,18,:,:);
data.mat(:,[5 18],:,:) = [];

cmat = [];
for s = 1:size(data.mat,3)
for b = 1:size(data.mat,4)
mat = data.mat(:,:,s,b);
mat = mat-mean(mat,2);
%mat(:,[5 18]) = [];
cmat(:,:,s,b) = corr(mat);
rcmat(:,:,s,b) = corr(mat');
end
end
%
tlbls = data.tlbs;
tlbls([5 18]) = [];
cmat_2d = mean(mean(cmat,4),3);
cmat_3d = mean(cmat,4);
cmat_3d_netRSA  = cmat_3d;
func_plot_dendMat({cmat_2d mean(mean(rcmat,4),3)},{tlbls data.rlbs})
[H,P,CI,STATS] = ttest(func_fit_RSA_model(cmat_3d,data.model));
subplot(2,2,1);title(t_statement(STATS,P),'fontsize',20);

netRSA_fit = func_fit_RSA_model(cmat_3d,data.model);
%% Reshape Voxel Data
for r = 1:size(netRSA_data.voxel_data,1);
    rmat = []
for s = 1:18
for c = 1:18
for b = 1:3
v = netRSA_data.voxel_data{r,c,s,b};
rmat(c,s,b,:) = v;
end
end
end
rmats{r} = rmat;
end
%% Voxel Corr
cmats = [];
for r = 1:size(netRSA_data.voxel_data,1)
for s = 1:18
for b = 1:3
mat = squeeze(rmats{r}(:,s,b,:));
mat([5 18],:) = [];
mat = mat-mean(mat,1); % centering       
cmats(:,:,r,s,b) = corr(mat','rows','pairwise');
end
end
end
sum(isnan(cmats(:)))
%% Single ROI RDM
r = 4;
cmat_2d = mean(mean(cmats(:,:,r,:,:),5),4);
cmat_3d = squeeze(mean(cmats(:,:,r,:,:),5));
func_plot_dendMat(cmat_2d,tlbls)

[H,P,CI,STATS]  = ttest(func_fit_RSA_model(cmat_3d,data.model));
title({data.rlbs{r} t_statement(STATS,P)},'fontsize',20);
%% Model Fit Bar. 
f = figure(1);clf
dt = [];
for r = 1:size(netRSA_data.voxel_data,1)
    dt(:,r) = func_fit_RSA_model(squeeze(mean(cmats(:,:,r,:,:),5)),data.model);
end
clf;
func_plot_tbar_plot(dt,data.rlbs,0);
%% Hax
f = figure(1);
r_ord = [1:13];
r_ord = [1 2 3 4 5 6 8 11 12 13       9 10];length(unique(r_ord))
func_plot_tbar_plot(dt(:,r_ord),data.rlbs(r_ord),0);

f.CurrentAxes.FontSize = 18;
f.CurrentAxes.FontWeight = 'bold';
f.CurrentAxes.LineWidth = 2;



[H,P,CI,STATS] = ttest(dt);

%[H,P,CI,STATS] = ttest(dt(:,[4 6 11]));
[H,P,CI,STATS] = ttest(dt(:,[4 6]));
t_statement(STATS,P);

x_c = max(xlim)-max(xlim)* .2
x_y = max(ylim)-max(ylim)* 0.05
str = '* p < .05/13';
text(x_c,x_y,str,'fontsize',18,'fontweight','bold')
ylabel('Model fit (r)','fontsize',14)
title('Regional Model Fit','fontsize',20)
f.CurrentAxes.FontWeight = 'bold';
f.CurrentAxes.FontSize = 16
%% Fit Mean RDM
mean_rdm_3d = squeeze(mean(mean(cmats,3),5));
mean_rdm_2d = mean(mean_rdm_3d,3);
    func_plot_dendMat(mean_rdm_2d,tlbls)
[H,P,CI,STATS] = ttest(func_fit_RSA_model(mean_rdm_3d,data.model));
t_statement(STATS,P);
% netRSA_fit
meanRSA_fit = func_fit_RSA_model(mean_rdm_3d,data.model)

[H,P,CI,STATS] = ttest(netRSA_fit,mean(dt,2))
[H,P,CI,STATS] = ttest(mean(dt,2))
[H,P,CI,STATS] = ttest(netRSA_fit,dt(:,4));
%[H,P,CI,STATS] = ttest(netRSA_fit,mean(dt(:,H),2))
[H,P,CI,STATS] = ttest(netRSA_fit,meanRSA_fit)

func_plot_tbar_plot([netRSA_fit mean(dt,2) meanRSA_fit],{'NetRSA' 'Mean Fit' 'Mean RDM'})


[H,P,CI,STATS] = ttest(mean(dt(:,[4]),2),netRSA_fit);
t_statement(STATS,P);
%%
[H,P,CI,STATS] = ttest(netRSA_fit,mean(dt,2));
t_statement(STATS,P)
%% Average Model Fit
[H,P,CI,STATS] = ttest(mean(dt,2));
t_statement(STATS,P);
%% Size RDMs
dt = [4	4	2	5	1	6	3	1	4	5	2	3	3	3	10	3
5	4	2	3	7	8	5	1	3	4	2	2	2	6	8	3
5	6	3	8	6	9	8	1	6	8	5	4	4	2	10	5
4	5	4	5	4	7	6	2	4	5	3	2	3	6	10	4
4	6	3	5	4	8	6	1	3	5	3	2	3	7	9	3];
%
mat = [];
for i = 1:size(dt,1)
    v = dt(i,:)'; % Vec
    v = (v - min(v)) / (max(v) - min(v)); % Norm the vec
    Y = pdist(v); % dis
    mat(:,:,i) = squareform(Y); 
end
size_RDM = 1-mean(mat,3);

figure(1)
func_plot_dendMat(mean(mat,3),tlbls);

dt = [];
for r = 1:13
    dt(:,r) = func_fit_RSA_model(squeeze(mean(cmats(:,:,r,:,:),5)),size_RDM);
end
clf;
func_plot_tbar_plot(dt,data.rlbs,0);%
%% Global vs Local
global_model = {{'Flora' 'Fruits & Veg' 'Food & Drink' 'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds'}
{'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials' 'Transport' 'Outdoors' 'Bodyparts'}};
global_model = {{'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds'} {'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials'}};
model_gl = func_made_RSA_model(tlbls,global_model);
model_gl(find(eye(length(model_gl)))) = 1;
load('/Users/aidasaglinskas/Desktop/mats/behav.mat')
%% Corr vs PartialCorr
dt = [];
dt2 = [];
for r = 1:13
    cmat_3d = squeeze(mean(cmats(:,:,r,:,:),5));
for s = 1:18
   v1 = squareform(1-cmat_3d(:,:,s))';
   v2 = squareform(1-size_RDM)';
   v3 = squareform(1-data.model)';
   v4 = squareform(1-model_gl)';
   v5 = squareform(nanmean(behav.RDM_RT,3))';
   v6 = squareform(nanmean(behav.RDM_Rating,3))';
   v7 = squareform(behav.RDM_RT(:,:,s))';
   v8 = squareform(behav.RDM_Rating(:,:,s))';
  
   dt(s,r) = corr(v1,v6,'rows','pairwise');
   dt2(s,r) = partialcorr(v1,v4,v3,'rows','pairwise');
end
end
func_plot_tbar_plot(dt(:,:),data.rlbs,0)
%%
% data.model
% size_RDM
% behav.RDM_RT

rlbls = {'AG-L' 'IPL-L' 'IPL-R' 'OFC-L' 'OFC-R' 'PHG-L' 'PHG-R' 'Prec.-M' 'RSC-L' 'RSC-R' 'pMTG-L' 'pMTG-R' 'vmPFC-L'};
clust = {'pMTG-L' 'pMTG-R' 'IPL-L' 'IPL-R' 'OFC-L' 'OFC-R'};
clust = {'AG-L' 'PHG-R' 'PHG-L' 'PHG-R' 'Prec.-M' 'RSC-L' 'RSC-R'  'vmPFC-L'};
%clust = rlbls;
clust = {'PHG-L' 'PHG-R' 'RSC-L' 'RSC-R'}
inds = ismember(rlbls,clust);
%inds = 1:13;
%inds = 1:13
% Build cmat
for s = 1:18
for b = 1:3
mat = data.mat(inds,:,s,b);
mat = mat - mat(:,18);
mat(:,[5 18]) = [];
%mat = mat - mean(mat,1);
cmat(:,:,s,b) = corr(mat);
end
end
% Fit model
cmat = mean(cmat,4);
%
% data.model
% size_RDM
% behav.RDM_RT

dt = func_fit_RSA_model(cmat,{data.model 1-size_RDM nanmean(behav.RDM_RT,3)});
func_plot_tbar_plot(dt,{'Sem' 'Size' 'RT'});
%% 5 let 
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
clust = {};
%clust{1} = {'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds'};
%clust{2} = {'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials'};
clust = {tlbls}
%
%(r,cat_ind,s,b_ind)
tcmat = [];rcmat = [];
for i = 1:length(clust);
inds = ismember(wikiClust.lbls,clust{i})';
for s = 1:18
for b = 1:3
mat = data.mat(:,inds,s,b);
%mat = mat - data.mat(:,18,s,b);
mat = mat-mean(mat,2);
tcmat(:,:,i,s,b) = corr(mat);
rcmat(:,:,i,s,b) = corr(mat');
end
end
end
%
i = 1;func_plot_dendMat({mean(mean(tcmat(:,:,i,:,:),5),4) mean(mean(rcmat(:,:,i,:,:),5),4)}, {tlbls(ismember(wikiClust.lbls,clust{i})') data.rlbs})

for i = 1:length(clust);
tiny_C = squeeze(mean(tcmat(:,:,i,:,:),5));
tiny_M = wikiClust.cmat(ismember(wikiClust.lbls,clust{i})',ismember(wikiClust.lbls,clust{i})');
model_ev = func_fit_RSA_model(tiny_C,tiny_M);
[H,P,CI,STATS] = ttest(model_ev);
t_statement(STATS,P);
end
%% NetRSA, 5let
%(r,cat_ind,s,b_ind)
load('/Users/aidasaglinskas/Desktop/netRSA_data.mat');
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat');
a = load('/Users/aidasaglinskas/Downloads/It_RDM_4AIDAS.mat');
data = netRSA_data;
%data.mat - data.mat(:,18,:,:);
data.tlbs([5 18]) = [];
data.mat(:,[5 18],:,:) = [];
data.leg = 'ROI|cat_ind|SUB|b_ind';
tlbls = data.tlbs;

rlbls = data.rlbs;

slice_cats = {'Clothes'
'Musical ins'
'Tools'
'Household'
'Materials'
'Transport'
'Outdoors'
'Bodyparts'}

length(slice_cats)
slice_ROIs = {   'AG-L'
    'IPL-L'
    'IPL-R'
    'OFC-L'
    'OFC-R'
    'PHG-L'
    'PHG-R'
    'Prec.-M'
    'RSC-L'
    'RSC-R'
    'pMTG-L'
    'pMTG-R'
    'vmPFC-L'}

cat_inds = ismember(tlbls,slice_cats);
ROI_inds = ismember(rlbls,slice_ROIs);
%

%bigmodel = func_made_RSA_model(netRSA_data.tlbs,{{'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds'} {'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials'}})
%clf;add_numbers_to_mat(bigmodel,tlbls)
data.mat = data.mat(ROI_inds,cat_inds,:,:);
data.model = data.model(cat_inds,cat_inds);
%data.model = bigmodel;
%data.model = 1-a.catMat(cat_inds,cat_inds);

rlbls = rlbls(ROI_inds);
tlbls = tlbls(cat_inds);
%
cmat = [];rcmat = [];
for s = 1:size(data.mat,3)
for b = 1:size(data.mat,4)
mat = data.mat(:,:,s,b);
%mat = mat - mat(:,18);
mat = mat-mean(mat,2);
%mat = zscore(mat,[],1);
%mat(:,[5 18]) = [];
cmat(:,:,s,b) = corr(mat);
rcmat(:,:,s,b) = corr(mat');
end
end
%

cmat_2d = mean(mean(cmat,4),3);
cmat_3d = mean(cmat,4);
%
figure(5)
func_plot_dendMat({cmat_2d mean(mean(rcmat,4),3)},{tlbls rlbls})
model_ev = func_fit_RSA_model(cmat_3d,data.model);
[H,P,CI,STATS] = ttest(model_ev,0,'tail','right');
subplot(2,2,1);title(t_statement(STATS,P),'fontsize',20)
netRSA_fit = func_fit_RSA_model(cmat_3d,data.model);
figure(6)
func_plot_dendMat(data.model,tlbls)
%w{2} = model_ev
%% Md plot
f = figure(5);
f.Color = [1 1 1];
clf;
Y = mdscale(1-cmat_2d,2);
spc=.12;
arrayfun(@(x) text(Y(x,1),Y(x,2),tlbls{x},'fontsize',16),1:length(Y));
xlim([min(Y(:,1))-spc max(Y(:,1)+spc)]);
ylim([min(Y(:,2)-spc) max(Y(:,2)+spc)]);
%%





%% Food knowledge

targ_t = {    'Animals-Water'
    'Animals-Insects'
    'Animals-Domestic'
    'Animals-Wild'
    'Animals-Birds'
    'Fruits & Veg'
    'Food & Drink'}

inds = find(ismember(tlbls,targ_t));
%disp(tlbls')
r = 1;
size(cmats)
clust = {{   'Animals-Water'
    'Animals-Insects'
    'Animals-Domestic'
    'Animals-Wild'
    'Animals-Birds'}
    {   'Fruits & Veg'
    'Food & Drink'}}
model = func_made_RSA_model(tlbls,clust);

dt = [];
for r = 1:13
m = squeeze(mean(cmats(:,:,r,:,:),5));
dt(:,r) = func_fit_RSA_model(m,model);
end
func_plot_tbar_plot(dt,data.rlbs,1)
%% Univariate
c = {};
c{1} = {'Fruits & Veg' 'Food & Drink'};
c{2} = {'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds'};
c{3} = {'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials'};
c{4} = {'Transport' 'Outdoors'};
leg = {'Food' 'Animals' 'Tools' 'Places'};
mat = [];
uselbls = data.tlbs;uselbls([5 18]) = [];
    addpath('/Users/aidasaglinskas/Downloads/pierremegevand-errorbar_groups-0e167a1/')
load('/Users/aidasaglinskas/Desktop/netRSA_data.mat');
data = netRSA_data;
data.mat = data.mat - data.mat(:,18,:,:);
data.mat(:,[5 18],:,:) = [];
for t = 1:length(c)
mat(:,t,:) = squeeze(mean(mean(data.mat(:,ismember(uselbls,c{t}),:,:),4),2));
end

m = mean(mat,3);
se = std(mat,[],3) ./ sqrt(18);

f = figure(3);clf;clc;
f.Color = [1 1 1];
try;[a b c] = errorbar_groups(m',se','FigID',3);catch;end

start = 2.5;xt = start;
for i = 1:12;xt(end+1) = start+i*4;end;f.CurrentAxes.XTick = xt

xticklabels(data.rlbs);
legend(leg)