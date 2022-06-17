function extractTransientFromMd(md, projPath, folder, dataName, mdref, saveflag)

	if isempty(mdref)
		compareToFine = 0;
	else 
		compareToFine = 1;
	end
	hasAnalytical = 0;
	%% extract time dependent solutions {{{
	% output 
	disp(['==== Start to process on ', folder]);
	name = dataName;
	time = cell2mat({md.results.TransientSolution(:).time});
	ice_levelset = cell2mat({md.results.TransientSolution(:).MaskIceLevelset});
	% analytical solutions
	if isfield(md.results, 'analyticalSolution')
		hasAnalytical = 1;
		error('not updated the analytical_levelset, need to remove the duplicated data')
	else
		hasAnalytical = 0;
		% use the first round solution of advance phase as the reference solution
		repeatNt = md.results.timesettings.repeatNt;
		NT = floor(length(time)/repeatNt);
		startT = rem(length(time), repeatNt);
		% if startT is not 0 then remove the first few steps
		ice_levelset = ice_levelset(:, 1+startT:end);
		time = time(1+startT:end);
		analytical_levelset = ice_levelset(:, 1:NT);
	end
	disp(['======> Finish data extraction ', folder]);

	% recompute analytical solution if use finer mesh
	if compareToFine 
		disp(['======> Use a finer mesh with ', num2str(mdref.mesh.numberofelements), ' elements']);
		ind = [NT:NT:length(time)];
		numerical_sol = InterpFromMeshToMesh2d(md.mesh.elements,md.mesh.x,md.mesh.y,ice_levelset(:,ind),mdref.mesh.x, mdref.mesh.y);

		disp(['======> Project reference solution to a finer mesh']);
		ref_sol = InterpFromMeshToMesh2d(md.mesh.elements,md.mesh.x,md.mesh.y,md.mask.ice_levelset,mdref.mesh.x, mdref.mesh.y);
		analytical_sol = repmat(ref_sol, 1, repeatNt);
		time_misfit = time(ind);
	else
		disp(['======> Use the computational mesh to evaluate the misfit for all the time steps']);
		numerical_sol = ice_levelset;
		analytical_sol = repmat(analytical_levelset, 1, repeatNt);
		time_misfit = time;
	end

	disp(['======> Calculate the misfit of the two sign functions']);
	misfit = sign(analytical_sol) - sign(numerical_sol);
	sum_misfit = sum(misfit, 1);
	sum_abs_misfit = sum(abs(misfit), 1);

	if compareToFine
		[total_misfit, ~, ~] =integrateOverDomain(mdref, misfit);
		[total_abs_misfit, ~, ~] =integrateOverDomain(mdref, abs(misfit));
	else
		[total_misfit, ~, ~] =integrateOverDomain(md, misfit);
		[total_abs_misfit, ~, ~] =integrateOverDomain(md, abs(misfit));
	end

	disp(['======> Finish the misfit: ']);
	disp(['          total misfit: ', num2str(min(total_misfit)), ' -- '  num2str(max(total_misfit))]);
	disp(['          abs misfit  : ', num2str(min(total_abs_misfit)), ' -- '  num2str(max(total_abs_misfit))]);

	% save data
	if saveflag
		savePath = [projPath, 'Models/', folder, '/'];
		disp(['======> Saving to ', savePath]);
		save([savePath, 'levelsetSolutions', '.mat'], 'name',...
			'time', 'ice_levelset', 'analytical_levelset', 'repeatNt', 'NT', 'total_misfit',...
			'total_abs_misfit', 'sum_misfit', 'sum_abs_misfit', 'time_misfit');
		disp(['======> Saving complete ']);
	end
	%}}}
