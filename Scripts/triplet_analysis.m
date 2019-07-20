load('/Users/aidasaglinskas/Desktop/pre_stacked_scans.mat','all_scans');
roi_input_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/';
brain_mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis_18_3mm/mask.nii';
fls = dir([roi_input_dir '*.nii']);
fls = {fls.name}';

svec = 1:20; svec([9 12]) = [];
%
tic

% Center data. 
all_scans.samples = all_scans.samples - mean(all_scans.samples,1)
    %clf;plot(all_scans.samples([1 100 400 900],:)')
RSMs = [];
pairs = nchoosek(1:18,2);
for r_ind = 1:length(fls);
mask = cosmo_fmri_dataset(fullfile(roi_input_dir,fls{r_ind}),'mask',brain_mask_fn);
voxel_inds = logical(mask.samples);
ROI_ds = cosmo_slice(all_scans,voxel_inds,2);
for s_ind = 1:length(svec);
    clc;disp([r_ind s_ind]);toc
subID = svec(s_ind);
SUB_ds = cosmo_slice(ROI_ds,ROI_ds.sa.subID==subID,1);
    %c_ind = 1
    %b_ind = 1;
for p_ind = 1:size(pairs,1);
pair_DS = cosmo_slice(SUB_ds,ismember(SUB_ds.sa.cond_index,pairs(p_ind,:)),1);
    ch_v = [1 2 3 1 2 3];
    if ~all(arrayfun(@(x) pair_DS.sa.b_ind(x)==ch_v(x),1:6)) ~size(pair_DS.samples,1)==6; error('something wrong');end
    cmat = corr(pair_DS.samples');
    
    within1 = 1-squareform(1-cmat(1:3,1:3));
within1_m = mean(within1);
    within2 = 1-squareform(1-cmat(4:6,4:6));
within2_m = mean(within2);
    across = cmat(1:3,4:6);
across_m = mean(across(:));
across_m = mean(across(find(eye(3))));
pl = 0;
if pl
%pairs(p_ind,:)
subplot(1,2,1)
add_numbers_to_mat(cmat);drawnow
subplot(1,2,2)
bar([within1_m within2_m across_m])
xticklabels({'W1' 'W2' 'A'})
ylim([-1 1]);
drawnow
end

                %measure = ((across_m ./ within1_m) + (across_m ./ within2_m)) / 2; %% TRY this measure, more RFX

%measure = mean([((across_m+1) ./ (within1_m+1)) ((across_m+1) ./ (within2_m+1))]);
measure = across_m;
%measure = measure-1;
                %measure = ((across_m+min([within1_m within2_m across_m])) ./ (within1_m+min([within1_m within2_m across_m]))) + ((across_m+min([within1_m within2_m across_m])) ./ (within2_m+min([within1_m within2_m across_m]))) / 2

%measure = across_m / (within1_m+within2_m);

if measure > 100; error('WHAAAAAT');end
    
RSMs(pairs(p_ind,1),pairs(p_ind,1),s_ind,r_ind) = 1;
RSMs(pairs(p_ind,2),pairs(p_ind,2),s_ind,r_ind) = 1;
RSMs(pairs(p_ind,1),pairs(p_ind,2),s_ind,r_ind) = measure;
RSMs(pairs(p_ind,2),pairs(p_ind,1),s_ind,r_ind) = measure;

end
% Normalise SUB/ROI
%RSMs(:,:,s_ind,r_ind) = RSMs(:,:,s_ind,r_ind) ./ max(max(RSMs(:,:,s_ind,r_ind)));
%add_numbers_to_mat(RSMs(:,:,s_ind,r_ind))
end
end
disp('ALL DONE')
clf;hist(RSMs(:))
RSMs_raw = RSMs;
%%
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat');
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat');
model = wikiClust.cmat;
tlbls18 = tlbls;
rlbls = fls;
    rlbls = strrep(rlbls,'ROI_','');
    rlbls = strrep(rlbls,'.nii','');

RSMs = RSMs_raw;
drop = [5 18];RSMs(drop,:,:,:) = [];RSMs(:,drop,:,:) = [];tlbls = tlbls18;tlbls(drop) = [];
%%
figure(1)
i = 3;
func_plot_dendMat((mean(RSMs(:,:,:,i),3)),tlbls);
title(rlbls{i},'fontsize',20)
%%
figure(2)
dt = [];
for r = 1:7
    dt(:,r) = func_fit_RSA_model(RSMs(:,:,:,r),model);
end
clf;func_plot_tbar_plot(dt,rlbls);