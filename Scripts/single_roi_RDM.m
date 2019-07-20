%load('CorrMVPACmats');
load('wikiClust.mat');
load('rlbls');
load('tlbls');
%%
f = figure(1)
r_ind = 15;

wh = 1:17;

mat = squeeze(mean(cmat(r_ind,wh,wh,:),4));

Y = 1-get_triu(mat);
Z = linkage(Y,'ward');
[h x perm] = dendrogram(Z,'labels',tlbls(wh));
[h(1:end).LineWidth] = deal(2);
xtickangle(45);
f.CurrentAxes.FontSize =12
f.CurrentAxes.FontWeight = 'bold'
title(rlbls(r_ind),'fontsize',20);
