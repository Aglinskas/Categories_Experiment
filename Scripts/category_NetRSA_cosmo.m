load('all_ds26.mat')
load('tlbls')
load('rlbls');rlbls = strrep(rlbls,'_','-');
CatNames_eng = tlbls;
load('subvec')
load('catVec')
%subvec = find(~ismember([1:20],[9 12]));
%catVec = find(~ismember([1:18],[5]));
disp('loaded and ready')
%%
voxel_data = {};
abeta = []; 
for m = 1:24%length(all_ds);
    clc;disp(m);
for s = 1:length(subvec);
    subID = subvec(s);
for c_ind = 1:length(catVec);
    c = catVec(c_ind);
ds = all_ds{m};
ds = cosmo_slice(ds,ds.sa.subID==subID);
ds = cosmo_remove_useless_data(ds);
for i = 1:2
    dim = 2; % default, 2
ds.samples(ds.sa.run_ind==i,:) = zscore(ds.samples(ds.sa.run_ind==i,:),[],dim);
end

ds = cosmo_slice(ds,ds.sa.cond_index==c);
vec = mean(ds.samples,1);
voxel_data.mat{m,c_ind,s} = vec;
abeta.mat(m,c_ind,s) = mean(vec);
end
end
end
voxel_data.leg = 'mat|condition|subject'
disp('done')
%% Voxel Check
length_mat = [];
wh_m = 1:size(voxel_data.mat,1)
for i = wh_m
for j = 1:18
    length_mat(i,j) = length(voxel_data.mat{i,16,j});
end
end
add_numbers_to_mat(length_mat,rlbls(wh_m));
xticks([]);
xlabel('n voxels','fontsize',20);
%% Big Cmat
cmat = [];
disp('running')
for s = 1:size(voxel_data.mat,3);
for r = 1:size(voxel_data.mat,1);
for c1 = 1:16;
for c2 = 1:16;
v1 = voxel_data.mat{r,c1,s}';
v2 = voxel_data.mat{r,c2,s}';
v1 = v1-voxel_data.mat{r,17,s}';
v2 = v2-voxel_data.mat{r,17,s}';
cmat(r,c1,c2,s) = corr(v1,v2);
end
end
end
end
%sum(isnan(cmat(:)))
disp('done')
%% Task Clustering
wh_rois = 1:24;
wh_rois = [ 3     4     5     6     7     8    11    12    13    14    15    16    17    23 24]
tcmats = squeeze(mean(cmat(wh_rois,:,:,:),1));
%% ROI clustering
a = [];
wh_cats = 1:16;
for s = 1:size(cmat,4)
for r = 1:size(cmat,1)
a(:,r,s) = get_triu(squeeze(cmat(r,wh_cats,wh_cats,s)))';
end
end
rcmats = [];
for s = 1:size(cmat,4)
rcmats(:,:,s) = corr(a(:,:,s));
end
%% Plot Dendrograms
figure(1);
tcmat = mean(tcmats,3);
rcmat = mean(rcmats(wh_rois,wh_rois,:),3);
m = {rcmat tcmat};
%l = {strrep(masks.lbls,'ROI_','') CatNames_eng(1:17)};
l = {rlbls(wh_rois) CatNames_eng(catVec(1:16))};
c = 0;
for i = 1:2
c = c+1;
sp = subplot(2,2,c);

Y = 1-get_triu(m{i});
Z = linkage(Y,'ward');
[h x perm] = dendrogram(Z,'labels',l{i});
[h(1:end).LineWidth] = deal(2);
sp.FontSize = 12;sp.FontWeight = 'bold';
ord = perm;
xtickangle(45)
c = c+1;
sp = subplot(2,2,c);
add_numbers_to_mat(m{i}(ord,ord),l{i}(ord))
sp.FontSize = 12;sp.FontWeight = 'bold';sp.CLim = [[min(get_triu(m{i})) max(get_triu(m{i}))]];
xtickangle(45)
end
%%
figure(2)
load('./mats/wikiClust.mat')
model = wikiClust.cmat(catVec(1:16),catVec((1:16)));
for m_ind = 1:size(rcmats,1)
for s_ind = 1:size(rcmats,3)
mat = cmat(m_ind,:,:,s_ind);
mat = squeeze(mat);
v1 = get_triu(mat)';
v2 = get_triu(model)';
dt(m_ind,s_ind) = corr(v1,v2);
end
end
m = mean(dt,2);
sd = std(dt,[],2) ./ sqrt(18);
clf
sp = subplot(2,1,1);
bar(m); hold on;
errorbar(m,sd,'r.'); hold on;
xlim([1-.5 length(m)+.5]);
xticks(1:length(m));
xticklabels(rlbls(1:length(m)));
xtickangle(45);
sp = subplot(10,1,6);
[H,P,CI,STATS] = ttest(dt');
add_numbers_to_mat(STATS.tstat);
xlim([1-.5 length(m)+.5]);
sp.CLim = [1.95 1.96];
%%
figure(3)
for m_ind = 1:26;
m = squeeze(mean(abeta.mat(m_ind,:,:),3));
sd = squeeze(std(abeta.mat(m_ind,:,:),[],3)) ./ sqrt(18);
subplot(7,4,m_ind);
bar(m);hold on;
errorbar(m,sd,'r.');hold off;
xticks(1:length(m));xticklabels(tlbls(catVec));xtickangle(45);
title(rlbls(m_ind),'fontsize',14);
end