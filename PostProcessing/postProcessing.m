clear
close all

glacier = 'Levelset';
compareToFine = 1;
Id = 300;  % 310, 400, 410
% Setting {{{ 
stepName = 'Transient';
saveflag = 1;
addpath('./');
projPath = ['/totten_1/chenggong/', glacier, '/'];
steps = [0];
%}}}
% Loading models {{{
[folderList, dataNameList] = getFolderList(Id);
Ndata = length(folderList);
for i = 1:Ndata
    disp(['---- Loading the model from ', folderList{i}]);
    org{i}=organizer('repository', [projPath, 'Models/', folderList{i}], 'prefix', ['Model_' glacier '_'], 'steps', steps);
    mdList{i} = loadmodel(org{i}, [stepName]);
end 
%% load reference mesh
if compareToFine
	disp('load a super fine mesh');
	org_finemesh=organizer('repository', [projPath, 'Models/'], 'prefix', ['Model_' glacier '_'], 'steps', steps);
	mdref = loadmodel(org_finemesh, 'SuperfineMesh'); 
else
	mdref = '';
end%}}}
% postProcessing {{{
for i = 1:Ndata
	extractTransientFromMd(mdList{i}, projPath, folderList{i}, dataNameList{i}, mdref, saveflag);
end
%}}}
