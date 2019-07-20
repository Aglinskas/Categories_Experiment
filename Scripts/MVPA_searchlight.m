load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/all_scans.mat')
%% RSM Searchlight
%ch = [all_scans.sa.b_ind,all_scans.sa.cond_index,all_scans.sa.run_ind,all_scans.sa.subID]
analysis_name = 'test_decode';
    ofn_temp = fullfile('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/',analysis_name);
    if ~exist(ofn_temp);mkdir(ofn_temp);end
    
ds = all_scans;
nvoxels_per_searchlight=100;
nbrhood=cosmo_spherical_neighborhood(ds,'count',nvoxels_per_searchlight);

svec = find([1:20]~=12);
max_s = 5;
max_b = 3;
%% Main Loop
for s_ind = 1:max_s;
    subID = svec(s_ind);
%for b_ind = 1:max_b;

ds = all_scans;
ds = cosmo_slice(ds,ds.sa.subID==subID);
%ds = cosmo_slice(ds,ds.sa.b_ind==b_ind);

ds.sa.targets = ds.sa.cond_index;
ds.sa.chunks = ds.sa.b_ind;
% set measure

for i = 1:3
ds.samples(ds.sa.chunks==i,:) = zscore(ds.samples(ds.sa.chunks==i,:),[],2)
end


measure = @cosmo_crossvalidation_measure;
measure_args = struct();
measure_args.classifier = @cosmo_classify_lda;
measure_args.partitions = cosmo_nfold_partitioner(ds.sa.chunks);

lda_results = cosmo_searchlight(ds,nbrhood,measure,measure_args);

% run searchlight
clc;disp(sprintf('%d/%d:%d/%d',s_ind,max_s,b_ind,max_b))
%ds_rsm_binary=cosmo_searchlight(ds,nbrhood,measure,measure_args);

fn = sprintf('S%dB%d.nii',s_ind,b_ind);
output_fn = fullfile(ofn_temp,fn);
cosmo_map2fmri(ds_rsm_binary,output_fn);
end
%end
disp('all done')