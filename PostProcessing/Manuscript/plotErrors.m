clear
close all

glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
figNamePrefix = [projPath, 'PostProcessing/Figures/'];
saveflag = 1;

finalTime = 5;
Ids = [102, 112, 122, 132];
figs = {'rectangle', 'rectangle_side0', 'semicircle', 'semicircle_side0'};
% start the loop {{{
for iid = 1:length(Ids)
	Id = Ids(iid);
	figName = [figNamePrefix, figs{iid}];
	%% Load data {{{
	addpath([projPath, '/PostProcessing/']);
	[folderList, nameList] = getFolderList(Id, 0);

	% Load simulations from transient.mat
	transData = loadData(folderList, 'levelset', [projPath, 'Models/']);
	Ntrans = length(transData);
	nsub = 2;
	%}}}
	%% Average behaviors {{{
	figure('position',[0,300,400,300])

	for i = 1: Ntrans
		time = transData{i}.time;
		% number of misfit elements no abs
		subplot(nsub,1,1)
		plot(transData{i}.time, transData{i}.total_misfit/1e6, 'LineWidth', 2);
		hold on

		subplot(nsub,1,2)
		plot(transData{i}.time, transData{i}.total_abs_misfit/1e6, 'LineWidth', 2);
		hold on
	end
	subplot(nsub, 1, 1);
	title('total misfit area')
	xlim([0, finalTime])
	ylim([-4, 4])
	xlabel('Time (a)')
	ylabel('Misfit area (km$^2$)', 'Interpreter', 'latex')

	subplot(nsub, 1, 2);
	title('total absolute misfit area')
	xlim([0, finalTime])
	ylim([0, 4])
	xlabel('Time (a)')
	ylabel('Misfit area (km$^2$)', 'Interpreter', 'latex')

%	legend(nameList, 'Interpreter', 'latex', 'Location', 'best')
	set(gcf,'color','w');
	if saveflag
		export_fig([figName, '.pdf'])
	end
	%}}}
end %}}}
