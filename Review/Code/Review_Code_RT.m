code_root= '/Users/aidasaglinskas/Desktop/TN-Semantic-Categories/';
fn_temp='fMRI_Data/S%d/S%.2i_P1_myTrials_fixed.mat';
nsubs=20;
ncats = 18;
%% Collect Behavioral Data
svec = 1:nsubs
svec(svec==12)=[]; % No data for S12

for s = 1:length(svec);
subID = svec(s);
fn=sprintf(fn_temp,subID,subID);
load(fullfile(code_root,fn))
for cat = 1:ncats
mat_RT(cat,s) = nanmean([myTrials([myTrials.CatInd]==cat).RT]');
mat_rating(cat,s) = nanmean([myTrials([myTrials.CatInd]==cat).response]');
end
end

imagesc(isnan(mat_RT))
imagesc(isnan(mat_rating))

