load('/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Scripts/wikiClust.mat')
model = wikiClust.cmat;

clear outD
for sub=1:18
    for b_ind = 1:3
    myDat=squeeze(subjDat(sub,b_ind,:,:));
    v1=squareform(1-model);
    myDat=myDat-repmat(mean(myDat,1),16,1);
    v2=squareform(1-corr(myDat'));
    outD(sub,b_ind)=corr2(v1,v2);
    end
    
end
[h p ci stats]=ttest(mean(outD,2))