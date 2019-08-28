function F_statement(table)
t_ind = strcmp(table(:,1),'Time');
e_ind  = strcmp(table(:,1),'Error');
df_ind = strcmp(table(1,:),'df');
F_ind = strcmp(table(1,:),'F');
p_ind = strcmp(table(1,:),'Prob>F');

pval = table{t_ind,p_ind};
if pval < .001;
    p_str = '< .001';
else
    p_str = ['= ' num2str(pval,'%.3f')]
end
fs = sprintf('F(%d,%d) = %.3f, p %s',table{t_ind,df_ind},table{e_ind,df_ind},table{t_ind,F_ind},p_str);
disp(fs)
end