load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/searchlight_data.mat');
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat');
sd.mat(:,:,:,[9 12]) = [];
sd.mat = sd.mat-.5

%r_ord = [ 6 3 4 11 14 16 15 1 5 12 7 2 10 13 8 9 17]';
sd.mat = sd.mat(:,:,r_ord,:);
sd.rlbls = sd.rlbls(r_ord)
disp('done')
i = 0;
%%
i = i+1
%
%m = mean(sd.mat(:,:,i,:),4);
mn = squeeze(sd.mat(:,:,i,:));
mn = squeeze(mean(mn,2));
se = std(mn,[],2)% ./ sqrt(18);
m = mean(mn,2);
%se = std(sd.mat(:,:,i,:),[],4) ./ sqrt(18);
add_numbers_to_mat(m,sd.tlbls)
%func_plot_dendMat(1-m,sd.tlbls)
%
clf;
[H,P,CI,STATS] = ttest(mn,0,'dim',2,'alpha',.05);
bar(m);hold on
errorbar(1:16,m,m-CI(:,1),m-CI(:,2),'r.');hold on
%
xticks(1:16)
xlim([0 17])
xticklabels(sd.tlbls)
xtickangle(45)
title(sd.rlbls{i},'fontsize',20)
arrayfun(@(x) text(x-.1,0,'*','fontsize',30),find(H));
%% T matrix
clf
mat = sd.mat;
for i = 1:16
    mat(i,i,:,:) = NaN;
end
mat = squeeze(nanmean(mat,1));
[H,P,CI,STATS] = ttest(mat,0,'dim',3,'alpha',.001);
add_numbers_to_mat(H',sd.rlbls,sd.tlbls)
%% Model Fit 
v2 = get_triu(wikiClust.cmat)';
[za mat] = get_Z_atlas(linkage(1-v2','ward'));
v2 = get_triu(mat);
fitMat = []
for r = 1:size(sd.mat,3)
for s = 1:size(sd.mat,4)
    v1 = get_triu(sd.mat(:,:,r,s))';
    [za mat] = get_Z_atlas(linkage(v1','ward'));
    v1 = get_triu(mat);
    
fitMat(r,s) = corr(v1',v2');
end
end

[H,P,CI,STATS] = ttest(fitMat,0,'dim',2,'tail','both');
m = mean(fitMat');
clf
bar(m);hold on;
errorbar(1:length(H),m,m'-CI(:,1),m'-CI(:,2),'r.')
arrayfun(@(x) text(x-.1,0,'*','fontsize',30),find(H))

xticks(1:length(m));
xticklabels(sd.rlbls);
xtickangle(45)
%% Network Taxonomy

cmat = [];
for r1 = 1:size(sd.mat,3)
for r2 = 1:size(sd.mat,3)
for s = 1:size(sd.mat,4)
    v1 = get_triu(sd.mat(:,:,r1,s))';
    v2 = get_triu(sd.mat(:,:,r2,s))';
    cmat(r1,r2,s) = corr(v1,v2);
end
end
end
func_plot_dendMat(mean(cmat,3),sd.rlbls)
%%