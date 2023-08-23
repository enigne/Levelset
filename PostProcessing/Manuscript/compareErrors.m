clear
close all

glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
figNamePrefix = [pwd(), '/Figures/'];
plotflg = 1;
saveflag = 1;

finalTime = 50;
Ids = [301, 302, 304, 311, 312, 314, 401, 402, 404, 411, 412, 414];
figs = {
			'uniform_parabola_1000', 
			'uniform_triangle_1000', 
			'uniform_uniform_1000', 
			'uniform_parabola_5000',
			'uniform_triangle_5000', 
			'uniform_uniform_5000',
			'rectangle_parabola_1000', 
			'rectangle_triangle_1000', 
			'rectangle_uniform_1000', 
			'rectangle_parabola_5000',
			'rectangle_triangle_5000', 
			'rectangle_uniform_5000',
			};
figtitles = {
				'parabola $v_0=1000$ m/a', 
				'triangle $v_0=1000$ m/a', 
				'uniform $v_0=1000$ m/a', 
				'parabola $v_0=5000$ m/a', 
				'triangle $v_0=5000$ m/a', 
				'uniform $v_0=5000$ m/a', 
				'parabola $v_0=1000$ m/a', 
				'triangle $v_0=1000$ m/a', 
				'uniform $v_0=1000$ m/a', 
				'parabola $v_0=5000$ m/a', 
				'triangle $v_0=5000$ m/a', 
				'uniform $v_0=5000$ m/a', 
				};

colorstyle = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#77AC30'};
Nlines = 4;
% start the loop {{{
errors = {};
names = {};

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
	% get the final errors{{{
	for i = 1: Ntrans
		errors{iid}(i) = transData{i}.total_abs_misfit(end)/1e6;
		names{iid}{i} = transData{i}.name;
	end
	%}}}
	% plot{{{
	reerr = reshape(errors{iid},Nlines,5)/2
	if plotflg 
		figure('position',[0,1000,600,400])
		bar(reerr)
		legend({'$\tau=1$', '$\tau=10$', '$\tau=100$', '$\tau=200$', '$\tau=\infty$'},'Interpreter','latex')
		xticklabels({'AD', 'SU', 'SUPG', 'Ua'})
		hAxes.TickLabelInterpreter = 'latex';
		ylabel('Absolute misfit area (km$^2$)', 'Interpreter', 'latex')
		title(figtitles{iid}, 'Interpreter', 'latex')
		if contains(figtitles{iid}, '5000')
			ylim([0,23*5])
		else
			ylim([0,23])
		end

		set(gcf,'color','w');
		if saveflag
			export_fig([figName, '.pdf'])
		end
	end
	%}}}
end %}}}
