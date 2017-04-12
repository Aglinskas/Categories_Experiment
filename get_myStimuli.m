function myStimuli = get_myStimuli
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
    myStimuli(r).o_i = r;
    
    
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
l_t = length(myStimuli);

[~,index] = sortrows([myStimuli.task_ind].'); myStimuli = myStimuli(index); clear index
%[myStimuli(1:l_t).ot] = 

%items_per_task = length(find([myStimuli.task_ind] == 1));
% Randomize the blocks
items_per_task = length(unique({myStimuli.item_name}));
possible = 2:items_per_task;
available_block_div = possible(find(mod(items_per_task,possible) == 0));
available_block_lengts = 105 ./ available_block_div;

%available_block_lengts = 35    21    15     7     5     3     1
%block_length = 21;
block_length = available_block_lengts(1)
o = 1:block_length:l_t;
n_blocks = length(o);

range1 = [1:n_blocks];
%range1 = Shuffle(range1);
b_temp = num2cell(range1);
%b_temp = Shuffle(b_temp)

[myStimuli(o).b_ind] = deal(b_temp{:});

for i = o
    range_ind = i:i+block_length-1;
    [myStimuli(range_ind).b_ind] = deal(myStimuli(i).b_ind);
end

% Finally Sort Randomised block order
%[~,index] = sortrows([myStimuli.b_ind].'); myStimuli = myStimuli(index); clear index;

%myStimuli = Shuffle(myStimuli)
%mat = [[myStimuli.cat_ind]' [myStimuli.task_ind]' ./10];
%imagesc(mat)

end %ends function
