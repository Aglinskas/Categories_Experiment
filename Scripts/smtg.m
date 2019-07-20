coords = [-12	-91	-9
0	-58	31
-60	-52	-2
-51	-55	-9
-41	-52	-14
-33	-34	-20
-18	32	-9
-48	38	9
-36	35	16
-9	47	-9
-45	-61	20
-36	-67	38
42	-61	45
-48	-56	-16
-57	-52	2
-48	-68	24
-32	-68	42]
names = {'s-EVC'
's-Prec'
's-lat-pMTG'
's-med-pMTG'
's-ven-pMTG'
's-peak-PHG'
's-OFC'
's-Lat-IFG'
's-med-IFG'
's-vmPFC'
's-low-Angular'
's-IPL'
's-Angular-R'
'n-pITG'
'n-pMTG'
'n-Angular'
'n-IPL'}
%%
ofn  = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_norm/Searchlight_ROIs/';
sph_radius = 12;
space_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_norm/4m.nii';
blobs_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_norm/Searchlight_blobs/';
%%
func_makeROIsFromCoords_cats2(coords,names,ofn,sph_radius,space_fn,blobs_dir)