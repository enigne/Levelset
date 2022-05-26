function extractTransientFromMd(md, projPath, folder, dataName, saveflag)

	%% extract time dependent solutions {{{
	% output 
	disp(['==== Start to process on ', folder]);
	name = dataName;
	time = cell2mat({md.results.TransientSolution(:).time});
	ice_levelset = cell2mat({md.results.TransientSolution(:).MaskIceLevelset});
	disp(['======> Finish data extraction ', folder]);

	disp(['======> Calculate analytical solution']);
	cx0 = md.results.analyticalSolution.cx;
	cy0 = md.results.analyticalSolution.cy;
	vx = md.results.analyticalSolution.vx;
	vy = md.results.analyticalSolution.vy;
	radius = md.results.analyticalSolution.radius;

	% time series of the center positions 
	cx = time.*vx + cx0;
	cy = time.*vy + cy0;

	analytical_levelset = setLevelset(md.mesh.x, md.mesh.y, cx, cy, radius);
	disp(['======> Finish calculation, size of the solution: ', num2str(size(analytical_levelset))]);

	disp(['======> Calculate the misfit of the two sign functions']);
	misfit = sign(analytical_levelset) - sign(ice_levelset);
	sum_misfit = sum(misfit, 1);
	sum_abs_misfit = sum(abs(misfit), 1);

	[total_misfit, ~, ~] =integrateOverDomain(md, misfit);
	[total_abs_misfit, ~, ~] =integrateOverDomain(md, abs(misfit));

	disp(['======> Finish the misfit: ']);
	disp(['          total misfit: ', num2str(min(total_misfit)), ' -- '  num2str(max(total_misfit))]);
	disp(['          abs misfit  : ', num2str(min(total_abs_misfit)), ' -- '  num2str(max(total_abs_misfit))]);

	% save data
	if saveflag
		savePath = [projPath, 'Models/', folder, '/'];
		disp(['======> Saving to ', savePath]);
		save([savePath, 'levelsetSolutions', '.mat'], 'name',...
			'time', 'ice_levelset', 'analytical_levelset', 'total_misfit',...
			'total_abs_misfit', 'sum_misfit', 'sum_abs_misfit');
		disp(['======> Saving complete ']);
	end
	%}}}
