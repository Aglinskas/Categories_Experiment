roi_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_Jneuro/blobs/';
space = mars_space('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis_18_3mm/beta_0008.nii');
fls = dir([roi_dir 'Se*']);
roi_fls = {fls.name}';

all_blobs = [];
for i = 1:length(roi_fls)
    clear roi 
    load(fullfile(roi_dir,roi_fls{i}));
    if isempty(all_blobs);
        all_blobs = roi;
    else
        all_blobs = all_blobs | roi;
    end
end
ofn = fullfile(roi_dir,'combined.mat');
saveroi(all_blobs,ofn); %
mars_rois2img(ofn,strrep(ofn,'.mat','.nii'),space); %