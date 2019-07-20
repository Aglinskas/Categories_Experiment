deccomb = load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/all_ds_comb.mat')
dec15 = load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/decodingRSA_15.mat')
corRSA = load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/netRSA.mat')
wiki = load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat')
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/rlbls.mat')
load('CorrCombROI.mat')
%load('PanNet.mat')
%%
%target{1} = mean(corRSA.netRSA.tcmats,3);
%model = wiki.wikiClust.cmat;
wh = 1:17;
%target = dec15.res(wh,wh,:,:);
target = squeeze(mean(dec15.res(1:17,1:17,:,:),3))
target = permute(corRSA.netRSA.all_cmat,[2 3 1 4]);
%% ROI Corr
for m = 1:15
for s = 1:19
    v1 = get_triu(target(:,:,m,s))';
    v2 = get_triu(model)';
    mat(m,s) = corr(v1,v2);
    %plot(v1,v2,'.');lsline;pause
end
end
m = mean(mat,2);
s = std(mat,[],2) / sqrt(19);
[H,P,CI,STATS] = ttest(mat');
%% Overall Corr
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
model = wikiClust.cmat;
%target = squeeze(mean(dec15.res(1:17,1:17,:,:),3));
target = netRSA.tcmats;
%target = squeeze(res(1:17,1:17,16,:));

for s = 1:19
   v1 = get_triu(target(:,:,s))';
   v2 = get_triu(model)';
   dt(s) = corr(v1,v2);
end
[H,P,CI,STATS] = ttest(dt)
%%
figure(1);clf;

subplot(2,1,1);
bar(m);hold on;
errorbar(m,s,'r.');hold off;
ylabel('correlation values')
xticks(1:15)
xticklabels(rlbls);
xtickangle(45);
xlim([.5 15.5])
sp = subplot(10,1,6);
add_numbers_to_mat(STATS.tstat);
xticks([]);yticks([]);
sp.CLim = [1.95 1.96];
ylabel('T values')
%% Plot Wiki RSM
f = figure(1);
sp = subplot(1,2,1)
wiki.wikiClust.cmat;
Y = 1-get_triu(wiki.wikiClust.cmat);
Z = linkage(Y,'ward');
[h x perm] = dendrogram(Z,'labels',tlbls(1:17));
sp.FontSize = 13;sp.FontWeight = 'bold';
[h(1:end).LineWidth] = deal(3);

xtickangle(45);
sp = subplot(1,2,2);
add_numbers_to_mat(wiki.wikiClust.cmat(perm,perm),tlbls(perm));

sp.FontSize = 13;sp.FontWeight = 'bold';
title('Wiki RSM')
%% 
figure(1)
mat = mean(dec15.res(:,:,5,:),4);
mat = mat(1:17,1:17)-.5
Y = get_triu(mat);
Z = linkage(Y,'ward');
[h x perm] = dendrogram(Z,'labels',tlbls(1:17))
[h(1:end).LineWidth] = deal(2)
xtickangle(45)
ylim([-.01 max(Z(:,3))+.01])
%%
figure(2);
add_numbers_to_mat(mat(perm,perm),tlbls(perm))
%%



