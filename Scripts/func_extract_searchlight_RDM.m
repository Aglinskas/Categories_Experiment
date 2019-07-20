function sd = func_extract_searchlight_RDM(ROI_fn)
% function sd = func_extract_searchlight_RDM(ROI_fn,ROI_fls)
% load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat')
%ROI_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/';
ROI_fls = dir([ROI_fn '*.nii']);
ROI_fls = {ROI_fls.name}';
ROI_lbls = ROI_fls;
ROI_lbls = strrep(ROI_lbls,'ROI_','');
ROI_lbls = strrep(ROI_lbls,'.nii','');

dt_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_2mm/BigOut/d%d_out.nii';
%%
ROI_lbls = strrep(ROI_fls,'ROI_','');
ROI_lbls = strrep(ROI_fls,'.nii','');
%conds = find([1:17]~=5);
conds = 1:18;
svec = [ 1 2 3 4 5 6 7 8 10 11 13 14 15 16 17 18 19 20];
tlbls = {'Clothes'    'Musical ins'    'Tools'    'Household'    'Leisure'    'Materials' 'Transport'    'Animals-Water'    'Animals-Insects'    'Animals-Domestic' 'Animals-Wild'    'Animals-Birds'    'Fruits & Veg'    'Food & Drink'    'Flora' 'Outdoors'    'Bodyparts'    'control task'}
pairs = nchoosek(conds,2);
%%
res = [];
aDS = {};
for m_ind = 1:length(ROI_fls);
    
for s_ind = svec;
    
clc;disp([m_ind s_ind]);
m_fn = fullfile(ROI_fn,ROI_fls{m_ind});
dt_fn = sprintf(dt_fn_temp,s_ind);

ds = cosmo_fmri_dataset(dt_fn,'mask',m_fn);
aDS{m_ind,s_ind} = ds;
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
searchlight_data.aDS = aDS;
searchlight_data.aDS_leg = 'ROI|SUB';
%%
%searchlight_data.mat(:,5,:,:) = [];
%searchlight_data.mat(5,:,:,:) = [];
%searchlight_data.tlbls(18) = [];
%searchlight_data.tlbls(5) = [];
%%
sd = searchlight_data;
sd.mat(:,:,:,find(~ismember(1:max(svec),svec))) = [];
%save('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/searchlight_data.mat','sd')
