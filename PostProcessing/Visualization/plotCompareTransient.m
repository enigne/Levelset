clear
close all

glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
figNamePrefix = [projPath, 'PostProcessing/Figures/'];
saveflag = 1;

finalTime = 50;
%Ids = [202, 203, 204, 212, 213, 214];
Ids = [0];
figs = {'circle_parabola_v5'};%, 'circle_triangle', 'circle_gaussian', 'circle_uniform', 'circle_parabola_v5', 'rectangle_parabola'};
linestyles = {'-', ':', '--'};
colorstyle = {'#0072BD', '#D95319', '#EDB120'};
Nlines = length(colorstyle) ;
% start the loop {{{
for iid = 1:length(Ids)
	Id = Ids(iid);
	figName = [figNamePrefix, figs{iid}, '_initcomp'];
	%% Load data {{{
	addpath([projPath, '/PostProcessing/']);
	[folderList, nameList] = getFolderList(Id, 0);

	% Load simulations from transient.mat
	transData = loadData(folderList, 'levelset', [projPath, 'Models/']);
	Ntrans = length(transData);
	%}}}
	%% Average behaviors {{{
	figure('position',[0,400,600,450])
	nsub = 2;

	for i = 1: Ntrans
		time = transData{i}.time;
		% number of misfit elements no abs
		subplot(nsub,1,1)
		plot([0,transData{i}.time_misfit], [0,transData{i}.total_misfit/1e6], 'LineWidth', 1.5, 'Color', colorstyle{mod((i-1), Nlines)+1},'LineStyle', linestyles{fix((i-1)/ Nlines)+1});
		hold on

		subplot(nsub,1,2)
		plot([0,transData{i}.time_misfit], [0,transData{i}.total_abs_misfit/1e6], 'LineWidth', 1.5, 'Color', colorstyle{mod((i-1), Nlines)+1},'LineStyle', linestyles{fix((i-1)/ Nlines)+1});
		hold on
	end
	subplot(nsub, 1, 1);
	title('total misfit area')
	xlim([0, finalTime])
	ylim([-20, 20])
	xlabel('Time (a)')
	ylabel('Misfit area (km$^2$)', 'Interpreter', 'latex')

	subplot(nsub, 1, 2);
	title('total absolute misfit area')
	xlim([0, finalTime])
	ylim([0, 25])
	xlabel('Time (a)')
	ylabel('Misfit area (km$^2$)', 'Interpreter', 'latex')

	legend(nameList, 'Location','best')
	set(gcf,'color','w');
	if saveflag
		export_fig([figName, '.pdf'])
	end
	%}}}
end %}}}
