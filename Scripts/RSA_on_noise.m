for perm = 1:1000
clc;disp(perm)
rand_roi_data = [];
for s = 1:size(roi_data.mat,3)
for m = 1:size(roi_data.mat,1)
rand_roi_data(m,:,s) = Shuffle(roi_data.mat(m,:,s));
end
end

for s = 1:size(roi_data.mat,3)
    rdata_noise(:,:,s) = corr(rand_roi_data(:,:,s)');
end

mnoise = mean(rdata_noise,3);
Z = linkage(1-get_triu(mnoise),'ward');
c = cluster(Z,2);
%func_plot_dendMat(mnoise,mat_lbls)

clust_noise = {};
clust_noise{end+1} = mat_lbls(c==1)';
clust_noise{end+1} = mat_lbls(c==2')';
model_noise = func_made_RSA_model(mat_lbls,clust_noise);

for s = 1:size(rdata_noise,3)
    v1 = get_triu(rdata_noise(:,:,s))';
    v2 = get_triu(model_noise)';
    dt(s) = corr(v1,v2);
end

[H,P,CI,STATS] = ttest(dt);
tval = STATS.tstat;

t_collect(perm) = tval;

end
%%
histogram(t_collect,'Normalization','pdf')
%histogram(t_collect)
box off
% count probability pdf