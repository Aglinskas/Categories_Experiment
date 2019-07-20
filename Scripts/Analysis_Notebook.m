clear all; close all; clc;
tic
disp(datestr(datetime))
addpath('/Users/aidasaglinskas/Downloads/old/pierremegevand-errorbar_groups-0e167a1/')
%% Load up
% voxel data
    load('/Users/aidasaglinskas/Desktop/detrend_voxel_data.mat')
%load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/voxel_data_allvC.mat');
% ROI data
    load('/Users/aidasaglinskas/Desktop/detrend_roi_data.mat')
    %load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/roi_data_allVc.mat');
    %load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/searchlightROIs.mat')
roi_raw = roi_data;
% tlbls
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat');
tlbls_raw = tlbls;
% wiki Model
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/mats/wikiClust.mat')
% combData;
%comb = load('/Users/aidasaglinskas/Desktop/comb_voxel_data.mat');
comb = load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/voxel_data_comb.mat');
comb = comb.voxel_data;
%
%model = wikiClust.cmat; model(5,:) = [];model(:,5) = [];
wikiClust.cmat;wikiClust.cmat(:,5) = [];wikiClust.cmat(5,:) = [];wikiClust.lbls(5) = [];
%model = wikiClust;
roi_data.leg = 'ROI|CONDS|SUBS';
rlbls = voxel_data.mat_files; 

roi_data.tlbls = tlbls;
roi_data.rlbls = rlbls;


warning('off','stats:linkage:NotEuclideanMatrix')
disp('loaded and ready')
%% restrict tasks 
bool_restrict_tasks = 1;
if bool_restrict_tasks
    %t_names = {'Leisure' 'Tools' 'Animals-Wild' 'Animals-Insects'}
    t_names = {'Leisure'}
    t_drop = find(ismember(tlbls,t_names));
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

cc = 'control task';
cc_ind = find(strcmp(tlbls,cc));
roi_data.mat(:,cc_ind,:) = [];
voxel_data.dt(:,cc_ind,:) = [];
comb.dt(:,cc_ind,:) = [];
tlbls(cc_ind) = [];
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
roi_data.tlbls = tlbls';
t_ord = 1:length(roi_data.tlbls)
r_ord = 1:length(roi_data.rlbls)
%t_ord = [10 11 7 8 9 14 12 13 1 3 4 5 16 6 15 2];
%r_ord = [8 9 5 6 7 12 1 2 10 11 3 4];
%r_ord = 1:size(roi_data.mat,1);

%reorder

roi_data.mat = roi_data.mat(r_ord,t_ord,:);
roi_data.tlbls = roi_data.tlbls(t_ord);
roi_data.rlbls = roi_data.rlbls(r_ord);

comb.dt = comb.dt(:,t_ord,:);
comb.tlbls = roi_data.tlbls;


voxel_data.mat_files = voxel_data.mat_files(r_ord);
voxel_data.dt = voxel_data.dt(r_ord,t_ord,:);
voxel_data.tlbls = roi_data.tlbls;

wikiClust.cmat = wikiClust.cmat(t_ord,t_ord);
wikiClust.lbls = wikiClust.lbls(t_ord);

voxel_data
comb
roi_data
%% Task > Control Bar Plot
mm = squeeze(mean(roi_data.mat,2));
m = mean(mm,2);
se = std(mm,[],2) ./ sqrt(size(roi_data.mat,3));

