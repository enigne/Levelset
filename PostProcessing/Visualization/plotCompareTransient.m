clear
close all

glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
figNamePrefix = [projPath, 'PostProcessing/Figures/test_'];

finalTime = 50;

Id = 0; % Latest experiments
Id = 20; % v=0 on the sides
Id = 30; % v=0 on the sides
%% Load data {{{
addpath([projPath, '/PostProcessing/']);
[folderList, nameList] = getFolderList(Id, 0);

% Load simulations from transient.mat
transData = loadData(folderList, 'levelset', [projPath, 'Models/']);
Ntrans = length(transData);
nsub = 4;
%}}}
%% Average behaviors {{{
figure('position',[0,500,800,1000])

for i = 1: Ntrans
	time = transData{i}.time;
	% number of misfit elements no abs
	subplot(nsub,1,1)
	plot(transData{i}.time, transData{i}.sum_misfit, 'LineWidth', 2);
	hold on

	subplot(nsub,1,2)
	plot(transData{i}.time, transData{i}.sum_abs_misfit, 'LineWidth', 2);
	hold on

	subplot(nsub,1,3)
	plot(transData{i}.time, transData{i}.total_misfit/1e6, 'LineWidth', 2);
	hold on

	subplot(nsub,1,4)
	plot(transData{i}.time, transData{i}.total_abs_misfit/1e6, 'LineWidth', 2);
	hold on
end
subplot(nsub, 1, 1);
title('total misfit in number of elements')
xlim([0, finalTime])
ylim([-400, 400])

subplot(nsub, 1, 2);
title('total abs misfit in number of elements')
xlim([0, finalTime])
ylim([0, 400])

subplot(nsub, 1, 3);
title('total misfit area (km^2)')
xlim([0, finalTime])
ylim([-1e4, 1e4])

subplot(nsub, 1, 4);
title('total abs misfit area (km^2)')
xlim([0, finalTime])
ylim([0, 1e4])

legend(nameList, 'Interpreter', 'latex', 'Location', 'best')
set(gcf,'color','w');
%}}}
