directory = '/Users/aidasaglinskas/Google Drive/Aidas:  Summaries & Analyses (WP 1.4)/Categories_Experiment/fMRI_Data/S%d/nifti'
folders = {'Anatomical' 'Fieldmap' 'Sess1' 'Sess2'};
filenames = {'ana_nopeel.nii' 'fieldmap.nii' 'data.nii' 'data.nii'};

subvec = find([1:20]~=12);
for s = 1:length(subvec)
for f = 1:4
subID = subvec(s);
dr = fullfile(sprintf(directory,subID),folders{f});
fl = dir([dr '/*.nii']);
fn = fullfile(dr,fl(1).name);
new_fn = fullfile(dr,filenames{f});
copyfile(fn,new_fn)
end
end

