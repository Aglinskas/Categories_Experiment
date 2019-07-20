% Masks
mask_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_Jneuro/ROIs/';
mask_fls = dir([mask_dir '*.nii']);
mask_fls = {mask_fls.name}';
mask_lbls = mask_fls;
mask_lbls = strrep(mask_lbls,'ROI_','');
mask_lbls = strrep(mask_lbls,'.nii','');
% 
svec = find(~ismember([1:20],[9 12]));
sub_SPM_dir_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/Analysis3/';
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/mats/cat_names.mat')
%%
clc
allDs = {};
for m_ind = 1:length(mask_lbls);
m_fn = fullfile(mask_dir,mask_fls{m_ind});

ds = [];
for s_ind = 1:length(svec);
    clc;disp([m_ind s_ind])
subID = svec(s_ind);
sub_SPM_dir = sprintf(sub_SPM_dir_temp,subID);
SPM = [];
load([sub_SPM_dir 'SPM.mat']);

beta_names = {SPM.Vbeta.descrip}';
beta_fls = {SPM.Vbeta.fname}';

for cat_ind = 1:18;
these_betas = find(~cellfun(@isempty,strfind(beta_names,cat_names{cat_ind})));

for b_ind = 1:3
    
    bt_nii = beta_fls{these_betas(b_ind)};
    run_str = beta_names{these_betas(b_ind)}(strfind(beta_names{these_betas(b_ind)},'Sn(')+3);
    run_ind = str2num(run_str);
    
    
    dt_fn = fullfile(sub_SPM_dir,bt_nii);
    
single_scan = cosmo_fmri_dataset(dt_fn,'mask',m_fn);
%single_scan = cosmo_remove_useless_data(single_scan);

single_scan.sa.s_ind = s_ind;
single_scan.sa.subID = subID;
single_scan.sa.cat_ind = cat_ind;
single_scan.sa.b_ind = b_ind;
single_scan.sa.run_ind = run_ind;

    
    if isempty(ds)
        ds = single_scan;
    else
        ds = cosmo_stack({ds single_scan});
    end


end % ends 3 beta
end % ends categoru

end % ends subs
allDs{m_ind} = ds;
end % ends mask 
%%


rlbls = mask_lbls
save('/Users/aidasaglinskas/Desktop/ElisaData.mat','allDs','tlbls','rlbls')
sh = [allDs{1}.sa.b_ind allDs{1}.sa.cat_ind allDs{1}.sa.s_ind allDs{1}.sa.subID];
figure;imagesc(sh)
%%