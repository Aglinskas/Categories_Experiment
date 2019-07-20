load('all_scans_ROIs.mat');
load('subvec.mat');
load('cat_names.mat');
t = {    'Clothes'    'Musical ins'    'Tools'    'Household'    'Leisure'  'Materials'    'Transport' 'Animals-Water'    'Animals-Insects'    'Animals-Domestic' 'Animals-Wild'    'Animals-Birds'    'Fruits & Veg' 'Food & Drink'    'Flora' 'Outdoors'    'Bodyparts' 'control task'};
%%
cmat = zeros(18,18,19);
for s = subvec
    clc;disp(s)
for c1 = 1:18;
for c2 = c1+1:18;
%clc;disp([s c1 c2])
inds1 = all_scans.sa.subID==s & all_scans.sa.cond_index==c1;
inds2 = all_scans.sa.subID==s & all_scans.sa.cond_index==c2;

v1 = cosmo_slice(all_scans,inds1);
v1 = cosmo_remove_useless_data(v1);
v1.samples = zscore(v1.samples,[],2);
v1.samples = mean(v1.samples,1);

v2 = cosmo_slice(all_scans,inds2);
v2 = cosmo_remove_useless_data(v2);
v2.samples = zscore(v2.samples,[],2);
v2.samples = mean(v2.samples,1);
cmat(c1,c2,s) = corr(v1.samples',v2.samples');
%imagesc(cmat(:,:,s));drawnow;
end
end
end
%% Cluster
lbls = t;
Y = 1-get_triu(mean(cmat,3));
Z = linkage(Y,'ward');
[h x perm] = dendrogram(Z,'labels',lbls);
xtickangle(45);


