root_fldr = '/Users/aidasaglinskas/Google Drive/Aidas:  Summaries & Analyses (WP 1.4)/Categories_Experiment/fMRI_Data/RAW copy/'
temp = dir(root_fldr)
temp = {temp([temp.isdir]).name}';
fldrs = temp(~ismember(temp,{'.' '..'}))
% Loop Through Folders
for fldr_ind = 1:length(fldrs);
fldr_fn = fullfile(root_fldr,fldrs{fldr_ind});
    fls = dir([fldr_fn '/*/*/*.IMA']);
dicom_fn = fullfile(fls(1).folder,fls(1).name);
d = dicominfo(dicom_fn);

t = {d.PatientID
d.PatientSex
d.PatientSize
d.PatientWeight 
d.AcquisitionDate 
d.AcquisitionTime
d.PatientID(7:8)
d.PatientID(5:6)
d.PatientID(1:4)}';

t_leg = {'ID'
'Sex'
'Height'
'Weight '
'AcquisitionDate '
'AcquisitionTime'
'DOB_Day'
'DOB_Month'
'DOB_Year'};

td = cell2table(t,'VariableNames',t_leg);

T(fldr_ind,:) = td;
end
%T.AcquisitionTime = cellfun(@(x) str2num(x)/1e4,T.AcquisitionTime,'UniformOutput',0);
T.AcquisitionTime = cellfun(@(x) [x(1:2) ':' x(3:4)],T.AcquisitionTime,'UniformOutput',0);
%T.AcquisitionTime = cellfun(@num2str,T.AcquisitionTime,'UniformOutput',0);
%T.AcquisitionDate = cellfun(@(x) [x(1:4) '/' x(5:6) '/' x(7:8)],T.AcquisitionDate,'UniformOutput',0);
%%
T = sortrows(T,[5 6]);
%writetable(T,'Dicom_info.csv','Delimiter',';')