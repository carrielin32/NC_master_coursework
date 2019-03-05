function fMRI_basic_Preprocessig_language

% example of preprocessing implementation for SPM12 
% original scripts: https://github.com/blri/CREx_fMRI
% author of current version: Feng Lin (f.lin@students.uu.nl) 
% date: Mar 4, 2019 

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
        fprintf([w.subjects{iS} 'Preprocessing.../n']);
 
    
    w.subName = w.subjects{iS};
    w.subPath = fullfile(w.dataDir, w.subjects{iS});
    w.structPath = fullfile(w.subPath, w.structDir);

    cd(w.subPath);

%%======== do preprocessing step by step =================
DoSliceTiming(w);
DoRealignunwarp(w);
DoCoregister(w);
DoSegment(w);

%%========================================================
    end 
end

function DoSliceTiming(w)
    
    clear matlabbatch; 

    % loop for sessions 
    matlabbatch{1}.spm.temporal.st.scans = {};
    for j=1:numel(w.sessions)
        %% Get EPI raw files           
        f = spm_select('ExtFPList',  fullfile(w.subPath, w.sessions{j}), '^.*\.nii$', Inf);
        matlabbatch{1}.spm.temporal.st.scans{j} = cellstr(f); 
        %%
    end
    
    matlabbatch{1}.spm.temporal.st.nslices = w.nSlices;
    matlabbatch{1}.spm.temporal.st.tr = w.TR;
    matlabbatch{1}.spm.temporal.st.ta = 2.4375; 
    matlabbatch{1}.spm.temporal.st.so = [1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40]; 
    matlabbatch{1}.spm.temporal.st.refslice = 39;      
    matlabbatch{1}.spm.temporal.st.prefix = 'a'; 
    
    save(fullfile(w.subPath, 'SPM12_matlabbatch_1_SliceTiming.mat'),'matlabbatch');     
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);  
    %%
      
end


function DoRealignunwarp(w)
    clear matlabbatch 
    
    % loop for sessions 
    matlabbatch{1}.spm.spatial.realign.estwrite.data = {};
    for j=1:numel(w.sessions)
        %% Get files after slice timing           
        f = spm_select('ExtFPList',  fullfile(w.subPath, w.sessions{j}), ['^a' '.*' '.*\.nii$'], Inf);
        matlabbatch{1}.spm.spatial.realignunwarp.data{j} = cellstr(f);
        %%
    end
    
    
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm = 0;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.einterp = 2;
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions.weight = '';
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.fot = [1 2 3 4 5 6];
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.sot = [];
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.rem = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.noi = 5;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.mask = 1;
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
    
    save(fullfile(w.subPath, 'SPM12_matlabbatch_2_Realignunwarp.mat'),'matlabbatch');

    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);       
end   


function DoCoregister(w)

    %get T1 structural file 
    a = spm_select('FPList', w.structPath, '^.*\.nii$'); 
    
    %get mean realigned EPI
    mean_realign = spm_select('FPList', fullfile(w.subPath, w.sessions{1}), ['^mean' '.*\.nii$']);
    
    clear matlabbatch
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = cellstr(mean_realign);
    matlabbatch{1}.spm.spatial.coreg.estimate.source = cellstr(a);
    matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

    save(fullfile(w.subPath, 'SPM12_matlabbatch_3_Coregister.mat'),'matlabbatch');  
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);  
end


function DoSegment(w)

    % select the T1 anatomical image
    coregAnat = cellstr(spm_select('FPList', w.structPath, '^.*\.nii$'));
    
    
    % get template of each cerebral tissue 
    tmpGM         = {'/Users/carrielin/Documents/MATLAB/spm12/tpm/TPM.nii,1'};
    tmpWM         = {'/Users/carrielin/Documents/MATLAB/spm12/tpm/TPM.nii,2'};
    tmpCSF        = {'/Users/carrielin/Documents/MATLAB/spm12/tpm/TPM.nii,3'};
    tmpBone       = {'/Users/carrielin/Documents/MATLAB/spm12/tpm/TPM.nii,4'};      
    tmpSoftTissue = {'/Users/carrielin/Documents/MATLAB/spm12/tpm/TPM.nii,5'};              
    tmpAirBck     = {'/Users/carrielin/Documents/MATLAB/spm12/tpm/TPM.nii,6'};  
    
    clear matlabbatch;
    
    matlabbatch{1}.spm.spatial.preproc.channel.vols = coregAnat;
    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001; % Bias regularisation light
    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;  % 60 mm cutoff
    matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];     
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = tmpGM;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];  %native
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];  
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = tmpWM;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];  %native
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];       
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = tmpCSF;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];  %native
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];   
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = tmpBone;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];  %native
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = tmpSoftTissue;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];  %native
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];        
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = tmpAirBck;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];     
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];   %  Forward

    save(fullfile(w.subPath, 'SPM12_matlabbatch_4_Segment.mat'),'matlabbatch');     
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);  
    
end


        
