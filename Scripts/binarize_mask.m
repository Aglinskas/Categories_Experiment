fn = '/Users/aidasaglinskas/Downloads/semantic_association-test_z_FDR_0.01.nii';
dt = load_nii(fn);
th = 6;
dt.img(dt.img < th) = 0;
dt.img(dt.img > th) = 1;
sum(dt.img(:))
%%
save_nii(dt,'/Users/aidasaglinskas/Downloads/mask.nii');