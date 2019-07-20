load('combROItcmat_corr.mat')
load('wikiClust.mat')
load('decodingRSA.mat','res');res = squeeze(res(1:17,1:17,16,:));
load('tlbls')
%%
model = wikiClust.cmat;
%target = res;
target = tcmats
for s = 1:19
    v1 = get_triu(model)';
    v2 = get_triu(target(:,:,s))';
    data(s) = corr(v1,v2);
end
[H,P,CI,STATS] = ttest(data)
%%
temp = 't(%d) = %.2f, p = %.4f';
clc;
disp(sprintf(temp,STATS.df,STATS.tstat,P));
%%
f = figure(1);clf
sp = subplot(1,2,1)
cmat = squeeze(mean(target,3));
Y = get_triu(cmat);
Z = linkage(Y,'ward');
[h x perm] = dendrogram(Z,'labels',tlbls(1:17));
[h(1:end).LineWidth] = deal(2);
xtickangle(45)

sp = subplot(1,2,2);
add_numbers_to_mat(cmat(perm,perm),tlbls(perm));
sp.CLim = [min(get_triu(cmat)) max(get_triu(cmat))];