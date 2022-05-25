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
	disp(['======> Finish calculation ', num2str(size(analytical_levelset))]);

	% save data
	if saveflag
		savePath = [projPath, 'Models/', folder, '/'];
		disp(['======> Saving to ', savePath]);
		save([savePath, 'levelsetSolutions', '.mat'], 'name',...
			'time', 'ice_levelset', 'analytical_levelset');
		disp(['======> Saving complete ']);
	end
	%}}}