[H,P,CI,STATS] = ttest(mm',0,'alpha',.05);
significant_inds = find(H);


figure(1);clf
h = bar(m);hold on;
e = errorbar(m,se,'r.');hold on;
xticklabels(roi_data.rlbls);
xtickangle(45);

nrois = size(roi_data.mat,1)
for i = 1:nrois
    if H(i)
text(i-.1,0,'*','fontsize',20);
    end
end

title('Overall engagement in task','FontSize',20)
hold off
%% Percentage Plot
figure(2)
inds = significant_inds;
inds = 1:12;
mat = roi_data.mat(inds,:,:);
rlbls = roi_data.rlbls(inds);
tlbls = roi_data.tlbls;

m = mean(mat,3);
%m(m<0) = 0;
%m = abs(m);
for i = 1:size(m,1)
m(i,:) + min(m(i,:)); % add the minimum value
m(i,:) = m(i,:) ./ sum(m(i,:)); % divide by sum
end

H = bar(m,'stacked');
xticklabels(rlbls);xtickangle(45);
ylim([0 1])
l = legend(tlbls,'Location','bestoutside');
title('Percentage of total signal elicited by each category','fontsize',20);
%% Semantic Model
clear stim
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/Jwiki.mat'); %wiki
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Stimulation_script/winList_man3.mat'); %finale

wiki.nouns = strrep(wiki.nouns,'-n','');

finale.final_list(:,[5 18]) = [];
finale.catNames([5 18]) = [];
finale.catNames = {'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials' 'Transport' 'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds' 'Fruits & Veg' 'Food & Drink' 'Flora' 'Outdoors' 'Bodyparts'};
inds = ismember(wiki.nouns,finale.final_list(:));
disp('perc words found');disp(sum(inds) ./ length(finale.final_list(:)) * 100);
wiki.dm_avg = wiki.dm_avg(inds,:);
wiki.nouns = wiki.nouns(inds);

stim.list = finale.final_list;
stim.catNames = finale.catNames;

pwd

tlbls = roi_data.tlbls;
ord = cellfun(@(x) find(strcmp(stim.catNames,x)),tlbls);
stim.catNames = stim.catNames(ord);
stim.list = stim.list(:,ord);

%plot --size 1000,500
figure(3)
wiki.dm_avg = log(wiki.dm_avg+1);

ncats = length(roi_data.tlbls);
for c = 1:ncats
cat_inds = ismember(wiki.nouns,stim.list(:,c));
cat_vec = mean(wiki.dm_avg(cat_inds,:),1);
catDM(c,:) = cat_vec;
end

catRSM = corr(catDM');
catlbls = stim.catNames;

res = func_plot_dendMat(catRSM,catlbls);
subplot(1,2,1);
title('Semantic model, corpus clustering','fontsize',20)

model = catRSM;
model_lbls = catlbls;

f = figure(9);
wiki.nouns = strrep(wiki.nouns,'-n','');
mat = log(wiki.dm_avg+1);
lbls = wiki.nouns;
Y = pdist(mat,'correlation');
Z = linkage(Y,'ward');
[h x perm] = dendrogram(Z,0,'labels',lbls,'ColorThreshold',1);
xtickangle(45);
f.Color = [1 1 1];
%% NetRSA
%r_inds = [significant_inds];
r_inds = 1:size(roi_data.mat,1)
%mat = roi_data.mat;
mat = roi_data.mat(r_inds,:,:);

lbls = {roi_data.tlbls roi_data.rlbls(r_inds)};
f = figure(1);
clear tcmats rcmats
for s = 1:size(roi_data.mat,3)
tcmats(:,:,s) = corr(mat(:,:,s));
rcmats(:,:,s) = corr(mat(:,:,s)');
end
NetRSA_tcmats = tcmats;
NetRSA_rcmats = rcmats;
tcmat = mean(tcmats,3);
rcmat = mean(rcmats,3);

mats = {tcmat rcmat};

% Plot
figure(4)
res = func_plot_dendMat(mats,lbls);
f.CurrentAxes.TickDir = 'out';
subplot(2,2,2);box off;
subplot(2,2,4);box off;
%% Model Fit
inds = 1:length(roi_data.rlbls);
%inds = significant_inds
wh_rois = voxel_data.mat_files(inds);
[cmat] = func_combroi(wh_rois,voxel_data);
data = cmat; 
model_fit = func_fit_RSA_model(data,model);
[H,P,CIb,STATS] = ttest(model_fit);
t_statement(STATS,P);

allCmats = [];
for inds = 1:length(voxel_data.mat_files);
wh_rois = voxel_data.mat_files(inds);
[cmat] = func_combroi(wh_rois,voxel_data);
allCmats(:,:,:,inds) = cmat;
data = cmat; 
model_fit = func_fit_RSA_model(data,model);
[H,P,CI,STATS] = ttest(model_fit);
end
%t_statement(STATS,P);
m_cmats = squeeze(mean(allCmats,3));
%% Show Brain Net?
p = 0;
if p 
figure
im_fn1 = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/BrainNet1.png';
im_fn2 = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/BrainNet2.png';
subplot(1,2,1)
imshow(imread(im_fn1))
subplot(1,2,2)
imshow(imread(im_fn2))
end
%%
figure(5);clf
tasks{1} = {'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds' 'Fruits & Veg' 'Food & Drink' 'Flora'};
tasks{1} = tlbls(ismember(tlbls,tasks{1}))
tasks{2} = {'Clothes' 'Musical ins' 'Tools' 'Household' 'Materials' 'Transport' 'Outdoors'}; % 'Bodyparts'
tasks{2} = tlbls(ismember(tlbls,tasks{2}))
tasks_lbls = {};
tasks_lbls{1} = 'Living';
tasks_lbls{2} = 'Non-Living';

%disp(roi_data.rlbls(res.ord{2})')
ROIs{1} =  {'RSc-L' 'RSc-R' 'PHG-L' 'PHG-R' 'Prec-M' 'vmPFC-M'}; % 
ROIs{2} =  {'IPL-L' 'IPL-R' 'pMTG-L' 'pMTG-R' 'OFC-L' 'OFC-R'}; % 

%ROIs{1} = {'PHG-L'    'PHG-R'    'EVC-L'    'IFG-L'    'pMTG_ITG-L'    'OFC-L'};
%ROIs{2} = {'AG-L'    'Prec-M' 'AG-R'    'IPS-L'    'dmPFC-L'    'dmPFC-M'};
ROIs_lbls{1} = 'Medial';
ROIs_lbls{2} = 'Lateral';

%ROIs{1} =  {'VTC-L' 'VTC-R' 'AG-L' 'ATL-L' 'Prec-M' 'vmPFC-M' }; % 
%ROIs{2} =  {'IFG-L' 'OFC-L' 'dmPFC-L' 'pMTG-L'}; % 
ROIs_lbls{1} = 'Medial';
ROIs_lbls{2} = 'Lateral';

rlbls = roi_data.rlbls;
tlbls = roi_data.tlbls;
mat = roi_data.mat;
clear cmats bcmats tiny_model_evidence model_evidence
for r = 1:length(ROIs)
for t = 1:length(tasks)
r_inds = ismember(rlbls,ROIs{r});
t_inds = ismember(tlbls,tasks{t});

% univariate response
redmat(r,t,:) = mean(mean(mat(r_inds,t_inds,:),1),2);

% multivariate
vx = voxel_data;
vx.dt = vx.dt(:,t_inds,:);vx.tlbls = vx.tlbls(t_inds);
wh_rois = ROIs{r};
tiny_cmat = func_combroi(wh_rois,vx);



tt = cellfun(@(x) find(strcmp(wikiClust.lbls,x)),tasks{t});
tiny_model = wikiClust.cmat(tt,tt);
tiny_model = wikiClust.cmat(t_inds,t_inds);
tiny_model_evidence(:,r,t) = func_fit_RSA_model(tiny_cmat,tiny_model);

cmat = func_combroi(wh_rois,voxel_data);
%model_evidence(:,r) = func_fit_RSA_model(cmat,wikiClust.cmat);
tiny_model_evidence(:,r,3) = func_fit_RSA_model(cmat,wikiClust.cmat);
end
end

m = mean(redmat,3);
sd = std(redmat,[],3);

% Univariate Bar
%bar(m);
errorbar_groups(m',sd')
xticklabels(ROIs_lbls);
legend(tasks_lbls);
title('Mean Beta Response','fontsize',20)
[H,P,CI,STATS] = ttest(tiny_model_evidence,0,'alpha',.05);

%ttest(squeeze(tiny_model_evidence(:,2,2)),squeeze(tiny_model_evidence(:,2,3)))
%f = figure(10);add_numbers_to_mat(squeeze(P),tasks_lbls,ROIs_lbls);f.CurrentAxes.CLim = [.049 .05];

%
figure(8);clf
m = squeeze(mean(tiny_model_evidence));
se = squeeze(std(tiny_model_evidence,[],1)) ./ sqrt(STATS.df(1,1)+1);

bar(m);hold on;
errorbar(m,se,'r.');hold off
errorbar_groups(m',se');
xticklabels(ROIs_lbls);
tasks_lbls{3} = 'All Semantic';
legend(tasks_lbls,'location','bestoutside');
title('Model Fit','fontsize',20);
%%
figure(12)
t = 1;r = 1;
i = r;
%t_inds = ismember(tlbls,tasks{t});
t_inds = 1:16
vx = voxel_data;
vx.dt = vx.dt(:,t_inds,:);vx.tlbls = vx.tlbls(t_inds);
wh_rois = ROIs{r};
tiny_cmat = func_combroi(wh_rois,vx);
func_plot_dendMat(mean(tiny_cmat,3),vx.tlbls);
subplot(1,2,1);title(strjoin(ROIs{i},','),'fontsize',20)
%%
figure(6)
wh_roi = voxel_data.mat_files{1};
wh_tasks = {'Animals-Birds' 'Animals-Wild' 'Food & Drink' 'Fruits & Veg' 'Tools' 'Clothes'};
tind = find(ismember(tlbls,wh_tasks));
rind = find(strcmp(voxel_data.mat_files,wh_roi));

use_data = voxel_data;
use_data.dt = use_data.dt(:,tind,:);
use_data.tlbls = use_data.tlbls(tind);

cmat = func_combroi({wh_roi},use_data);

%plot --size 1000,500
func_plot_dendMat(mean(cmat,3),use_data.tlbls);
subplot(1,2,1);title([wh_roi ' RSA'],'fontsize',20)
%% Model fit to individual regions. 
clear cmats m se H
for i = 1:length(voxel_data.mat_files)
wh_rois = voxel_data.mat_files(i);
cmat = func_combroi(wh_rois,voxel_data);
model_evidence = func_fit_RSA_model(cmat,model);
[h,P,CI,STATS] = ttest(model_evidence);

cmats(i,:,:,:) = cmat;
m(i) = mean(model_evidence);
se(i) = std(model_evidence) ./ sqrt(STATS.df+1);
tvals(i) = STATS.tstat;
H(i) = h;
end
%
figure(7);clf
bar(m); hold on;
errorbar(m,se,'r.'); hold off;
%
nrois = size(roi_data.mat,1)
for i = 1:length(m)
    if H(i)
text(i-.1,0,'*','fontsize',20);
    end
end


xticklabels(voxel_data.mat_files);
title('Semantic Model Fit By region','fontsize',20)
%% Combine groups
wh_tasks = {{'Animals-Wild' 'Animals-Birds'} {'Animals-Insects' 'Animals-Domestic'} {'Fruits & Veg' 'Food & Drink'} {'Tools' 'Household'} {'Transport' 'Outdoors'}}
wh_tasks_leg = {'Animals-outside' 'Animals-inside' 'Food' 'Tools' 'Places'}
dt = [];
for w = 1:5
dt(:,w,:) = mean(roi_data.mat(:,ismember(roi_data.tlbls,wh_tasks{w}),:),2);
end


perc_mat = mean(dt,3);
perc_mat = perc_mat - min(perc_mat,[],2);
perc_mat = perc_mat + 1;
perc_mat = perc_mat ./ sum(perc_mat,2);


bar(perc_mat,'stacked')
legend(wh_tasks_leg,'location','bestoutside')
ylim([0 1]);
xticklabels(roi_data.rlbls);
xtickangle(45)
%%
a = get(0,'children');
for i = 1:length(a)
a(i).Color = [1 1 1]
end
%%
model_fit = [];
for i = 1:length(voxel_data.mat_files);
wh_rois = voxel_data.mat_files(i);
[cmats] = func_combroi(wh_rois,voxel_data);
model_fit(:,i) = func_fit_RSA_model(cmats,wikiClust.cmat);
end
[H,P,CI,STATS] = ttest(model_fit);

figure(10);clf
m = mean(model_fit);
se = std(model_fit) ./ sqrt(18);
bar(m); hold on
errorbar(m,se,'r.'); hold off
xticklabels(roi_data.rlbls);xtickangle(45);
arrayfun(@(x) text(x-.1,0,'*','fontsize',30),find(H))
title('Regional Model Fit','fontsize',20)
%% Multivariate taxonomy
nrois =  length(voxel_data.mat_files);
cmats = [];
for i = 1:nrois
    wh_rois = voxel_data.mat_files(i);
    cmats(:,:,:,i) = func_combroi(wh_rois,voxel_data); 
end
mcmats = squeeze(mean(cmats,3));
figure(11)
rcmat = [];
for s = 1:size(cmats,3)
for r1 = 1:nrois
for r2 = 1:nrois
   rcmat(r1,r2,s) = corr(get_triu(cmats(:,:,s,r1))',get_triu(cmats(:,:,s,r2))'); 
end
end
end
func_plot_dendMat(mean(rcmat,3),voxel_data.mat_files);
title('Multivariate Dendrogram')
%%
load('/Users/aidasaglinskas/Desktop/Clutter/Categories_Experiment/Binder_data/Binder.mat')
sum(ismember(binder.noun_labels,wiki.nouns));
%% Binder Clust
% c = {'animal' 'body part' 'food' 'instrument' 'place' 'plant' 'tool'};
% clc;
% 
% cmat = [];
% for c1 = 1:length(c)
% for c2 = 1:length(c)
%     v1 = mean(binder.rating_mat(strcmp(binder.category,c{c1}),:));
%     v2 = mean(binder.rating_mat(strcmp(binder.category,c{c2}),:)); 
%     cmat(c1,c2) = corr(v1',v2')
% end
% end
% figure(13)
% func_plot_dendMat(cmat,c)

%%
toc