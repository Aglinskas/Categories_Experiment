rp_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/nifti/Sess%d/rp_data.txt';

%%
figure(2);clf

svec = find([1:20]~=12);
l = 0;
for s = 1:length(svec);
    subID  = svec(s);
for sess = 1:2;

rp_fn = sprintf(rp_fn_temp,subID,sess);
load(rp_fn)

l = l+1;
subplot(length(svec),2,l)


%plot(rp_data(:,1:3))
%ylim([-1 3])

plot(rp_data(:,4:6))
ylim([-.05 .05])

end
end