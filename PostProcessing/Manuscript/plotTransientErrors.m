clear
close all

glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
figNamePrefix = [projPath, 'PostProcessing/Manuscript/Figures/'];
saveflag = 1;
st = 1; 
re = 1;
folderList = {['20230307_LS_circle_uniform_vx1000_stab', num2str(st), '_reinit', num2str(re), '/']};
% Load data {{{
% load model
md = loadRefMd();
% load data
transData = loadData(folderList, 'levelset', [projPath, 'Models/']);
NT = transData{1}.NT;
%}}}
% plot {{{
id = 40;
t = [2, 10, 25, 50];
nplot = numel(t);
for i = 1:length(transData)
	for p = 1:nplot
		tid = id+(t(p)-1)*NT;
		dist = 0.5*(sign(transData{i}.ice_levelset(:,tid)) - sign(transData{i}.analytical_levelset(:,id)));
		plotmodel(md, 'data', dist, 'figure', p, 'caxis', [-1,1], 'title', ['time=', num2str(transData{i}.time(tid))], 'figposition', [0,1000,500,400])
		xlabel('x (m)')
		ylabel('y (m)')

		figName = [figNamePrefix, 'errors_st', num2str(st), '_re', num2str(re), '_t', num2str(transData{i}.time(tid))];
		set(gcf,'color','w');
		if saveflag
			disp(['  Save to ', figName])
			export_fig([figName, '.pdf'])
		end
	end
end
%}}}
