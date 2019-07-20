function [OutData] = func_extract_RSA(masks_dir,mask_fls)
% [OutData] = func_extract_RSA(masks_dir,mask_fls)
subvec = 1:20;
subvec([9 12]) = [];
all_scans = [];
spm_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/Analysis3/';

cat_names = {'vestiti' 'strumenti musicali' 'utensili' 'cose di casa' 'tempo libero' 'materiali' 'trasporto & movimento' 'animali acquatici' 'insetti & rettili' 'animali  domestici' 'animali  esotici' 'uccelli' 'frutta e vegetali' 'cibo & bevande' 'flora' 'natura' 'parti del corpo' 'control task'};
tlbls = {'Clothes' 'Musical ins' 'Tools' 'Household' 'Leisure' 'Materials' 'Transport' 'Animals-Water' 'Animals-Insects' 'Animals-Domestic' 'Animals-Wild' 'Animals-Birds' 'Fruits & Veg' 'Food & Drink' 'Flora' 'Outdoors' 'Bodyparts' 'control task'};
cat_lbls = [cat_names' tlbls'];

tic
all_scans=[]
myDat=[];
tic

if ~iscell(mask_fls);mask_fls = {mask_fls};end

for m = 1:length(mask_fls);
    mask_fn = fullfile(masks_dir,mask_fls{m})
    dat = []
for s = 1:length(subvec);

    
clc;
disp('getting data')
disp(sprintf('ROI: %d/%d, SUB: %d/%d',m,length(mask_fls),s,length(subvec)))
toc
    
    subID = subvec(s);
    spm_fn = [sprintf(spm_fn_temp,subID)];
    SPM = [];load([spm_fn 'SPM.mat'])
    if isempty(SPM);error('no SPM');end
    for cat_ind = 1:18;
        inds = find(~cellfun(@isempty,strfind({SPM.Vbeta.descrip}',cat_lbls{cat_ind,1})));
        if length(inds) ~= 3;error('not 3 betas');end
        for b_ind = 1:3;

         
            wh = inds(b_ind);
            descrip = SPM.Vbeta(wh).descrip;
            fn = SPM.Vbeta(wh).fname;
            % Gets run index
            tag = ' - Sn(';
            pos = strfind(descrip,tag)+length(tag);
            run_ind = str2num(descrip(pos)); if isempty(run_ind);error('error retrieving run ind');end

            data_fn = fullfile(spm_fn,fn);

            ds = cosmo_fmri_dataset(data_fn,'mask',mask_fn);

            ds.sa.descrip = {descrip};
            ds.sa.subID = subID;
            ds.sa.b_ind = b_ind;
            ds.sa.cond_index = cat_ind;
            ds.sa.run_ind = run_ind;
            ds.sa.cond_lbl_it = cat_lbls(cat_ind,1);
            ds.sa.cond_lbl_en = cat_lbls(cat_ind,2);

%myDat(s,b_ind,cat_ind,:)=ds.samples;

dat(s,cat_ind,b_ind,:) = ds.samples;
%data(m,s,cat_ind,b_ind,:) = ds.samples

%             if isempty(all_scans);
%                 all_scans = ds;
%             else
%                 all_scans = cosmo_stack({all_scans ds});
%             end

        end
    end
end %ends subjects

rdata{m} = dat;


OutData.voxel_data = rdata;
OutData.dt_leg = 'SUB|CAT|BETA|VOXELS';
rlbls = mask_fls;
rlbls = strrep(rlbls,'ROI_','');
rlbls = strrep(rlbls,'.nii','');
OutData.rlbls = rlbls;
OutData.tlbls = tlbls;

myDat_raw = myDat;
disp('done')
end % ends masks
%%
fit_scott_legacy = 0
if fit_scott_legacy
load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
model = wikiClust.cmat;

subjDat = myDat_raw;
%load('/Users/aidasaglinskas/Desktop/forDebug.mat','subjDat') % to get 3.44 value
% input to this is 
clear outD
if size(subjDat,3)>16
subjDat(:,:,[5 18],:)=[];
%myDat = Shuffle(myDat);
end

outD = []
for sub=1:18
    for b_ind = 1:3
    myDat=squeeze(subjDat(sub,b_ind,:,:));
    v1=squareform(1-model);
    myDat=myDat-repmat(mean(myDat,1),16,1); % center data
    v2=squareform(1-corr(myDat'));
    outD(sub,b_ind)=corr2(v1,v2);
    end
end
m_out_d = mean(outD,2);
%[h p ci stats]=ttest(mean(outD,2));
[h p ci stats]=ttest(m_out_d);
t_statement(stats,p);
end % ends if 
