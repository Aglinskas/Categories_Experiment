function func_makeROIsFromCoords(coords,names,ofn,sph_radius)
%func_makeROIsFromCoords(coords,names,ofn,sph_radius)
%coords = mc.coords
%names = mc.lbls
%ofn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_allVsC/'
%sph_radius = 6
%% Paths and file links
addpath('/Users/aidasaglinskas/Documents/MATLAB/marsbar/')
space_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis3_18subs/beta_0009.nii';
addpath(genpath('/Users/aidasaglinskas/Documents/MATLAB/spm12/toolbox/marsbar/'));
blobs_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/Blobs_allVc16_p01/';
%blobs_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/Blobs_Detrend_05/';
blobs_fn = 'Blobs_combined_roi.mat';
blobs_path = fullfile(blobs_dir,blobs_fn);
%% Combine Blobs and Covert Blobs
if ~exist(ofn)
    mkdir(ofn)
else
    delete([ofn '*'])
end
space = mars_space(space_fn);
%% Get Blobs
if exist(blobs_path)
masks.all_blobs = load(blobs_path);
combine_blobs = 0;
else
temp = dir([blobs_dir '*_ROI.mat']);
if isempty(temp);error('no blobs found');end
blobs_fn = {temp.name}';
all_blobs = [];
for i = 1:length(blobs_fn);
clear roi 
    load(fullfile(blobs_dir,blobs_fn{i}));
    if isempty(all_blobs);
        all_blobs = roi;
    else
        all_blobs = all_blobs | roi;
    end
end
saveroi(all_blobs,[blobs_dir 'Blobs_combined_roi.mat']); %
mars_rois2img([blobs_dir 'Blobs_combined_roi.mat'],[blobs_dir 'Blobs_combined.nii'],space); %
masks.all_blobs = load(blobs_path);
end
%% Draw and Treshold ROIs
all_rois = [];
for i = 1:length(names);
%escape pSTS and Angular;
   this_sphere = maroi_sphere(struct('centre',coords(i,:),'radius', sph_radius));
    if isempty(all_rois); all_rois = this_sphere;end 
            % if ~isempty(strfind(names{i},'Angular'))
            % this_sphere = this_sphere & masks.all_blobs.roi & masks.AG.roi;
            % all_rois = all_rois | this_sphere;
            % disp('Angular Detected, Special Treatment')
            % elseif ~isempty(strfind(names{i},'pSTS'))
            % this_sphere = this_sphere & masks.all_blobs.roi & masks.psts.roi;
            % all_rois = all_rois | this_sphere;    
            % disp('pSTS Detected, Special Treatment')
            % else
            % end
this_sphere = this_sphere & masks.all_blobs.roi;
all_rois = all_rois | this_sphere;

ofn_nm = [ofn 'ROI_' names{i} '.mat'];
saveroi(this_sphere,ofn_nm);
mars_rois2img(ofn_nm,strrep(ofn_nm,'.mat','.nii'),space)
end

saveroi(all_rois,[ofn 'ROIs_Combined.mat'])    
mars_rois2img([ofn 'ROIs_Combined.mat'],[ofn 'Combined_ROIs.nii'],space)
%% RoiSizes
rep = []
RoiSizes = 1;
v = [];
if RoiSizes == 1
r_list = dir([ofn '*.nii']);
r_list = {r_list.name}';
for i = 1:length(r_list)
temp =  cosmo_fmri_dataset(fullfile(ofn,r_list{i}));
v(i) = sum(temp.samples); 
rep = arrayfun(@(x) [r_list{x} ':' num2str(v(x))],1:length(v),'UniformOutput',0)';
end
end
[Y I] = sort(v,'descend');
disp(rep(I));