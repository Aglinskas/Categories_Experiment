%for subID = 1;
% SPM_fn_temp = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/fMRI_Data/S%d/Analysis2/SPM.mat';
% SPM_fn = sprintf(SPM_fn_temp,subID);
%SPM_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis3/SPM.mat';
SPM_fn = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/Group_analysis3_18subs/SPM.mat';
load(SPM_fn)
    xSPM = SPM;
    xSPM.Ic = 3;
    xSPM.k = 20;
    xSPM.Im = [];
    xSPM.pm= [];
    xSPM.u = .001;
    xSPM.thresDesc = 'none';
[hReg,xSPM,SPM] = spm_results_ui('setup',xSPM);

% Postion the graphs
% figs = get(0,'children');
% figs(find(cellfun(@(x) isempty(strfind(x,'Results')),{figs.Name},'UniformOutput',1))).Position = [ -0.5461    1.2250    0.3602    0.8300];
% figs(find(cellfun(@(x) isempty(strfind(x,'Graphics')),{figs.Name},'UniformOutput',1))).Position = [ -1012         984         307         303];
img = '/Users/aidasaglinskas/Documents/MATLAB/spm12/canonical/single_subj_T1.nii';
%img = '/Users/aidasaglinskas/Documents/MATLAB/spm12/canonical/cortex_8196.surf.gii';
spm_sections(xSPM,hReg,img)
% Render
    show_rend = 1
    if show_rend
    %rendfile = '/Users/aidasaglinskas/Documents/MATLAB/spm12/canonical/cortex_8196.surf.gii';
    rendfile = '/Users/aidasaglinskas/Documents/MATLAB/spm12/rend/render_single_subj.mat';
    fn = [];
    fn.rend = rendfile;plotted=0;
    while ~plotted
    if ~exist('H');
        H = spm_mesh_render(fn.rend);
        %spm_mesh_inflate(H.patch,40)
    end
        try
    spm_mesh_render('overlay',H,xSPM);plotted=1
        catch
            clear H
        end
    end
    end
%%
    
spm_mip_ui('SetCoords',[-31    -6   -39])
    
save_figure = 0
if save_figure
ofn_root = '/Users/aidasaglinskas/Google Drive/Aidas/Categories_Experiment/results/AnimalsToolsCons/';
if ~exist(ofn_root);mkdir(ofn_root);end
fn = [num2str(subID) '.jpg'];
ofn = fullfile(ofn_root,fn);
f = figure(1);
title(fn,'fontsize',20);drawnow
saveas(f,ofn);
end