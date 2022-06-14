clear
close all

glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
saveflag = 1;
stepName = 'Transient';
%% Load model {{{
[folderList, dataNameList] = getFolderList();

steps = [1];

for i = 1:length(folderList)
	disp(['---- Downloading the model from Discovery to ', folderList{i}]);
	org=organizer('repository', [projPath, 'Models/', folderList{i}], 'prefix', ['Model_' glacier '_'], 'steps', steps);
	if perform(org, ['Transient_Discovery_Download'])
		md = loadmodel(org, [stepName]);

		md.cluster = discovery('numnodes',1,'cpuspernode',1);
		savePath = md.miscellaneous.name;
		disp(['Downloadng ', savePath, ' from Discovery'])

		md=loadresultsfromcluster(md,'runtimename', savePath);

		savemodel(org,md);
		if ~strcmp(savePath, './')
			system(['mv ', projPath,'/Models/', savePath, '/Model_',glacier,'_Transient_Discovery_Download.mat ', projPath, '/Models/', savePath, '/Model_', glacier, '_', stepName, '.mat']);
		end
	end
end

