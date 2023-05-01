clear
close all

glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
figNamePrefix = [pwd(), '/Figures/'];
saveflag = 0;
folderList = {'20230307_LS_circle_uniform_vx1000_stab1_reinit1/'};
id = 1;
t = [2, 10, 30, 50];
% Load data {{{
% load model
md = loadRefMd();
% load data
transData = loadData(folderList, 'levelset', [projPath, 'Models/']);
NT = transData{1}.NT;
nplot = numel(t);
%}}}
for i = 1:length(transData)
	figure('position',[0,1000,800,1000])
	for p = 1:nplot
		dist = 0.5*(sign(transData{i}.ice_levelset(:,id+(t(p)-1)*NT)) - sign(transData{i}.analytical_levelset(:,id)));
		plotmodel(md, 'data', dist, 'subplot', [2,ceil(nplot/2),p], 'figure', i, 'caxis', [-1,1])
	end

end
return


% start the loop {{{
for iid = 1:1
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
	for i = 1: 1
		figure('position',[0,1000,800,1000])
		for tid = 1:length(tList)


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
end
