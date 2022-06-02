clear
close all

today = datestr(date(), 'yyyymmdd');

finalTime = 25;
reinit = [0];%, 1, 10, 50, 100];
stablization = [1];%,2,5];
steps = [8];

for i = 1:length(reinit)
	for l = 1:length(stablization)
		savePath = [today, '_LevelsetTest_zeroSide', '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
		md = runme('steps', steps,...
			'finalTime', finalTime,...
			'levelset stabilization', stablization(l),...
			'levelset reinitialize', reinit(i),...
			'savePath', [savePath]);
	end
end
