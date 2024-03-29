clear
close all

glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
figNamePrefix = [pwd(), '/Figures/'];
figName = 'legend';
saveflag = 1;

linestyles = {'-', ':', '--', '-.'};
colorstyle = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#77AC30'};
stabName = {'AD', 'UW', 'SUPG', 'SUPG+FAB'};
reinitName = {'$n_R=1$', '$n_R=10$', '$n_R=100$', '$n_R=200$', '$n_R=\infty$'};
nameList = [reinitName, stabName];
Nlines = 3;
% Make the legend {{{
figure('position',[0,1000,900,400])
hold on
for i = 1:length(colorstyle)
	plot([1:1],[1:1], 'LineWidth', 2, 'Color', colorstyle{i}, 'LineStyle', '-')
end
for i = 1:length(linestyles)
	plot([1:1],[1:1], 'LineWidth', 2, 'Color', '#888888', 'LineStyle', linestyles{i})
end 
legend(nameList, 'Interpreter', 'latex','Orientation','horizontal','Location','northoutside')
set(gcf,'color','w');
if saveflag
	export_fig([figNamePrefix, figName, '.pdf'])
end
%}}}
% Make the colorbar {{{
figName = 'colorbar';
figure('position',[0,1000,400,200])
imagesc([1,2],[1,2],[-1,1])
cb = colorbar;
colormap([ 0         0    0.5;
0.5000    1.0000    0.5000;
0.5000         0         0])
cb.Ticks=[-1, 0, 1];
cb.TickLabels={'-1','0','1'};
set(gcf,'color','w');
if saveflag
	export_fig([figNamePrefix, figName, '.pdf'])
end
%}}}
