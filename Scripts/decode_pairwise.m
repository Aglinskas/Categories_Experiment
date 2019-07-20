fls = {'all_ds26.mat'	'catVec.mat'	'rlbls.mat'	'subvec.mat'	'tlbls.mat'};
cellfun(@load,fls);
%%
pairs = nchoosek(1:18,2);
res = []
for m = 17%:15
for pair_ind = 1:length(pairs)
    clc;disp([m 15 pair_ind length(pairs)])
    this_pair = pairs(pair_ind,:);
for s = 1:length(subvec)
subID = subvec(s);
ds = all_ds{m};

ds = cosmo_slice(ds,ds.sa.subID==subID);
ds = cosmo_slice(ds,ismember(ds.sa.cond_index,this_pair));
ds = cosmo_remove_useless_data(ds);
% Set Targets and chunks
ds.sa.chunks = ds.sa.b_ind;
ds.sa.targets = ds.sa.cond_index;

for i = 1:3
dim = 2;
ds.samples(ds.sa.b_ind==i,:) = zscore(ds.samples(ds.sa.b_ind==i,:),[],dim);
end

% for i = 1:2
% dim = 2;
% ds.samples(ds.sa.run_ind==i,:) = zscore(ds.samples(ds.sa.run_ind==i,:),[],dim);
% end

opt = struct;
partitions = cosmo_nfold_partitioner(ds.sa.chunks);
classifier = @cosmo_classify_lda;
dataset = ds;

[pred, accuracy] = cosmo_crossvalidate(dataset, classifier, partitions, opt);

res(this_pair(1),this_pair(2),m,s) = accuracy;
res(this_pair(2),this_pair(1),m,s) = accuracy;
end
end
end
res_backup = res;
disp('all done')
%save('decodingRSA_15.mat')
%% Plot Single
r_ind = 18;
m = mean(res(w_t,w_t,r_ind,:),4);
lbls = tlbls(w_t);
sp = subplot(1,2,1)
Y = get_triu(m);
Z = linkage(Y,'ward');

[h x perm] = dendrogram(Z,'labels',lbls);
[h(1:end).LineWidth] = deal(2)
sp.FontSize = 12;sp.FontWeight = 'bold';
xtickangle(45)
sp = subplot(1,2,2)
add_numbers_to_mat(m(perm,perm),lbls(perm))
sp.TickDir = 'out';
sp.FontSize = 12;sp.FontWeight = 'bold';
title(rlbls(r_ind),'fontsize',14)
%% T statistics
a = permute(squeeze(res(w_t,w_t,r_ind,:)),[3 1 2]);
a = a-.5
[H,P,CI,STATS] = ttest(a);
tmat = squeeze(STATS.tstat);
f = figure(2)
add_numbers_to_mat(tmat(perm,perm),tlbls(w_t(perm)))
f.CurrentAxes.CLim = [3 3.1]
%%
load('wikiClust.mat');
c = []
w_t = catVec(1:16);
for s = 1:18
    c(s) = corr(get_triu(wikiClust.cmat(w_t,w_t))',get_triu(1-squeeze(res(w_t,w_t,r_ind,s)))');
end
[H,P,CI,STATS]  = ttest(c);
clc;disp(sprintf('t(%d) = %.2f, p = %.4f',STATS.df,STATS.tstat,P))
%%
wt = 1:17;
for s = 1:19
for r1 = 1:15
for r2 = 1:15
   rcmat(r1,r2,s) = corr(get_triu(res(wt,wt,r1,s))',get_triu(res(wt,wt,r2,s))');
end
end
end
%%
clf;
f = figure(1);
mrcmat = mean(rcmat,3);
Y = 1-get_triu(mrcmat);
Z = linkage(Y,'ward');
subplot(1,2,1)
[h x perm] = dendrogram(Z,'labels',rlbls(1:15));
[h(1:end).LineWidth] = deal(2);
xtickangle(45);
f.CurrentAxes.FontSize = 14;
f.CurrentAxes.FontWeight = 'bold';

sp = subplot(1,2,2);
add_numbers_to_mat(mrcmat(perm,perm),rlbls(perm));
sp.CLim = [min(get_triu(mrcmat)) max(get_triu(mrcmat))];
%%
tf = figure(2);
[H,P,CI,STATS] = ttest(permute(rcmat,[3 1 2]));
tmat = squeeze(STATS.tstat);
tmat(find(eye(size(tmat)))) = 0;

add_numbers_to_mat(tmat(perm,perm),rlbls(perm));
tf.CurrentAxes.CLim = [1.95 1.96]
%%


