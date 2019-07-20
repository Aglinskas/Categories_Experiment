% Load
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/mats/cat_names.mat');
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/tlbls.mat')
cat_lbls = [cat_names tlbls'];
%%
tic
subvec = 1:20;
subvec([9 12]) = [];
all_scans = [];
spm_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/Analysis3/';

%mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis_18_3mm/mask.nii';
mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/ROI_PC-jNeuro.nii'
%mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/ROI_OFC-L.nii';
%mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/test/test.nii';

for s = 1%:length(subvec);
    subID = subvec(s);
    spm_fn = [sprintf(spm_fn_temp,subID)];
    SPM = [];load([spm_fn 'SPM.mat'])
    if isempty(SPM);error('no SPM');end
    for cat_ind = 1:18;
        inds = find(~cellfun(@isempty,strfind({SPM.Vbeta.descrip}',cat_lbls{cat_ind,1})));
        if length(inds) ~= 3;error('not 3 betas');end
        for b_ind = 1:3;
            
            clc
            disp(sprintf('S:%d/%d, C:%d/%d, B:%d/%d',s,length(subvec),cat_ind,18,b_ind,3));
            disp(all_scans)
            
            wh = inds(b_ind);
            descrip = SPM.Vbeta(wh).descrip;
            fn = SPM.Vbeta(wh).fname;
            % Gets run index
            tag = ' - Sn(';
            pos = strfind(descrip,tag)+length(tag);
            run_ind = str2num(descrip(pos)); if isempty(run_ind);error('error retrieving run ind');end
            
            data_fn = fullfile(spm_fn,fn);
            
            ds = cosmo_fmri_dataset(data_fn,'mask',mask_fn);
            
            ds.sa.descrip = {descrip};
            ds.sa.subID = subID;
            ds.sa.b_ind = b_ind;
            ds.sa.cond_index = cat_ind;
            ds.sa.run_ind = run_ind;
            ds.sa.cond_lbl_it = cat_lbls(cat_ind,1);
            ds.sa.cond_lbl_en = cat_lbls(cat_ind,2);
            
            
            if isempty(all_scans);
                all_scans = ds;
            else
                all_scans = cosmo_stack({all_scans ds});
            end
            
        end
    end
end
toc
%save temp all_scans
%save('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/all_scans_test.mat','all_scans');
%save('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/test/test_allBrain','all_scans')