load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/jNeuroRois2.mat');
%%
voxel_data.dt(:,17,:) = [];
voxel_data.tlbls(17) = [];
%%
acc = [];
clc;tic
disp('computing')
for t = 1:16;
ds = [];
single_scan = [];
    use_vx = voxel_data;
    use_vx.dt(:,t,:) = [];
    use_vx.tlbls(t) = [];
for r = [1:5];
[cmat] = func_combroi(voxel_data.mat_files(r),use_vx);
for s = 1:18
    
single_scan.samples = get_triu(cmat(:,:,s));
%single_scan.samples = zscore(single_scan.samples);
single_scan.sa.sub = s;
single_scan.sa.ROI = r;

if isempty(ds)
    ds = single_scan;
else
    ds = cosmo_stack({ds single_scan});
end

end
end
ds.sa.targets = ds.sa.ROI;
ds.sa.chunks = ds.sa.sub;
partitions = cosmo_nfold_partitioner(ds.sa.chunks);
[pred, accuracy] = cosmo_crossvalidate(ds,@cosmo_classify_lda,partitions);
acc(t) = accuracy;
end
disp('done');toc
%% Plot
numl = 1:length(acc);
figure(1);clf;hold on
[Y I] = sort(acc);
bar(acc(I));
xticks(numl);
xticklabels(voxel_data.tlbls(I));
xtickangle(45);

plot(numl,repmat(1/length(unique(pred)),1,length(numl)),'k-')
ylabel('Decoding accuracy');
xlabel('Categoru Removed');