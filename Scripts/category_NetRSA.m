% Collect
spm_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis3/';
roi_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROI_files/';
roi_data = func_extract_data_from_ROIs_cats(roi_dir,spm_dir);
disp('done')
%%
%load('roi_data.mat')
load('cat_names.mat')
roi_data.legend = arrayfun(@(x) [num2str(x,'%.2i') ':' roi_data.lbls{x}],1:length(roi_data.lbls),'UniformOutput',0)';
roi_data.tlabels = cat_names;
roi_data.tlabels =  {    'Clothes'    'Musical ins'    'Tools'    'Household'    'Leisure'  'Materials'    'Transport' 'Animals-Water'    'Animals-Insects'    'Animals-Domestic' 'Animals-Wild'    'Animals-Birds'    'Fruits & Veg' 'Food & Drink'    'Flora' 'Outdoors'    'Bodyparts' 'control task'};
%% Single
r_ind = r_ind + 1;
mat = squeeze(roi_data.mat(r_ind,:,:));
mat = mat - mat(end,:)
figure(4)
m = mean(mat,2);
s = std(mat,[],2) / sqrt(20);

bar(m);hold on;
errorbar(m,s,'r.');hold off
title(roi_data.lbls{r_ind},'fontsize',20)
xticks(1:18)
xticklabels(roi_data.tlabels)
xtickangle(45)
%% RSA
figure(4);clf
amat = roi_data.mat;
clear tcmats rcmats
for s_ind = 1:size(amat,3);
smat = amat(:,:,s_ind);
tcmats(:,:,s_ind) = corr(smat);
rcmats(:,:,s_ind) = corr(smat');
end

tcmat = mean(tcmats,3);
rcmat = mean(rcmats,3);

m = {rcmat tcmat};
l = {roi_data.lbls roi_data.tlabels};
c = 0;
for i = 1:2
c = c+1;
subplot(2,2,c)
Y = 1-get_triu(m{i});
Z = linkage(Y,'ward');
[h x perm] = dendrogram(Z,'labels',l{i});
ord = perm;
xtickangle(45)
c = c+1;
subplot(2,2,c)
add_numbers_to_mat(m{i}(ord,ord),l{i}(ord))
end
%%
f = figure(2)
check_mat = mean(amat,3) ./ std(amat,[],3);
add_numbers_to_mat(check_mat,roi_data.tlabels,roi_data.lbls);
%f.CurrentAxes.CLim = [-1.95 1.96]
%%
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
load('decodingRSA.mat','res')
model = wikiClust.cmat;
target = squeeze(res(1:17,1:17,16,:));
for s = 1:19
   v1 = 1-get_triu(target(:,:,s))';
   v2 = get_triu(model)';
   dt(s) = corr(v1,v2);
end
[H,P,CI,STATS] = ttest(dt)
%%





%save('PanNet.mat','rcmats','tcmats')