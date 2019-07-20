coords = [-30	14	42
-15	62	13
-12	-91	-9
-39	-67	45
42	-61	45
-30	-85	13
-18	32	-9
17	49	-2
0	-58	31
9	-49	27
-12	-49	27
6	2	45
-4	47	-8
-45	-61	20
-58	-52	-2
-51	-55	-9
-39	-52	-12
-32	-34	-17
-51	-49	-11
-48	-70	31
-48	20	40
-15	17	49
-3	-64	31];
%%
names = {'dlPFC-L'
'dmFPC-L'
'EVC-L'
'IPL-L'
'IPL-R'
'LOTC-L'
'OFC-L'
'vmPFC-R'
'Prec-M'
'RSC-R'
'RSC-L'
'SMA-M'
'vmPFC-L'
'Angular-L'
'LOC-L'
'pMTG-lat-L'
'pMTG-med-L'
'PHG-L'
'pMTG-JN-L'
'AG-JN-L'
'latPFC-JN-L'
'dmPFC-JN-L'
'PC-JN-L'}
%%
ofn  = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/';
sph_radius = 10;
space_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/Searchlight_16way_norm/4m.nii';
blobs_dir = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_Jneuro/blobs/';
%%
func_makeROIsFromCoords_cats2(coords,names,ofn,sph_radius,space_fn,blobs_dir)

%% Delete Small

fls = dir([ofn '*.nii']);
fls = {fls.name}';

for i = 1:length(fls);

fn = fullfile(ofn,fls{i});
dt = load_nii(fn);

nml = sum(dt.img(:));

if nml < 20;
crap = dir(strrep(fn,'.nii','*'));
crap = {crap.name}'
for c = 1:length(crap)
    delete(fullfile(ofn,crap{c}))
end
end



end

    
    
    




