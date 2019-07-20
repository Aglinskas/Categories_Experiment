cond_names = {'vestiti' 'strumenti musicali' 'utensili' 'cose di casa' 'tempo libero' 'materiali' 'trasporto & movimento' 'animali acquatici' 'insetti & rettili' 'animali  domestici' 'animali  esotici' 'uccelli' 'frutta e vegetali' 'cibo & bevande' 'flora' 'natura' 'parti del corpo' 'control task'};
sub_dir_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/Analysis2/';
beta_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/Analysis2/beta_%.4i.nii';
%mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis2/mask.nii';
mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROI_files/Combined_ROIs.nii'
ofn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/';
svec = find([1:20]~=12);
%%
all_scans = [];
for s = 1:length(svec);
    subID = svec(s);
tic
sub_dir = sprintf(sub_dir_temp,subID);
    load(fullfile(sub_dir,'SPM.mat'));
    beta_names = {SPM.Vbeta.descrip}';
for cond_index = 1:18;
clc;disp([subID cond_index])

cond_names{cond_index};
this_cond_betas = find(~cellfun(@isempty,strfind(beta_names,cond_names{cond_index})));
    if length(this_cond_betas)~=3;error('not 3 betas');end

for b_ind = 1:3
beta_fn = sprintf(beta_fn_temp,subID,this_cond_betas(b_ind));

    txt = beta_names{this_cond_betas(b_ind)};
    expr = 'Sn\(.\)';
    run_ind_str = regexp(txt,expr,'match');
    run_ind = str2num(run_ind_str{1}(4));
    
single_scan = cosmo_fmri_dataset(beta_fn,'mask',mask_fn);

single_scan.sa.subID = subID;
single_scan.sa.cond_index = cond_index;
single_scan.sa.b_ind = b_ind;
single_scan.sa.run_ind = run_ind;

    if isempty(all_scans)    
       all_scans = single_scan;
    else
        all_scans = cosmo_stack({all_scans single_scan});
    end    
    
end % beta
   
end % end condition loop
toc
end % ends subject loop

disp('created')
save([ofn 'all_scans_ROIs.mat'],'all_scans')
disp('saved')

    