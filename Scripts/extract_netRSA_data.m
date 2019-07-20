%% ROIs 
%mask_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_detrend_3m/';
%mask_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_allVsC2/'
mask_dir = '/Volumes/External_2TB/PhD_Data/fMRI_Projects/Categories_Experiment/ROIS/ROIS_detrend_3m/'
mask_fls = dir([mask_dir 'R*.nii']);
mask_fls = {mask_fls.name}';

cat_names_fn = '/Volumes/External_2TB/PhD_Data/fMRI_Projects/Categories_Experiment/Scripts/mats/cat_names.mat'
tlbls_fn = '/Volumes/External_2TB/PhD_Data/fMRI_Projects/Categories_Experiment/Scripts/tlbls.mat';
spm_fn_temp = '/Volumes/External_2TB/PhD_Data/fMRI_Projects/Categories_Experiment/fMRI_Data/S%d/Analysis3/';
%% Stack Scans 

nrois = length(mask_fls);
for r = 1:nrois;
%mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis_18_3mm/mask.nii';
mask_fn = fullfile(mask_dir,mask_fls{r});

all_scans = []
load(cat_names_fn);
load(tlbls_fn);
cat_lbls = [cat_names tlbls'];
subvec = 1:20;
subvec([9 12]) = [];
all_scans = [];

for s = 1:length(subvec);
    subID = subvec(s);
    spm_fn = [sprintf(spm_fn_temp,subID)];
    SPM = [];load([spm_fn 'SPM.mat']);
    if isempty(SPM);error('no SPM');end
    for cat_ind = 1:18;
        inds = find(~cellfun(@isempty,strfind({SPM.Vbeta.descrip}',cat_lbls{cat_ind,1})));
        if length(inds) ~= 3;error('not 3 betas');end
        for b_ind = 1:3; 
            
            clc
            disp(sprintf('R: %d/%d,S:%d/%d, C:%d/%d, B:%d/%d',r,nrois,s,length(subvec),cat_ind,18,b_ind,3));
%             disp(all_scans)
            
            wh = inds(b_ind);
            descrip = SPM.Vbeta(wh).descrip;
            fn = SPM.Vbeta(wh).fname;
            % Gets run index
            tag = ' - Sn(';
            pos = strfind(descrip,tag)+length(tag);
            run_ind = str2num(descrip(pos)); if isempty(run_ind);error('error retrieving run ind');end
            
            data_fn = fullfile(spm_fn,fn);
            
           ds = cosmo_fmri_dataset(data_fn,'mask',mask_fn);
            
           mat_out(r,cat_ind,s,b_ind) = nanmean(ds.samples);
           mat_out_vx{r,cat_ind,s,b_ind} = ds.samples;
           
        end
    end
end
end %enss ROIS
%all_scans = cosmo_remove_useless_data(all_scans);
%%
netRSA_data = struct;
netRSA_data.mat = mat_out;
netRSA_data.voxel_data = mat_out_vx;
netRSA_data.tlbs = tlbls;
netRSA_data.rlbls = mask_fls;
netRSA_data.rlbls = strrep(netRSA_data.rlbls,'.nii','');
netRSA_data.rlbls = strrep(netRSA_data.rlbls,'ROI_','');
netRSA_data.legend = 'ROI|Category|Subject|Observation';
%netRSA_data.rlbs = netRSA_data.rlbls
save('/Users/aidasaglinskas/Desktop/Categories_Experiment/Files/netRSA_data3.mat','netRSA_data');
%%