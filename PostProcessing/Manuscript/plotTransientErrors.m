clear
close all
addpath('../')
glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
saveflag = 1;
stList = [1];%,2,5,6];
reList = [1];%100
%folderList = {['20240309_LS_circle_uniform_vx1000_stab', num2str(st), '_reinit', num2str(re), '/']};
%folderList = {['20231219_LS_circle_uniform_vx1000_stab', num2str(st), '_reinit', num2str(re), '/']};
%folderList = {['20230307_LS_rectangle_uniform_vx1000_stab', num2str(st), '_reinit', num2str(re), '/']};
%folderList = {['20230227_LS_circle_uniform_vx1000_stab', num2str(st), '_reinit', num2str(re), '/']};
prefix = '20240624_LS_circle_uniform_vx1000';
figNamePrefix = [projPath, 'PostProcessing/Manuscript/Figures/structured_mesh/refine50/'];

% load model
md = loadRefMd([projPath, 'Models/', prefix, '_stab1_reinit1'], 'Transient');

for ist = 1:numel(stList)
	for ire = 1:numel(reList)
		st = stList(ist); 
		re = reList(ire);

		folderList = {[prefix, '_stab', num2str(st), '_reinit', num2str(re), '/']};
		% Load data {{{
		% load data
		transData = loadData(folderList, 'levelset', [projPath, 'Models/']);
		NT = transData{1}.NT;
		%}}}
		% plot {{{
		id = [40, 20, 40, 40];
		t = [1, 2, 2, 50];
		nplot = numel(t);
		for i = 1:length(transData)
			for p = 1:nplot
				tid = id(p)+(t(p)-1)*NT;
				dist = 0.5*(sign(transData{i}.ice_levelset(:,tid)) - sign(transData{i}.analytical_levelset(:,id(p))));
				plotmodel(md, 'data', dist, 'figure', p, 'caxis', [-1,1], 'title', ['time=', num2str(transData{i}.time(tid))], 'figposition', [0,1000,500,400])
				xlabel('x (m)')
				ylabel('y (m)')
				colormap(jet)

				figName = [figNamePrefix, 'errors_st', num2str(st), '_re', num2str(re), '_t', replace(num2str(transData{i}.time(tid)),'.','_')];
				set(gcf,'color','w');
				if saveflag
					disp(['  Save to ', figName])
					export_fig([figName, '.pdf'])
				end
			end
		end
	end
end
%}}}
