clear
close all

glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
figNamePrefix = [pwd(), '/Figures/'];
saveflag = 1;

finalTime = 50;
Ids = [304, 404, 301, 302, 303, 314];
figs = {'semicircle_uniform_1000', 'rectangle_uniform_1000', 'semicircle_parabola_1000', 'semicircle_trangle_1000', 'semicircle_gaussian_1000', 'semicircle_uniform_5000'};
figtitles = {'Semicircle, uniform $v_0=1000$ m/a', 
				'Straight line, uniform $v_0=1000$ m/a', 
				'Semicircle, parabola $v_0=1000$ m/a', 
				'Semicircle, triangle $v_0=1000$ m/a', 
				'Semicircle, gaussian $v_0=1000$ m/a', 
				'Semicircle, uniform $v_0=5000$ m/a', 
				};
linestyles = {'-', ':', '--'};
colorstyle = {'#0072BD', '#D95319', '#EDB120'};
Nlines = 3;
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
	%}}}
	%% Average behaviors {{{
	figure('position',[0,1000,600,200])

	for i = 1: Ntrans
		time = transData{i}.time;
		% number of misfit elements no abs
		%		subplot(nsub,1,1)
		%		plot(transData{i}.time_misfit, transData{i}.total_misfit/1e6, 'LineWidth', 2, 'LineStyle', linestyles{fix((i-1)/Nlines)+1},'Color', colorstyle{mod((i-1), Nlines)+1});
		%		hold on

		%		subplot(nsub,1,2)
		plot(transData{i}.time_misfit, transData{i}.total_abs_misfit/1e6, 'LineWidth', 2, 'LineStyle', linestyles{fix((i-1)/Nlines)+1},'Color', colorstyle{mod((i-1), Nlines)+1});
		hold on
	end
	%	subplot(nsub, 1, 1);
	%	title('total misfit area')
	%	xlim([0, finalTime])
	%	ylim([-25, 25])
	%	xlabel('Time (a)')
	%	ylabel('Misfit area (km$^2$)', 'Interpreter', 'latex')

	%	subplot(nsub, 1, 2);
	title(figtitles{iid}, 'Interpreter', 'latex')
	xlim([0, finalTime])
	ylim([0, 25])
	xlabel('Time (a)')
	ylabel('Absolute misfit area (km$^2$)', 'Interpreter', 'latex')

	%	legend(nameList, 'Interpreter', 'latex','Orientation','vertical','Location','eastoutside')
	set(gcf,'color','w');
	if saveflag
		export_fig([figName, '.pdf'])
	end
	%}}}
end %}}}
