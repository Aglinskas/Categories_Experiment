myStimuli = get_myStimuli;
names = {myStimuli.itemName}'
for n = 1:length(names)
url_temp = 'http://www.bing.com/images/search?q=%s&qs=n&form=QBLH&scope=images&sp=-1&pq=tobacco&sc=9-4&sk=&cvid=6F0C8B2A4AD446768332D2F9699587A4'
%url_temp = 'http://www.bing.com/images/search?&q=%s&qft=+filterui:photo-transparent+filterui:aspect-square&FORM=R5IR27'
this_name = names{n};
url = sprintf(url_temp,this_name)
src = urlread(url);
%%
errs = {};
warning('on')
j_ind = strfind(src,'.jpg')';
h_ind = strfind(src,'http')';

how_many = min([length(j_ind) 3]);
for wh_j = 1:how_many;
choose_j  = j_ind(wh_j);
a = h_ind(h_ind<choose_j);
h = a(end);
im_url = src(h:choose_j+3);
itm_name = this_name;
ofn = '/Users/aidasaglinskas/Desktop/Categories_Experiment/downloads/';
o = fullfile(ofn,[itm_name num2str(wh_j) '.jpg']);

% dir names{n} ofn unitl 3

try 
    urlwrite(im_url,o,'Timeout',10);
catch
    errs{end+1} = im_url;
    warning(sprintf('%s \nfailed to download',errs{end}));
    %warning('%s \nfailed to download',errs{end})
end
end

end