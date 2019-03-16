
function fMRI_auto_reorigin 

close all; clear all; clc;

% initialize SPM 
spm('defaults','fmri');
spm_jobman('initcfg');

%%define parameters in a general structure 'w'
w.dataDir  = '/Users/carrielin/Documents/MATLAB/basic_fMRI_course/1_Data/';  %raw data
w.subjects = {'07','08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '61','62','63','64','65','66'}; % without low accuracy ones (parent= dataDir)

w.structDir = 't1'; % structural directory (parent=subject)

%%
% loop on subjects 
    for iS=1:numel(w.subjects) 
        fprintf('=========================\n');
        fprintf([w.subjects{iS} 'Reorigin...\n']);
 
    
    w.subName = w.subjects{iS};
    w.subPath = fullfile(w.dataDir, w.subjects{iS});
    w.structPath = fullfile(w.subPath, w.structDir);

    cd(w.subPath);
    
%% do reorigin for each subject     
auto_reorient(w)

%%
    end
end 


function auto_reorient(w)

p=spm_select('FPList', w.structPath, '^.*\.nii$');

spmDir=which('spm');
spmDir=spmDir(1:end-5);
tmpl=[spmDir 'canonical\avg152T1.nii'];
vg=spm_vol(tmpl);
flags.regtype='rigid';
%p=spm_select(inf,'image');
    for i=1:size(p,1)
        f=strtrim(p(i,:));
        spm_smooth(f,'temp.nii',[12 12 12]);
        vf=spm_vol('temp.nii');
        [M,scal] = spm_affreg(vg,vf,flags);
        M3=M(1:3,1:3);
        [u s v]=svd(M3);
        M3=u*v';
        M(1:3,1:3)=M3;
        N=nifti(f);
        N.mat=M*N.mat;
        create(N);
    end
end
