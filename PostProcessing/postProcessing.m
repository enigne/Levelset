clear
close all

glacier = 'Levelset';
saveflag = 1;
suffixList = {'', '', ''}; % FIXME: need to do this automatic
stepName = 'Transient';
% Setting {{{ 
addpath('./');
projPath = ['/totten_1/chenggong/', glacier, '/'];
steps = [0];
%}}}
% Loading models {{{
[folderList, dataNameList] = getFolderList();
Ndata = length(folderList);
parfor i = 1:Ndata
    disp(['---- Loading the model from ', folderList{i}]);
    org{i}=organizer('repository', [projPath, 'Models/', folderList{i}], 'prefix', ['Model_' glacier '_'], 'steps', steps);
    mdList{i} = loadmodel(org{i}, [stepName, suffixList{1}]);
end %}}}
% load analytical solution {{{

%}}}
% postProcessing {{{
parfor i = 1:Ndata
	extractTransientFromMd(mdList{i}, projPath, folderList{i}, dataNameList{i}, saveflag);
end
%}}}
