function myStimuli = get_myStimuli
cd '/Users/aidasaglinskas/Desktop/Categories_Experiment/'
load('stimuli.mat')
%%
l = 0;
names = fieldnames(stimuli);
myStimuli = struct;
for i = 1:length(names);
    cat_name = names{i};
    cat_items = eval(sprintf('stimuli.%s',cat_name));
   for j = 1:length(cat_items)
       l = l+1;
       myStimuli(l).itemName = cat_items{j};
eval( sprintf('myStimuli(%d).is_%s = 1',l,cat_name) );
   end
end
for j = 1:length(names); % pad with zeros
    cat_name = names{j};
eval(sprintf('[myStimuli(find(cellfun(@isempty,{myStimuli.is_%s}))).is_%s] = deal(0)',cat_name,cat_name));
%[myStimuli(find(cellfun(@isempty,{myStimuli.is_Animal}))).is_Animal] = deal(0)
end


% add categories
fn = '/Users/aidasaglinskas/Desktop/Categories_Experiment/exp_questions.xlsx';
T = readtable(fn);


b = cellfun(@(x) ['h_' x],T{:,1},'Uniformoutput',0);






end% ends fucntio