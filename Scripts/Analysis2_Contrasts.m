clear;
cd '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts'
SPM_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/Analysis3/SPM.mat';
%%
svec = 1:20;
svec([9 12]) = [];
for subID = svec(9:end);
    SPM_fn = sprintf(SPM_fn_temp,subID);
    clear SPM
    load(SPM_fn)
    %% Category
    load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/mats/cat_names.mat');
    beta_names = {SPM.Vbeta.descrip}';
    e_vec = zeros(size(beta_names))';
    for cat_ind = 1:length(cat_names);
        beta_inds = find(~cellfun(@isempty,strfind(beta_names,cat_names{cat_ind})));
        if length(beta_inds) ~= 3; error('not 3 betas, somethings wrong');end
        vec = e_vec;
        vec(beta_inds) = 1;
        cons(cat_ind,:) = vec;
    end
    if any(sum(cons,1) > 1) | any(sum(cons,2) ~= 3);error('sanity sum check failed, check cons matrix');end
    
    con_vecs = cons; % genius, I know.
    con_lbls = cat_names;
    %%
    l = 1;
    % Template
    %wh{l,1} = []; wh{l,2} = []; wh{l,3} = ''; l = l+1;%
    wh{l,1} = [1:17];wh{l,2} = [18];wh{l,3} = 'all vs control'; l = l+1; % all vs control
    wh{l,1} = [8 9 10 11 12]; wh{l,2} = [1 2 3 4 6]; wh{l,3} = 'Animals > Tools'; l = l+1;%
    wh{l,1} = [1 2 3 4 6]; wh{l,2} = [8 9 10 11 12]; wh{l,3} = 'Tools > Animals'; l = l+1;%
    
    l = length(con_lbls);
    for i = 1:size(wh,1)
        l = l+1;
        v = sum(con_vecs(wh{i,1},:),1) + -sum(con_vecs(wh{i,2},:),1);
        con_vecs(l,:) = v;
        con_lbls{l} = wh{i,3};
    end
    
    clf;add_numbers_to_mat(con_vecs,con_lbls,'nonum')
    %%
    matlabbatch = []
    matlabbatch{1}.spm.stats.con.spmmat = {SPM_fn};
    
    for cind = 1:length(con_lbls);
        matlabbatch{1}.spm.stats.con.consess{cind}.tcon.name = con_lbls{cind};
        matlabbatch{1}.spm.stats.con.consess{cind}.tcon.weights = con_vecs(cind,:);
        matlabbatch{1}.spm.stats.con.consess{cind}.tcon.sessrep = 'none';
    end
    
    % ESS
    l = length(matlabbatch{1}.spm.stats.con.consess)+1;
    matlabbatch{1}.spm.stats.con.consess{l}.fcon.name = 'F Contrast';
    matlabbatch{1}.spm.stats.con.consess{l}.fcon.weights = con_vecs(1:18,:);
    matlabbatch{1}.spm.stats.con.consess{l}.fcon.sessrep = 'none';
    
    %
    matlabbatch{1}.spm.stats.con.delete = 1;
    spm_jobman('run',matlabbatch)
end % end subject loop