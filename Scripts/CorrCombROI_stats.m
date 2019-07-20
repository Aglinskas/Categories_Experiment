load('CorrCombROI.mat')
load('wikiClust.mat')
load('tlbls')
load('rlbls')
%%
model = wikiClust.cmat;
target = res;
wh = 1:17;
for s = 1:19
    v1 = get_triu(target(wh,wh,s))';
    v2 = get_triu(model)';
    
    dt(s) = corr(v1,v2);
end
[H,P,CI,STATS] = ttest(dt);
%%
figure(1);clf
wh = 1:18
m = mean(target(wh,wh,:),3);
Y = 1-get_triu(m);
Z = linkage(Y,'ward');
sp = subplot(1,2,1);
[h x perm] = dendrogram(Z,'labels',tlbls(wh));
[h(1:end).LineWidth] = deal(2)
xtickangle(45);sp.FontSize = 12;sp.FontWeight = 'bold';

sp = subplot(1,2,2);
add_numbers_to_mat(m(perm,perm),tlbls(perm))
xtickangle(45);sp.FontSize = 12;sp.FontWeight = 'bold';


