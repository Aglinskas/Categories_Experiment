%url_temp = 'http://www.bing.com/images/search?q=%s&qs=n&form=QBLH&scope=images&sp=-1&pq=tobacco&sc=9-4&sk=&cvid=6F0C8B2A4AD446768332D2F9699587A4';
url_temp = 'http://www.bing.com/images/search?sp=-1&pq=%s&sc=8-3&sk=&cvid=EEC350F9B42C47BBBD5BCDB3FC4B9EDD&q=%s&qft=+filterui:aspect-square+filterui:color2-FGcls_WHITE&FORM=R5IR20';
stimuli_list_fn = 'Stimuli.xlsx';
T = readtable(stimuli_list_fn);
temp = T.Variables;
temp = temp(:);
names = temp(~cellfun(@isempty,temp));
ofn = '/Users/aidasaglinskas/Desktop/Categories_Experiment/downloads/';
errs = {};
for n = 1:length(names)
%url_temp = 'http://www.bing.com/images/search?&q=%s&qft=+filterui:photo-transparent+filterui:aspect-square&FORM=R5IR27'
this_name = names{n};
disp(sprintf('DLing %d/%d :%s',n,length(names),this_name))
url = sprintf(url_temp,this_name,this_name);
src = urlread(url);
%%
warning('off')
j_ind = strfind(src,'.jpg')';
h_ind = strfind(src,'http')';

%how_many = min([length(j_ind) 3]);
wh_j = 0;
while length(dir(fullfile(ofn,[this_name '*']))) < 3;
wh_j = wh_j+1;
choose_j  = j_ind(wh_j);
a = h_ind(h_ind<choose_j);
h = a(end);
im_url = src(h:choose_j+3);
itm_name = this_name;
fn_ext = length(dir(fullfile(ofn,[itm_name '*']))) + 1;
o = fullfile(ofn,[itm_name num2str(fn_ext) '.jpg']);

% dir names{n} ofn unitl 3
try 
    urlwrite(im_url,o,'Timeout',10);
catch
    %errs{end+1} = im_url;
    %warning(sprintf('%s \nfailed to download',errs{end}));
    %warning('%s \nfailed to download',errs{end})
end

a = dir(o);
if exist(o) & a.bytes < 100000;
    delete(o);
end
end
end
disp('All Done')