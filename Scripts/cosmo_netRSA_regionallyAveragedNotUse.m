load('all_ds_workspace.mat');
load('subvec.mat');
load('rlbls')
load('tlbls');CatNames_eng = tlbls
%%
voxel_data = {};
abeta = [];
for m = 1:15;
    clc;disp(m);
    %ds = all_ds{m};
for s = 1:19;
    subID = subvec(s);
for c = 1:18;
ds = all_ds{m};
ds = cosmo_slice(ds,ds.sa.subID==subID);
ds = cosmo_remove_useless_data(ds);

% for i = 1:2
% ds.samples(ds.sa.run_ind==i,:) = zscore(ds.samples(ds.sa.run_ind==i,:),[],2);
% end

ds = cosmo_slice(ds,ds.sa.cond_index==c);
vec = mean(ds.samples,1);
voxel_data.mat{m,c,s} = vec;
abeta.mat(m,c,s) = mean(vec);
end
end
end
%sum(isnan(abeta.mat(:)))
%sum(isnan([voxel_data.mat{:}]))
disp('done')
%%
abeta.mat;
[tcmats,rcmats] = deal([]);
wh = 1:18;
for s = 1:19
    tcmats(:,:,s) = corr(abeta.mat(:,:,s));
    rcmats(:,:,s) = corr(abeta.mat(:,wh,s)');
end
%% Plot
tcmat = mean(tcmats(wh,wh,:),3);
rcmat = mean(rcmats,3);

m = {rcmat tcmat};
%l = {strrep(masks.lbls,'ROI_','') CatNames_eng(1:18)};
l = {rlbls(1:15) CatNames_eng(wh)};
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
end