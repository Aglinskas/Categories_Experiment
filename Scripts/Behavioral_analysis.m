code_root = '/Users/aidasaglinskas/Desktop/Categories_Experiment/';
load(fullfile(code_root,'/Scripts/subvec.mat'))
load(fullfile(code_root,'/Scripts/mats/cat_names.mat'))
cat_names([5 18]) = [];
%%
mt_fn_temp = fullfile(code_root,'/fMRI_Data/S%d/S%.2i_P1_myTrials_fixed.mat');
subvec = 1:20;
subvec([9 12]) = []
for s = 1:length(subvec);
subID = subvec(s);
mt_fn = sprintf(mt_fn_temp,subID,subID);
myTrials = [];
load(mt_fn);

if max([myTrials.response]) > 4; error('wat');end

for c = 1:16
   inds = find(strcmp({myTrials.CatName},cat_names{c}));
   resp(s,c) = nanmean([myTrials(inds).response]);
   cell_resp{s,c} = [myTrials(inds).response];
   RT(s,c) = nanmean([myTrials(inds).RT]);
   cell_RT{s,c} = [myTrials(inds).RT];
end
end % ends subs

behav.mat_rt = RT;
behav.mat_resp = resp;
behav.lbls = cat_names;
%save('/Users/aidasaglinskas/Desktop/behav.mat','behav')
%% Bar Plot
mRT  = nanmean(RT);
%mRT = mRT-mean(mRT)
eRT = nanstd(RT);
mresp = nanmean(resp);
%mresp = mresp-mean(mresp)
eresp = nanstd(resp);
%
figure(1);clf;

subplot(2,1,1);hold on
bar(mRT);;errorbar(mRT,eRT,'r.')
title('Reaction Times','fontsize',16)
xticks(1:17);xticklabels(cat_names);xtickangle(45)

subplot(2,1,2);hold on
bar(mresp);;errorbar(mresp,eresp,'r.')
title('Responses','fontsize',16)
xticks(1:17);xticklabels(cat_names);xtickangle(45)
%%
%resp RT
for s = 1:size(resp,1)
distmat_resp(:,:,s) = squareform(pdist(resp(s,:)'));
distmat_RT(:,:,s) = squareform(pdist(RT(s,:)'));
end

behav.RDM_RT = distmat_RT;
behav.RDM_Rating = distmat_resp;
%save('/Users/aidasaglinskas/Desktop/behav.mat','behav')
%% Pdist
m = {nanmean(distmat_resp,3), nanmean(distmat_RT,3)};
m_ind = 2;
lbls = cat_names;
Y = get_triu(m{m_ind});
Z = linkage(Y,'ward');

d = figure(2);
[h x perm] = dendrogram(Z,'labels',lbls(1:17));
[h(1:end).LineWidth] = deal(2);
xtickangle(45)
d.CurrentAxes.FontSize = 12;
d.CurrentAxes.FontWeight = 'bold';
%% Catecory similarity: Correlations
nsubs = size(cell_RT,1);
ncats = size(cell_RT,2);
for s = 1:nsubs
for c1 = 1:ncats
for c2 = 1:ncats
 mat1(c1,c2,s) = corr(cell_RT{s,c1}',cell_RT{s,c2}','rows','pairwise');
 mat2(c1,c2,s) = corr(cell_resp{s,c1}',cell_resp{s,c2}','rows','pairwise');
end
end
end
% Means
mmat1 = nanmean(mat1,3)
mmat2 = nanmean(mat2,3)

clf;c = 0;
lbls = cat_names(1:17);

mats = {mmat1 mmat2}
ttls = {'Reaction Times' 'RT cormat' 'Responses' 'response cormat'};
for i = 1:2
mat = mats{i};
Y = 1-get_triu(mat);
Z = linkage(Y,'ward');

c = c+1;
sp = subplot(2,2,c);
[h x perm] = dendrogram(Z,'labels',lbls);
sp.Title.String = ttls{c}
sp.Title.FontSize = 14;
    [h(1:end).LineWidth] = deal(2);
    sp.FontSize = 12;
    sp.FontWeight = 'bold';
    xtickangle(45);


c = c+1;sp = subplot(2,2,c);
add_numbers_to_mat(mat(perm,perm),lbls(perm))
sp.Title.String = ttls{c}
sp.Title.FontSize = 14;
end
%%

tmat = [];
mat = behav.mat_rt;
for t1 = 1:17;
for t2 = 1:17;
   [H,P,CI,STATS] = ttest(mat(:,t1),mat(:,t2),'alpha',.0);
    %tmat(t1,t2) = STATS.tstat;
    tmat(t1,t2) = H;
end
end

squeeze(P)


figure(3)
add_numbers_to_mat(triu(tmat),behav.lbls)
%%

nl = [1 2 3 4 6 7 16 17];
l = [8 9 10 11 12 13 14 15]
[H,P,CI,STATS] = ttest(nanmean(behav.mat_rt(:,nl),2),nanmean(behav.mat_rt(:,l),2));
t_statement(STATS,P)


