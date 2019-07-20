roi_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/';
fls = dir([roi_dir '*.nii']);
fls = {fls.name};
lbls = fls;
lbls = strrep(lbls,'ROI_','');
lbls = strrep(lbls,'.nii','');
dt_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/RSA_searchlight/';
dt_fls = dir([dt_dir '*_avg.nii']);
dt_fls = {dt_fls.name}';

data = [];
for s = 1:length(dt_fls)
    dt_fn = fullfile(dt_dir,dt_fls{s});
for i = 1:length(fls);
    clc;disp([s i])
   mask_fn = fullfile(roi_dir,fls{i});
   ds = cosmo_fmri_dataset(dt_fn,'mask',mask_fn);
   data(s,i) = mean(ds.samples);
end
end
%
figure(3)
func_plot_tbar_plot(data,lbls)
%%

coords = [-6 -64 31]; % t val, 3.44
%coords = [-15 -55 34.40]; % t val 5.55

%spm_mip_ui('SetCoords',coords)

%addpath('/Users/aidasaglinskas/Documents/MATLAB/spm12/toolbox/marsbar/');

sph_widths = 6;
roi = maroi_sphere(struct('centre', coords, ...
                'radius', sph_widths));

spc = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_2mm/6m.nii';
%spc = '/Users/aidasaglinskas/Desktop/Matlab_Neurosynth/single_subj_T1.nii'
ofnmat = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/test/roi.mat';
ofnnii = strrep(ofnmat,'.mat','.nii');
saveroi(roi,ofnmat);
% mars_rois2img(ofnmat,ofnnii);
mars_rois2img(ofnmat,ofnnii,mars_space(spc));

a = load_nii(ofnnii);
sum(a.img(:))
%%
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
roi_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/test/';
spm_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis_18_3mm/'
[roi_data voxel_data] = func_extract_data_from_ROIs_cats(roi_dir,spm_dir);

if size(voxel_data.dt,2) > 16
voxel_data.dt(:,[5 18],:) = [];
end

if length(tlbls) > 16
tlbls([5 18]) = [];
end

%tlbls([5 18]) = []
model = wikiClust.cmat;

cmats = func_combroi(voxel_data.mat_files,voxel_data);
figure(3)
func_plot_dendMat(mean(cmats,3),tlbls);

model_ev = func_fit_RSA_model(cmats,model);
[H,P,CI,STATS] = ttest(model_ev);
t_statement(STATS,P);
%% Manually Get
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/test/PrecDS')
%all_scans.samples = zscore(all_scans.samples,[],2)

cats = unique(all_scans.sa.cond_index');
subs = unique(all_scans.sa.subID');
vx = [];
for s = 1:length(subs)
for c = 1:length(cats)
for b = 1:3
%vx(c,s,b,:)

slice = all_scans.sa.subID==subs(s) & all_scans.sa.cond_index==cats(c) & all_scans.sa.b_ind==b;
if sum(slice) ~=1; error('something wong');end

ds = cosmo_slice(all_scans,slice);
vx(c,s,b,:) = ds.samples;
end
end
end

plot(vx(:));
xlim([1 length(vx(:))]);
%
cmat = [];
for c1 = 1:size(vx,1)
for c2 = 1:size(vx,1)
for s = 1:size(vx,2)
for b = 1:size(vx,3)
   v1 = vx(c1,s,b,:);
    v1 = squeeze(v1);
   v2 = vx(c2,s,b,:);
    v2 = squeeze(v2);
cmat(c1,c2,s,b) = corr(v1,v2);
end
end
end
end
cmat(:,[5 18],:,:) = [];
cmat([5 18],:,:,:) = [];

model_ev = func_fit_RSA_model(mean(cmat,4),model);
[H,P,CI,STATS] = ttest(model_ev);
t_statement(STATS,P)
%%
model_ev = [];
for i = 1:3
model_ev(:,i) = func_fit_RSA_model(cmat(:,:,:,i),model);
end

[H,P,CI,STATS] = ttest(mean(model_ev,2));
t_statement(STATS,P)
%%
cmat = [];
vxm = mean(vx,3);
for c1 = 1:size(vx,1)
for c2 = 1:size(vx,1)
for s = 1:size(vx,2)
   v1 = vxm(c1,s,:);
    v1 = squeeze(v1);
   v2 = vxm(c2,s,:);
    v2 = squeeze(v2);
cmat(c1,c2,s) = corr(v1,v2);
end
end
end
cmat(:,[5 18],:,:) = [];
cmat([5 18],:,:,:) = [];

model_ev = func_fit_RSA_model(mean(cmat,4),model);
[H,P,CI,STATS] = ttest(model_ev);
t_statement(STATS,P)