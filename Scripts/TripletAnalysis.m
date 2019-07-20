brain_mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis_18_3mm/mask.nii'
roi_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/';
roi_fls = dir([roi_dir '*.nii']);
roi_fls = {roi_fls.name}';
dt_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/RSA_searchlight2/%d.mat';
%%
for s_ind = 1:18;
dt_fn = sprintf(dt_temp,s_ind);
for r_ind = 1:length(roi_fls);
clc;disp([s_ind r_ind])
mask_fn = fullfile(roi_dir,roi_fls{r_ind});
load(dt_fn); % Loads subject dataset

mask = cosmo_fmri_dataset(mask_fn,'mask',brain_mask_fn);
for b = 1:3;
RDM_map3d_beta = RDM_map3d;
RDM_map3d_beta.samples = RDM_map3d_beta.samples(:,:,b);

RDM_map3d_beta.sa = struct;
ds = cosmo_slice(RDM_map3d_beta,mask.samples~=0,2);

cmat(:,:,r_ind,s_ind,b) = 1-squareform(mean(ds.samples,2));
end
end
end
%save('/Users/aidasaglinskas/Desktop/tripletdata.mat');
%%
size(cmat)
%cmat: 16    16     7    18     3
%%
for r = 1
for s = 1
    

for c1 = 1
for c2 = 2
for b1 = 1:3
for b2 = 1:2
        



end
end
end
end


end
end
%%




