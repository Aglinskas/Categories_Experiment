roi_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROI_files/';
spm_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis3/';
roi_data = func_extract_data_from_ROIs_cats(roi_dir,spm_dir);
disp('done')
ofn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/roi_data.mat';
save(ofn,'roi_data')