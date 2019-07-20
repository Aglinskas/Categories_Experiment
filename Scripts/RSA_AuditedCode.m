mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/test/roi.nii'


%mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis_18_3mm/mask.nii';
% mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/ROI_PC-jNeuro.nii'
%mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/ROIS/ROIS_much/ROI_OFC-L.nii';
%mask_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/test/test.nii';
tic
all_scans=[]
myDat=[];
for s = 1:length(subvec);
clc;disp([s length(subvec)])
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

myDat(s,b_ind,cat_ind,:)=ds.samples;
            if isempty(all_scans);
                all_scans = ds;
            else
                all_scans = cosmo_stack({all_scans ds});
            end

        end
    end
end
myDat_raw = myDat;
disp('done')
%%

load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
model = wikiClust.cmat;

myDat = myDat_raw;
% input to this is 
clear outD
if size(myDat,3)>16
myDat(:,:,[5 18],:)=[];
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
[h p ci stats]=ttest(mean(outD,2));
t_statement(stats,p);