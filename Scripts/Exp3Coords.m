load('/Users/aidasaglinskas/Desktop/voxel_data.mat')
load('/Users/aidasaglinskas/Desktop/roi_data.mat')
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat');
roi_data.leg = 'ROI|CONDS|SUBS';
%% Drop Leisure
roi_data.mat(:,5,:)= [];
voxel_data.dt(:,5,:) = [];
tlbls(5) = [];
%% Subtract CC
roi_data.mat = roi_data.mat - roi_data.mat(:,17,:);
roi_data.mat(:,17,:) = [];
voxel_data.dt(:,17,:) = [];
tlbls(17) = [];
%% Retrict ROIs
rlbls = voxel_data.mat_files;
wh_rois = ~ismember(1:length(rlbls),[1 2 16 17 11 12]);
rlbls_leg = arrayfun(@(x) [num2str(x,'%.2i') ' : ' rlbls{x}],1:length(rlbls),'UniformOutput',0)';

roi_data.mat = roi_data.mat(wh_rois,:,:);
voxel_data.dt = voxel_data.dt(wh_rois,:,:);
rlbls = rlbls(wh_rois);
%%
lbls = {tlbls rlbls};
%%%%%%%%%%%% Analysis %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NetRSA
figure(1)
clear tcmats rcmats
for s = 1:size(roi_data.mat,3)
tcmats(:,:,s) = corr(roi_data.mat(:,:,s));
rcmats(:,:,s) = corr(roi_data.mat(:,:,s)');
end
tcmat = mean(tcmats,3);
rcmat = mean(rcmats,3);

mats = {tcmat rcmat};
cc = 0;
for i = 1:2;
cc = cc+1;;sp = subplot(2,2,cc)
Y = 1-get_triu(mats{i});
Z = linkage(Y,'ward');
[h x perm] = dendrogram(Z,'labels',lbls{i});
ord = perm(end:-1:1);
[h(1:end).LineWidth] = deal(2);
xtickangle(45)

cc = cc+1;;sp = subplot(2,2,cc)
add_numbers_to_mat(mats{i}(ord,ord),lbls{i}(ord))
end
%% Voxel RSA
figure(2)

clear mat cmat
for s = 1:size(voxel_data.dt,3)
for r = 1:size(voxel_data.dt,1)
    mat = cell2mat(voxel_data.dt(r,:,s)');
    tcmat(:,:,r,s) = corr(mat');
end
end

rcmat = [];
for s = 1:size(tcmat,4);
for r1 = 1:size(tcmat,3);
for r2 = 1:size(tcmat,3);
    rcmat(r1,r2,s) = corr(get_triu(tcmat(:,:,r1,s))',get_triu(tcmat(:,:,r2,s))');
end
end
end

mtcmat = mean(mean(tcmat,4),3);
mrcmat = mean(rcmat,3);
size(mcmat)

mats = {mtcmat mrcmat};
cc = 0;
for i = 1:2;
cc = cc+1;;sp = subplot(2,2,cc)
Y = 1-get_triu(mats{i});
Z = linkage(Y,'ward');
[h x perm] = dendrogram(Z,'labels',lbls{i});
ord = perm(end:-1:1);
[h(1:end).LineWidth] = deal(2);
xtickangle(45)

cc = cc+1;;sp = subplot(2,2,cc)
add_numbers_to_mat(mats{i}(ord,ord),lbls{i}(ord))
end





