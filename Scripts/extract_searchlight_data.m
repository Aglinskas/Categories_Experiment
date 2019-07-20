load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat')
ROI_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_norm/Searchlight_ROIs/';
ROI_fls = dir([ROI_fn '*.nii']);
ROI_fls = {ROI_fls.name}';
ROI_lbls = ROI_fls;
    ROI_lbls = strrep(ROI_lbls,'ROI_','');
    ROI_lbls = strrep(ROI_lbls,'.nii','');
%%
conds = find([1:17]~=5);
pairs = nchoosek(conds,2);
dt_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_norm/BigOut/%d_out.nii';
%%
res = [];
for m_ind = 1:length(ROI_fls);
for s_ind = svec';
clc;disp([m_ind s_ind]);
m_fn = fullfile(ROI_fn,ROI_fls{m_ind});
dt_fn = sprintf(dt_fn_temp,s_ind);

ds = cosmo_fmri_dataset(dt_fn,'mask',m_fn);

mn = mean(ds.samples,2); % means

mat = [];
for i = 1:length(pairs)
    mat(pairs(i,1),pairs(i,2)) = mn(i);
    mat(pairs(i,2),pairs(i,1)) = mn(i); 
end

res(:,:,m_ind,s_ind) = mat;
add_numbers_to_mat(mat);drawnow;
end % ends sub
end % ends m
%%
leg = 'C1|C2|ROI|SUB';
searchlight_data = [];
searchlight_data.mat = res;
searchlight_data.leg = leg;
searchlight_data.tlbls = tlbls;
searchlight_data.rlbls = ROI_lbls;
%%
searchlight_data.mat(:,5,:,:) = [];
searchlight_data.mat(5,:,:,:) = [];
searchlight_data.tlbls(18) = [];
searchlight_data.tlbls(5) = [];
%%
sd = searchlight_data;
save('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/searchlight_data.mat','sd')
