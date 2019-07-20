load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/roi_coords.mat');


coords = roi_coords.coords;
names = roi_coords.lbls;
ofn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_allVsC/';
sph_radius = 7.5;
func_makeROIsFromCoords_cats(coords,names,ofn,sph_radius)
%%
roi_dir = ofn;
spm_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis3_18subs/SPM.mat';
roi_data = func_extract_data_from_ROIs_cats(roi_dir,spm_dir)
%%
