clear
close all

today = datestr(date(), 'yyyymmdd');

finalTime = 0.5;
repeatNt = 50;
vx0 = [1000, 5000];
reinit = [1, 10, 100];
stablization = [1, 2, 5];
vxshapes = {'parabola', 'gaussian', 'triangle', 'uniform'};


steps = [10];
for i = 1:length(reinit)
	for j = 1:length(vxshapes)
		for k = 1:length(vx0)
			for l = 1:length(stablization)
				savePath = [today, '_LS_circle_', vxshapes{j},'_vx', num2str(vx0(k)), '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
				md = runme('steps', steps,...
					'cluster name', 'discovery',...
					'finalTime', finalTime,...
					'vx shape', vxshapes{j},...
					'vx', vx0(k),...
					'repeat times', repeatNt, ...
					'levelset stabilization', stablization(l),...
					'levelset reinitialize', reinit(i),...
					'savePath', [savePath]);
			end
		end
	end
end

steps = [11];
for i = 1:length(reinit)
	for j = 1:length(vxshapes)
		for k = 1:length(vx0)
			for l = 1:length(stablization)
				savePath = [today, '_LS_rectangle_', vxshapes{j},'_vx', num2str(vx0(k)), '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
				md = runme('steps', steps,...
					'cluster name', 'discovery',...
					'finalTime', finalTime,...
					'vx shape', vxshapes{j},...
					'vx', vx0(k),...
					'repeat times', repeatNt, ...
					'levelset stabilization', stablization(l),...
					'levelset reinitialize', reinit(i),...
					'savePath', [savePath]);
			end
		end
	end
end
%
%steps = [7];
%for i = 1:length(reinit)
%	for l = 1:length(stablization)
%		savePath = [today, '_LevelsetTest_circle_zeroSide', '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
%		md = runme('steps', steps,...
%			'finalTime', finalTime,...
%			'levelset stabilization', stablization(l),...
%			'levelset reinitialize', reinit(i),...
%			'savePath', [savePath]);
%	end
%end
%
%steps = [8];
%for i = 1:length(reinit)
%	for l = 1:length(stablization)
%		savePath = [today, '_LevelsetTest_rect', '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
%		md = runme('steps', steps,...
%			'finalTime', finalTime,...
%			'levelset stabilization', stablization(l),...
%			'levelset reinitialize', reinit(i),...
%			'savePath', [savePath]);
%	end
%end
%
%steps = [9];
%for i = 1:length(reinit)
%	for l = 1:length(stablization)
%		savePath = [today, '_LevelsetTest_rect_zeroSide', '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
%		md = runme('steps', steps,...
%			'finalTime', finalTime,...
%			'levelset stabilization', stablization(l),...
%			'levelset reinitialize', reinit(i),...
%			'savePath', [savePath]);
%	end
%end
