clear
close all

glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
figNamePrefix = [projPath, 'PostProcessing/Figures/'];
saveflag = 1;
figName = [figNamePrefix, 'semicircle_side0'];

finalTime = 5;

Id = 0; % Latest experiments
Id = 102; % 10km rect
Id = 112; % 10km rect, side zero
Id = 122; % 10km circle
Id = 132; % 10km circle, side zero
%% Load data {{{
addpath([projPath, '/PostProcessing/']);
[folderList, nameList] = getFolderList(Id, 0);

% Load simulations from transient.mat
transData = loadData(folderList, 'levelset', [projPath, 'Models/']);
Ntrans = length(transData);
nsub = 2;
%}}}
%% Average behaviors {{{
figure('position',[0,500,800,500])

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
title('total misfit area (km^2)')
xlim([0, finalTime])
ylim([-4, 4])

subplot(nsub, 1, 2);
title('total abs misfit area (km^2)')
xlim([0, finalTime])
ylim([0, 4])

legend(nameList, 'Interpreter', 'latex', 'Location', 'best')
set(gcf,'color','w');
if saveflag
	export_fig([figName, '.pdf'])
end
%}}}
