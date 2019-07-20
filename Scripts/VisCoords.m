coords = [-51	-52	-9
-45	-70	31
-3	-64	31
-57	-52	-2
-39	-52	-12
-6	-58	27
-12	-58	13
12	-49	9
-9	44	-5
-24	-37	-16
-57	-25	16
-48	-67	20
-9	-61	52
-3	-22	45
-9	-61	52
-33	-64	42
-32	15	42
-21	29	42]
%% 
names = {'pMTG-jNeuro'
'AG-jNeuro'
'PC-jNeuro'
'pMTG-Lat'
'pMTG-Med'
'Prec'
'RSC-L'
'RSC-R'
'vmPFC'
'PHG-L'
'A1'
'pSTS-L'
'smtg'
'S2'
'Prec2'
'ANG'
'SFS1'
'SFS2'}
i = 0;
%%
i = 16;
spm_mip_ui('SetCoords',coords(i,:));
clc;disp(names{i})