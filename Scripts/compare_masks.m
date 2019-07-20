svec = find(~ismember([1:20],[12 9]));
% %% Cosmo Way
% allds = [];
% fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/Analysis2/mask.nii';
% for i = 1:length(svec)
% fn = sprintf(fn_temp,svec(i));
% ds = cosmo_fmri_dataset(fn);
%     if isempty(allds)
%         allds = ds;
%     else
%         allds = cosmo_stack({allds ds});
%     end
% 
% end
% allds.samples = sum(allds.samples);
% ofn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/allMasks.nii';
% cosmo_map2fmri(allds,ofn)
%%
all_ds = [];
for i = 1:length(svec)
fn = sprintf(fn_temp,svec(i));
a = load_nii(fn);
if isempty(all_ds)
  all_ds = a;
else
  all_ds.img(:,:,:,i) = a.img;
end 
end
m = all_ds;
m.img = sum(m.img,4);
ofn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/allMasks.nii';
save_nii(m,ofn)
%%
c = [12 54 24];
m.img(c(1),c(2),c(3));
sub = svec(find(~squeeze(all_ds.img(c(1),c(2),c(3),:))));
%%
M = '/Users/aidasaglinskas/Documents/MATLAB/spm12/canonical/cortex_8196.surf.gii'
fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/allMasks.nii'
%fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis3_18subs/mask.nii';
H = spm_mesh_render('Disp',M)
spm_mesh_render('Overlay',H,fn)
%%
c = [57 83 15];
ind = allds.fa.i == c(1) & allds.fa.j == c(2) & allds.fa.k == c(3);
allds.samples(find(ind));
%%
% figure(3)
% imagesc(1:18)
% xticks(1:18)
% yticks([])
% colormap('jet')