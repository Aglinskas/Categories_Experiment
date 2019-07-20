clear;
prep=  {'all_ds26.mat'	'rlbls.mat'	'tlbls.mat'}
cellfun(@load,prep)
%%

m_ind = 1;
s_ind = 1;
c_ind = 1;

ds = all_ds{m_ind};