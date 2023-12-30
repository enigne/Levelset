clear
close all

glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
figNamePrefix = [pwd(), '/Figures/'];
saveflag = 1;

finalTime = 50;
%Ids = [501, 502, 504, 511, 512, 514, 601, 602, 604, 611, 612, 614];
Ids = [904, 1004];
figs = {
      'semicircle_400_uniform_1000_all',
      'rectangle_400_uniform_1000_all',
%      'semicircle_parabola_1000_all',
%      'semicircle_triangle_1000_all',
%      'semicircle_uniform_1000_all',
%      'semicircle_parabola_5000_all',
%      'semicircle_triangle_5000_all',
%      'semicircle_uniform_5000_all',
%      'rectangle_parabola_1000_all',
%      'rectangle_triangle_1000_all',
%      'rectangle_uniform_1000_all',
%      'rectangle_parabola_5000_all',
%      'rectangle_triangle_5000_all',
%      'rectangle_uniform_5000_all',
         };
figtitles = {
            'uniform $v_0=1000$ m/a',
            'uniform $v_0=1000$ m/a',
%            'parabola $v_0=1000$ m/a',
%            'triangle $v_0=1000$ m/a',
%            'uniform $v_0=1000$ m/a',
%            'parabola $v_0=5000$ m/a',
%            'triangle $v_0=5000$ m/a',
%            'uniform $v_0=5000$ m/a',
%            'parabola $v_0=1000$ m/a',
%            'triangle $v_0=1000$ m/a',
%            'uniform $v_0=1000$ m/a',
%            'parabola $v_0=5000$ m/a',
%            'triangle $v_0=5000$ m/a',
%            'uniform $v_0=5000$ m/a',
            };

linestyles = {'-', ':', '--', '-.'};
colorstyle = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#77AC30'};
Nlines = 4;
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
	figure('position',[0,1000,400,300])

	for i = 1: Ntrans
		time = transData{i}.time;
		rows = fix((i-1)/Nlines)+1;
		columns = mod((i-1), Nlines)+1;
		%plot(transData{i}.time_misfit, transData{i}.total_abs_misfit/1e6, 'LineWidth', 2, 'LineStyle', linestyles{columns},'Color', colorstyle{rows});
		semilogy(transData{i}.time_misfit, transData{i}.total_abs_misfit/1e6/2, 'LineWidth', 2, 'LineStyle', linestyles{columns},'Color', colorstyle{rows});
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
	xlim([1, finalTime])
	if contains(figtitles{iid}, '5000')
		ylim([0.02, 80])
	else
		%ylim([0, 45])
		ylim([0.02, 80])
	end
	xlabel('Time (a)', 'Interpreter', 'latex')
	ylabel('Absolute misfit area (km$^2$)', 'Interpreter', 'latex')

	%	legend(nameList, 'Interpreter', 'latex','Orientation','vertical','Location','eastoutside')
	set(gcf,'color','w');
	if saveflag
		export_fig([figName, '.pdf'])
	end
	%}}}
end %}}}
