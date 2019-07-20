%% Filepaths
fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_norm/BigOut/%d_out.nii';
svec = 1:20;
    svec([9 12]) = [];
    roi_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/';
    roi_fls = dir([roi_dir '*.nii']);
roi_fls = {roi_fls.name}';
rlbls = roi_fls;
rlbls = strrep(rlbls,'ROI_','');
rlbls = strrep(rlbls,'.nii','');
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat')
tlbls([5 18]) = []
%% 
cmat = [];
for s = 1:18;
subID = svec(s);
for r = 1:7;
clc;disp([s r])
ds = cosmo_fmri_dataset(sprintf(fn_temp,subID),'mask',fullfile(roi_dir,roi_fls{r}));
cmat(:,:,r,s) = squareform(mean(ds.samples,2));
end
end
save('/Users/aidasaglinskas/Desktop/forElisaDecodingRDMs.mat','cmat','tlbls','rlbls');
%% Mean Category Decoding
clear;
load('/Users/aidasaglinskas/Desktop/forElisaDecodingRDMs.mat')
resmat = [];
for r = 1:length(rlbls);
for s = 1:18
mat = cmat(:,:,r,s);
for c = 1:16
vec = find([1:16]~=c);
resmat(c,r,s) = mean(mat(c,vec));
end
end
end
%% Plot Per ROI decoding
figure(1);
for r = 1:7
subplot(3,3,r)
mat = squeeze(resmat(:,r,:));
func_plot_tbar_plot(mat'-.5,tlbls);
title(rlbls{r},'fontsize',20);
end
%% Overall Category decodability
figure(2)
func_plot_tbar_plot(squeeze(mean(resmat,2))'-.5,tlbls)
%%