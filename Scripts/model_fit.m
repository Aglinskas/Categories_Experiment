load('netRSA.mat')
load('wikiClust.mat')
%%
for r = 1:15
for s = 1:19
mat = squeeze(netRSA.all_cmat(r,:,:,s));
model = wikiClust.cmat;
data(r,s) = corr(get_triu(mat)',get_triu(model)');
end
end
%%
figure(1);clf

m = mean(data');
sd = std(data');
rlbls = netRSA.rlbls;
    bar(m);
    hold on;
    errorbar(m,sd,'r.')
    xticks(1:15);
    xticklabels(rlbls);