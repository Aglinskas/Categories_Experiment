load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Data.mat');

drop_rois = [1 6 7 9 10 12 13 14 16 17]
keep_rois = find(~ismember(1:18,drop_rois))
rlbls = {'AG' 'IPL' 'Prec' 'PHG' 'RSC' 'dlPFC' 'pMTG' 'vmPFC'};
%%
roi_data.mat = roi_data.mat(keep_rois,:,:);
roi_data = rmfield(roi_data,'lbls');
roi_data.mat(:,5,:) = []
roi_data.rlbls = rlbls;
roi_data.leg = 'ROI|CAT|SUB';

voxel_data.dt = voxel_data.dt(keep_rois,:,:);
voxel_data.mat_files = rlbls;
voxel_data.dt(:,5,:) = []

sd.mat(5,:,:,:) = [];
sd.mat(:,5,:,:) = [];
sd.mat = sd.mat(:,:,keep_rois,:);
sd.rlbls = rlbls
sd.tlbls(5) = [];
sd.aDS = sd.aDS(keep_rois,:)

save('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Data2.mat','roi_data','voxel_data','sd');