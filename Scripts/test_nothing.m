mats
%%
load('roi_data.mat');
%roi_data.mat = roi_data.mat - roi_data.mat(:,18,:);
roi_data.mat = roi_data.mat(:,1:17,:);
lbls = cat_names(1:17)
cmat = [];
for s = 1:19
    cmat(:,:,s) = corr(roi_data.mat(:,:,s));
end

figure(1)
mcmat = mean(cmat,3);
Y = 1-get_triu(mcmat);
Z = linkage(Y,'ward');
dendrogram(Z,'labels',lbls);
xtickangle(45);
%%
corr(get_triu(mcmat)',get_triu(mats{2})')