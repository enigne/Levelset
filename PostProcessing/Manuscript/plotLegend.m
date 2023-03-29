clear
close all

glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
figNamePrefix = [pwd(), '/Figures/'];
figName = 'legend';
saveflag = 1;

linestyles = {'-', ':', '--'};
colorstyle = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#77AC30'};
stabName = {'AD', 'UW', 'SUPG'};
reinitName = {'$\tau=1$', '$\tau=10$', '$\tau=100$', '$\tau=200$', '$\tau=\infty$'};
nameList = [reinitName, stabName];
Nlines = 3;
% start the loop {{{
figure('position',[0,1000,900,400])
hold on
for i = 1:length(colorstyle)
	plot([1:1],[1:1], 'LineWidth', 2, 'Color', colorstyle{i}, 'LineStyle', '-')
end
for i = 1:length(linestyles)
	plot([1:1],[1:1], 'LineWidth', 2, 'Color', '#888888', 'LineStyle', linestyles{i})
end %}}}
legend(nameList, 'Interpreter', 'latex','Orientation','horizontal','Location','northoutside')
set(gcf,'color','w');
if saveflag
	export_fig([figNamePrefix, figName, '.pdf'])
end
%}}}
