ofn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/An_3B_S%d-Run%d.mat';
    % Load the MT
    mt_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/S%.2i_P1_myTrials_fixed.mat';
    a = [];
    svec = find([1:20]~=12);
for s = 1:length(svec);
    subID = svec(s);
    mt_fn = sprintf(mt_fn_temp,subID,subID);
    load(mt_fn)
   
for r_ind = 1:2
   [onsets names durations] = deal({});
   run_blocks = unique([myTrials([myTrials.fmri_run]==r_ind).BlockInd]);
for b_ind = 1:length(run_blocks);
    b = run_blocks(b_ind);
    inds = find([myTrials.BlockInd]==b);


onsets{b_ind} = myTrials(inds(1)).time_presented;
names{b_ind} = myTrials(inds(1)).CatName;
durations{b_ind} = 16;
end % ends blocks
ofn = sprintf(ofn_temp,subID,subID,r_ind);
%save(ofn,'onsets','names','durations');
end % ends run
end % ends subject