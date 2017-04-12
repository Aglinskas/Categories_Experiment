Q_fn = 'exp_questions.xlsx';
Stim_fn = 'Stimuli.xlsx';

Q = readtable(Q_fn);
Stim = readtable(Stim_fn);


%Stim.Properties.VariableNames
%Stim.Variables

StimVars = Stim.Variables;

%Q.Properties.VariableNames;
%Q.Variables;
qv = Q.Variables;
%get them in a row; 
r = 0;
myStimuli= struct;
for cat_ind = 1:size(Stim,2)
    cat_name = Stim.Properties.VariableNames{cat_ind};
    cat_non_empty = find(cellfun(@isempty,StimVars(:,cat_ind)) == 0);
    cat_items = StimVars(cat_non_empty,cat_ind);
for item_ind = 1:length(cat_items)
for q_ind = 1:size(Q,1)
    r = r+1;
    
    myStimuli(r).item_name = cat_items{item_ind};
    myStimuli(r).cat_ind = cat_ind;
    myStimuli(r).cat_str = cat_name;
    myStimuli(r).or_row_ind = r;
    
    
    myStimuli(r).task_ind = q_ind;
    myStimuli(r).task_str = qv{q_ind,1};
    myStimuli(r).query = qv{q_ind,2};
    
    
   
    
%     for qq = 1:size(Q,2)
%     fun_str = sprintf('myStimuli(r).%s = ''%s''',Q.Properties.VariableNames{qq},qv{q_ind,qq});
%     eval(fun_str);
%     end
    
    


    
end
end
end


