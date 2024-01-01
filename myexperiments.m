clear
close all

today = datestr(date(), 'yyyymmdd');
experiments = [3];

if any(experiments == 1) % exp 1: circle and straight, v0=1000, all four vx, reinit=[0,200] {{{

	finalTime = 0.5;
	repeatNt = 50;
	vx0 = [5000];
	dt = 0.005;
	output_frequency = 5;
	reinit = [0, 1, 10, 100, 200];
	stablization = [6];
	%vxshapes = {'parabola', 'gaussian', 'triangle', 'uniform'};
	vxshapes = { 'uniform'};

	for i = 1:length(reinit)
		for j = 1:length(vxshapes)
			for k = 1:length(vx0)
				for l = 1:length(stablization)
					savePath = [today, '_LS_circle_', vxshapes{j},'_vx', num2str(vx0(k)), '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
					steps = [10];
					md = runme('steps', steps,...
						'cluster name', 'discovery',...
						'dt', dt, ...
						'output frequency', output_frequency, ...
						'finalTime', finalTime,...
						'vx shape', vxshapes{j},...
						'vx', vx0(k),...
						'repeat times', repeatNt, ...
						'levelset stabilization', stablization(l),...
						'levelset reinitialize', reinit(i),...
						'savePath', [savePath]);

					steps = [11];
					savePath = [today, '_LS_rectangle_', vxshapes{j},'_vx', num2str(vx0(k)), '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
					md = runme('steps', steps,...
						'cluster name', 'discovery',...
						'dt', dt, ...
						'output frequency', output_frequency, ...
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
end %}}}
if any(experiments == 2) % exp 2: unstructured mesh{{{
	steps = [1, 3:5];
	md = runme('steps', steps);
end %}}}
if any(experiments == 3) % exp 3: circle and straight, v0=1000, all four vx, reinit=[0,1, 10, 100, 200] {{{

	finalTime = 0.5;
	repeatNt = 50;
	vx0 = [5000];
	dt = 0.0025;
	output_frequency = 10;
	reinit = [0, 1, 10, 100, 200];
	stablization = [1,2,5,6];
	%vxshapes = {'parabola', 'gaussian', 'triangle', 'uniform'};
	vxshapes = { 'uniform', 'parabola', 'triangle'};

	for i = 1:length(reinit)
		for j = 1:length(vxshapes)
			for k = 1:length(vx0)
				for l = 1:length(stablization)
					savePath = [today, '_LS_circle_', vxshapes{j},'_vx', num2str(vx0(k)), '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
					steps = [10];
					md = runme('steps', steps,...
						'cluster name', 'discovery',...
						'dt', dt, ...
						'output frequency', output_frequency, ...
						'finalTime', finalTime,...
						'vx shape', vxshapes{j},...
						'vx', vx0(k),...
						'repeat times', repeatNt, ...
						'levelset stabilization', stablization(l),...
						'levelset reinitialize', reinit(i),...
						'savePath', [savePath]);

					pause(5)
					steps = [11];
					savePath = [today, '_LS_rectangle_', vxshapes{j},'_vx', num2str(vx0(k)), '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
					md = runme('steps', steps,...
						'cluster name', 'discovery',...
						'dt', dt, ...
						'output frequency', output_frequency, ...
						'finalTime', finalTime,...
						'vx shape', vxshapes{j},...
						'vx', vx0(k),...
						'repeat times', repeatNt, ...
						'levelset stabilization', stablization(l),...
						'levelset reinitialize', reinit(i),...
						'savePath', [savePath]);

					pause(5)
				end
			end
		end
	end
end %}}}
if any(experiments == 4) % exp 4: unstructured mesh 200 res{{{
	steps = [1, 3:5];
	md = runme('steps', steps, 'nx', 100);
end %}}}
if any(experiments == 5) % exp 5: circle and straight, v0=1000, 5000, uniform, 200m resolution, reinit=[0,1, 10, 100, 200] {{{

	finalTime = 0.5;
	repeatNt = 50;
	vx0 = [1000];
	dt = 0.005;
	output_frequency = 5;
	reinit = [0, 1, 10, 100, 200];
	stablization = [1,2,5,6];
	%vxshapes = {'parabola', 'gaussian', 'triangle', 'uniform'};
	vxshapes = { 'uniform'};

	for i = 1:length(reinit)
		for j = 1:length(vxshapes)
			for k = 1:length(vx0)
				for l = 1:length(stablization)
					savePath = [today, '_LS_circle_', vxshapes{j},'_vx', num2str(vx0(k)), '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
					steps = [10];
					md = runme('steps', steps,...
						'cluster name', 'discovery',...
						'dt', dt, ...
						'output frequency', output_frequency, ...
						'finalTime', finalTime,...
						'vx shape', vxshapes{j},...
						'vx', vx0(k),...
						'repeat times', repeatNt, ...
						'levelset stabilization', stablization(l),...
						'levelset reinitialize', reinit(i),...
						'savePath', [savePath]);

					pause(5)
					steps = [11];
					savePath = [today, '_LS_rectangle_', vxshapes{j},'_vx', num2str(vx0(k)), '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
					md = runme('steps', steps,...
						'cluster name', 'discovery',...
						'dt', dt, ...
						'output frequency', output_frequency, ...
						'finalTime', finalTime,...
						'vx shape', vxshapes{j},...
						'vx', vx0(k),...
						'repeat times', repeatNt, ...
						'levelset stabilization', stablization(l),...
						'levelset reinitialize', reinit(i),...
						'savePath', [savePath]);

					pause(5)
				end
			end
		end
	end
end %}}}
if any(experiments == 6) % exp 6: unstructured mesh 400 res{{{
	steps = [1, 3:5];
	md = runme('steps', steps, 'nx', 50);
end %}}}
if any(experiments == 7) % exp 7: circle and straight, v0=1000, 5000, uniform, 400m resolution, reinit=[0,1, 10, 100, 200] {{{

	finalTime = 0.5;
	repeatNt = 50;
	vx0 = [1000];
	dt = 0.005;
	output_frequency = 5;
	reinit = [0, 1, 10, 100, 200];
	stablization = [1,2,5,6];
	%vxshapes = {'parabola', 'gaussian', 'triangle', 'uniform'};
	vxshapes = { 'uniform'};

	for i = 1:length(reinit)
		for j = 1:length(vxshapes)
			for k = 1:length(vx0)
				for l = 1:length(stablization)
					savePath = [today, '_LS_circle_400_', vxshapes{j},'_vx', num2str(vx0(k)), '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
					steps = [10];
					md = runme('steps', steps,...
						'cluster name', 'discovery',...
						'dt', dt, ...
						'output frequency', output_frequency, ...
						'finalTime', finalTime,...
						'vx shape', vxshapes{j},...
						'vx', vx0(k),...
						'repeat times', repeatNt, ...
						'levelset stabilization', stablization(l),...
						'levelset reinitialize', reinit(i),...
						'savePath', [savePath]);

					pause(5)
					steps = [11];
					savePath = [today, '_LS_rectangle_400_', vxshapes{j},'_vx', num2str(vx0(k)), '_stab', num2str(stablization(l)), '_reinit', num2str(reinit(i))];
					md = runme('steps', steps,...
						'cluster name', 'discovery',...
						'dt', dt, ...
						'output frequency', output_frequency, ...
						'finalTime', finalTime,...
						'vx shape', vxshapes{j},...
						'vx', vx0(k),...
						'repeat times', repeatNt, ...
						'levelset stabilization', stablization(l),...
						'levelset reinitialize', reinit(i),...
						'savePath', [savePath]);

					pause(5)
				end
			end
		end
	end
end %}}}
