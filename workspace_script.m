%url = 'https://www.wikiwand.com/en/Tiger';
url = 'http://www.bing.com/images/search?q=tobacco&qs=n&form=QBLH&scope=images&sp=-1&pq=tobacco&sc=9-4&sk=&cvid=6F0C8B2A4AD446768332D2F9699587A4'
src = urlread(url);
%%
errs = {};
warning('on')
j_ind = strfind(src,'.jpg')';
h_ind = strfind(src,'http')';

for wh_j = 1:length(j_ind);
choose_j  = j_ind(wh_j);
a = h_ind(h_ind<choose_j);
h = a(end);
im_url = src(h:choose_j+3);
itm_name = 'tobacco';
ofn = '/Users/aidasaglinskas/Desktop/Categories_Experiment/downloads/';
o = fullfile(ofn,[itm_name num2str(wh_j) '.jpg']);
try 
    urlwrite(im_url,o,'Timeout',5);
catch
    errs{end+1} = im_url;
    warning(sprintf('%s \nfailed to download',errs{end}));
    %warning('%s \nfailed to download',errs{end})
end
end