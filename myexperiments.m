clear
close all

today = datestr(date(), 'yyyymmdd');
today = '20220603'

finalTime = 2.5;
reinit = [0, 1, 10, 50, 100];
stablization = [1,2,5];


steps = [8];
for i = 1:length(reinit)
	for l = 1:length(stablization)
		savePath = [today, '_LevelsetTest_circle', '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
		md = runme('steps', steps,...
			'finalTime', finalTime,...
			'levelset stabilization', stablization(l),...
			'levelset reinitialize', reinit(i),...
			'savePath', [savePath]);
	end
end

steps = [9];
for i = 1:length(reinit)
	for l = 1:length(stablization)
		savePath = [today, '_LevelsetTest_circle_zeroSide', '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
		md = runme('steps', steps,...
			'finalTime', finalTime,...
			'levelset stabilization', stablization(l),...
			'levelset reinitialize', reinit(i),...
			'savePath', [savePath]);
	end
end

steps = [10];
for i = 1:length(reinit)
	for l = 1:length(stablization)
		savePath = [today, '_LevelsetTest_rect', '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
		md = runme('steps', steps,...
			'finalTime', finalTime,...
			'levelset stabilization', stablization(l),...
			'levelset reinitialize', reinit(i),...
			'savePath', [savePath]);
	end
end

steps = [11];
for i = 1:length(reinit)
	for l = 1:length(stablization)
		savePath = [today, '_LevelsetTest_rect_zeroSide', '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
		md = runme('steps', steps,...
			'finalTime', finalTime,...
			'levelset stabilization', stablization(l),...
			'levelset reinitialize', reinit(i),...
			'savePath', [savePath]);
	end
end
