function fMRI_firstlevel_Preprocessing_language

% example of first-level implementation for SPM12 
% original scripts: https://github.com/blri/CREx_fMRI
% author of current version: Feng Lin (f.lin@students.uu.nl) 
% date: Mar 5, 2019 

close all; clear all; clc; 

% initialize SPM 
spm('defaults','fmri');
spm_jobman('initcfg');

%%======define parameters in a general structure 'w'=====
w.dataDir  = '/Users/carrielin/Documents/MATLAB/basic_fMRI_course/1_Data/';  %raw data
w.subjects = {'sub07','sub08', 'sub09', 'sub10', 'sub11', 'sub12', 'sub13', 'sub14', 'sub15', 'sub16', 'sub17', 'sub18', 'sub61','sub62','sub63','sub64',
    'sub65','sub66'}; % without low accuracy ones (parent= dataDir)

w.structDir = 't1'; % structural directory (parent=subject)
w.sessions = {'picnam','verbgen'}; %session directory (parent=subject)

%% parameters from EPI files 
w.nSlices = 40;  %number of slices 
w.TR = 2.5;  %repetition time (s)
w.thickness = 2.5; % slice thickness (mm)

%%========================================================
% loop on subjects 
    for iS=1:numel(w.subjects) 
        fprintf('=========================/n');
        fprintf([w.subjects{iS} 'First level.../n']);
 
    
    w.subName = w.subjects{iS};
    w.subPath = fullfile(w.dataDir, w.subjects{iS});
    w.structPath = fullfile(w.subPath, w.structDir);

    cd(w.subPath);
    
    %%======== do dartel and first level =================
DoDartel(w);
DoFirstLevel(w);

%%========================================================
    end 
end

function DoDartel(w)

    clear matlabbatch; 

    matlabbatch{1}.spm.tools.dartel.mni_norm.template = fullfile(w.subPath, 'preprocessing','Template_6.nii');
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj.flowfield = fullfile(w.subPath, 'preprocessing', '^u_rc1r','.*\.nii');


    % loop for sessions 
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj.images={};
    for j=1:numel(w.sessions)
        %% Get EPI raw files           
        f = spm_select('ExtFPList',  fullfile(w.subPath, w.sessions{j}), '^ua','.*\.nii$', Inf);
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj.images{j} = cellstr(f); 
        %%
    end
    
    matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
    matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                               NaN NaN NaN];
    matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 0;
    matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [5 5 5];
    
    save(fullfile(w.subPath, 'SPM12_matlabbatch_5_dartel.mat'),'matlabbatch');     
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);  
    %%
      
end


function DoFirstlevel(w)

    clear matlabbatch;
    matlabbatch{1}.spm.stats.fmri_spec.dir = fullfile(w.subPath, 'stats');
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2.5;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 40;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 39;

%session 1 
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = spm_select('ExtFPList',  fullfile(w.subPath, 'picnam', '^swua','.*\.nii$', Inf);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond.name = 'picname';
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond.onset = [6000
                                                             54000
                                                             136000
                                                             209000
                                                             275000];
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond.duration = '<UNDEFINED>';
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond.tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond.orth = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;

    %session 2
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = spm_select('ExtFPList',  fullfile(w.subPath, 'verbgen', '^swua','.*\.nii$', Inf);
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond.name = 'verbgen';
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond.onset = [23000
                                                             74000
                                                             123000
                                                             170000
                                                             230000];
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond.duration = '<UNDEFINED>';
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond.tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond.orth = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.5;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    matlabbatch{2}.spm.stats.review.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.review.display.matrix = 1;
    matlabbatch{2}.spm.stats.review.print = 'ps';

    matlabbatch{3}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;
    
    save(fullfile(w.subPath, 'SPM12_matlabbatch_6_FirstLevel.mat'),'matlabbatch');     
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);  
    
end



    
