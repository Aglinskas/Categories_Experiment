clear;
SPM_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas:  Summaries & Analyses (WP 1.4)/Categories_Experiment/fMRI_Data/S%d/Analysis/SPM.mat';
load('subvec')
for s = 2:length(subvec);
    subID = subvec(s);
matlabbatch = [];
SPM_fn = sprintf(SPM_fn_temp,subID);
load(SPM_fn)
names =[  {'Animals-Domestic'}    {'Animals-Exotic'}    {'Animals-Water'}    {'Birds'} {'Body-Parts'}    {'Clothes'}   {'Flora'}    {'Food&Drink'} {'Fruits&Veg'}    {'Household'}    {'Insects&Reptiles'}    {'Leisure'} {'Materials'}    {'Musical_Ins'}    {'Outdoors'}    {'Tools'} {'Transport'} {'Control'}]
cond_names = names'
cond_names_legend = arrayfun(@(x) [num2str(x) ':' names{x}],1:length(cond_names),'UniformOutput',0)';
%% Define Contrasts
l = 1;
con_names{l} = 'living > non-living';
con_vec{l} = zeros(1,18);
con_vec{l}([1 2 3 4 11]) = 1
con_vec{l}([13 14 6 7 16]) = -1

l = l+1;
con_names{l} = 'non-living > living';
con_vec{l} = -con_vec{1};

l = l+1;
con_names{l} = 'all > control'
con_vec{l} = [ones(1,17) -17];

l = l+1;
con_names{l} = 'bodyparts > rest'
con_vec{l} = -ones(1,18);con_vec{l}(5) = 17

for i = 1:length(names)
    l = l+1;
    con_names{l} = names{i};
    con_vec{l} = zeros(1,18);
    con_vec{l}(i) = 1;
end

beta_names = {SPM.Vbeta.descrip}';
num_betas = length(beta_names);

vec = {};
for cind = 1:l
w = [];
weights = con_vec{cind};
for i = 1:length(cond_names)
    w = [w (~cellfun(@isempty,strfind(beta_names,cond_names{i}))*weights(i))];
end
vec = sum(w');
%%
con_name = con_names{cind};
contrast_vec = vec;
matlabbatch{1}.spm.stats.con.consess{cind}.tcon.name = con_name;
matlabbatch{1}.spm.stats.con.consess{cind}.tcon.weights = contrast_vec;
matlabbatch{1}.spm.stats.con.consess{cind}.tcon.sessrep = 'none';
end


matlabbatch{1}.spm.stats.con.spmmat = {SPM_fn};

% F contrast
l = length(matlabbatch{1}.spm.stats.con.consess)+1;
w = [];
for i = 1:length(cond_names);
    w = [w (~cellfun(@isempty,strfind(beta_names,cond_names{i})))];
end
matlabbatch{1}.spm.stats.con.consess{l}.fcon.name = 'f contrast';
matlabbatch{1}.spm.stats.con.consess{l}.fcon.weights = double([w~=0]');
matlabbatch{1}.spm.stats.con.consess{l}.fcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.delete = 1;
spm_jobman('run',matlabbatch)
end
disp('all done')