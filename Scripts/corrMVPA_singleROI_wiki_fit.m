load('CorrMVPACmats');
load('wikiClust.mat');
load('rlbls');
%%
for m = 1:15
for s = 1:19
    v1 = get_triu(squeeze(cmat(m,:,:,s)))';
    v2 = get_triu(wikiClust.cmat)';
    dt(m,s) = corr(v1,v2);
end
end
%%

mean_corr = mean(dt,2);
std_corr = std(dt,[],2) ./ sqrt(19);

figure(1);clf
subplot(2,1,1);
bar(mean_corr);hold on;
errorbar(mean_corr,std_corr,'r.');hold off;
xlim([.5 15.5])
xticks(1:15);xticklabels(rlbls);


[H,P,CI,STATS] = ttest(dt');
sp = subplot(10,1,6);
add_numbers_to_mat(P);
xticks(1:15);xticklabels(rlbls);
sp.CLim = [.04 .05];
colormap('parula');





