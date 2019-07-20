load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat');
ROI_fn = '/Users/aidasaglinskas/Desktop/testSemNS/'
ROI_fls = 'Semcombined.nii'
sd = func_extract_searchlight_RDM(ROI_fn,{ROI_fls});
%%
spm_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis_18_3mm/';
roi_dir  = ROI_fn;
[roi_data voxel_data] = func_extract_data_from_ROIs_cats(roi_dir,spm_dir)

voxel_data.dt(:,[5],:) = [];

for s = 1:18
for c = 1:17
voxel_data.dt{1,c,s} = voxel_data.dt{1,c,s} - voxel_data.dt{1,end,s};
end
end
voxel_data.dt(:,end,:) = [];
%%
clc;figure(3);clf
cmat = squeeze(mean(sd.mat,4));
cmats = squeeze(sd.mat);

cmats = func_combroi({'Semcombined'},voxel_data);
cmat = mean(cmats,3)


func_plot_dendMat(cmat,sd.tlbls)
%func_plot_dendMat(wikiClust.cmat,sd.tlbls)
%%
model_fit = func_fit_RSA_model(cmats,wikiClust.cmat);
[H,P,CI,STATS] = ttest(model_fit);
t_statement(STATS,P);