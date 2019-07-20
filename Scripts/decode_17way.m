clear
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/all_ds_workspace.mat','all_ds','masks');
a = load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/all_ds_workspace_comb.mat','all_scans')
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/cat_names.mat');
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/subvec.mat');
all_ds{16} = a.all_scans
masks.lbls = [{'L-ATL'}    {'L-Angular'}    {'L-MTG'}    {'L-IFG'}    {'L-OFC'} {'L-ITG'}    {'Prec.'}    {'R-ATL'}    {'R-Angular'}    {'R-MTG'} {'R-ITG'}    {'R-IFG'}    {'R-OFC'}    {'dmPFC'}    {'vmPFC'} {'all ROIs comb'}];
%%
for m = 1:16
    clc;disp([m 16])
for s = 1:length(subvec)    
subID = subvec(s);
ds = all_ds{m};

ds = cosmo_slice(ds,ds.sa.subID==subID);
%ds = cosmo_slice(ds,ds.sa.cond_index~=18);
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

res(m,s) = accuracy;
end
end
res_backup = res;
%% Plot Results
figure(1);clf
chance = 1/length(unique(ds.sa.targets));
res = res-chance
results_mean = mean(res,2);
results_sd = std(res,[],2) ./sqrt(19);
r_lbls = masks.lbls;
[H,P,CI,STATS] = ttest(res',0,'alpha',.05);

subplot(2,1,1)
bar(results_mean);hold on
errorbar(1:16,results_mean,results_sd,'r.');hold off
%errorbar(1:15,results_mean,CI(1,:),CI(2,:),'r.');hold off
%ylim([0 1]);
xlim([.5 16.5])
xticks([1:16]);
xticklabels(r_lbls);
[n i] = max(results_mean);

ttl = {'Max decoding' [r_lbls{i}  ' ' num2str(n,'%.4f')]};
title(ttl,'fontsize',14);

sp = subplot(10,1,6);
add_numbers_to_mat(STATS.tstat);
sp.CLim = [1.95 1.96];
title('t values')
xticks([])
yticks([])