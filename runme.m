function varargout=runme(varargin)

	%Check inputs {{{
	if nargout>1
		help runme
		error('runme error message: bad usage');
	end
	%recover options
	options=pairoptions(varargin{:});
	% }}}
	%GET cluster name: 'totten'{{{
	clustername = getfieldvalue(options,'cluster name','totten');
	% }}}
	%GET size of the domain: 20e3x20e3, the width of the fjord=10km{{{
	Lx = getfieldvalue(options,'Lx', 20e3);
	Ly = getfieldvalue(options,'Ly', Lx);
	% }}}
	%GET number of elements: 200x200{{{
	nx = getfieldvalue(options,'nx',200);
	ny = getfieldvalue(options,'ny',nx);
	% }}}
	%GET constant velocity fielld: (1500, 0){{{
	vx0 = getfieldvalue(options,'vx', 1500);
	vy0 = getfieldvalue(options,'vy', 0);
	% }}}
	%GET shape of vx: 'uniform' {{{
	vxshape = getfieldvalue(options,'vx shape', 'uniform');
	% }}}
	%GET radius of the circle: min(Lx,Ly)/4 {{{
	radius = getfieldvalue(options,'radius', min([Lx,Ly])/4);
	% }}}
	%GET center of the circle (cx,cy): (Lx/2+radius/2, Ly/2) {{{
	cx = getfieldvalue(options,'cx', Lx/2+radius/2);
	cy = getfieldvalue(options,'cy', Ly/2);
	% }}}
	%GET steps: [1]{{{
	steps = getfieldvalue(options,'steps',[1]);
	% }}}
	%GET savepath: '/' {{{
	savePath = getfieldvalue(options,'savePath', '/');
	% }}}
	%GET dt: 0.025{{{
	dt = getfieldvalue(options,'dt', 0.025);
	% }}}
	%GET finalTime: 5{{{
	finalTime = getfieldvalue(options,'finalTime', 2.5);
	% }}}
	%GET repeat advance and retreat: 1{{{
	repeatNt	= getfieldvalue(options,'repeat times', 1);
	% }}}
	%GET jobTime for running on supercomputer: 2 hours{{{
	jobTime = getfieldvalue(options,'jobTime', 2);
	% }}}
	%GET stabilization for levelset {{{
	levelsetStabilization = getfieldvalue(options,'levelset stabilization', 2);
	% }}}
	%GET reinitialization for levelset {{{
	levelsetReinit = getfieldvalue(options,'levelset reinitialize', 1);
	% }}}
	%GET output frequency {{{
	output_frequency = getfieldvalue(options,'output frequency', 1);
	% }}}

	%Load some necessary codes {{{
	% main setting
	glacier = 'Levelset'; hem='n';

	addpath(['/totten_1/chenggong/', glacier, '/PostProcessing/']);
	addpath(['/totten_1/chenggong/', glacier, '/src/']);
	projPath = ['/totten_1/chenggong/', glacier, '/'];
	% }}}
	%Cluster parameters{{{
	if strcmpi(clustername,'pfe')
		cluster=pfe('numnodes',1,'time',60,'processor','bro','cpuspernode',28,'queue','devel'); %max time is 120 (2hr) and max cpuspernode is 28 for 'bro'
		cluster=pfe('numnodes',1,'time',60,'processor','bro','cpuspernode',28,'queue','normal');
	elseif strcmpi(clustername,'discovery')
		cluster=discovery('numnodes',1,'cpuspernode',16);
		cluster.time = jobTime;
		waitonlock = 0;
	else
		cluster=generic('name',oshostname(),'np', 30);
		waitonlock = Inf;
	end
	clear clustername
	org=organizer('repository',['./Models'],'prefix',['Model_' glacier '_'],'steps',steps); clear steps;
	fprintf(['\n  ========  ' upper(glacier) '  ========\n\n']);
	%}}}

	%%%%%% Step 1--10
	if perform(org, 'Mesh')% {{{
		%md=squaremesh(model(), Lx, Ly, nx, ny);
		md=triangle(model(), 'Exp/square.exp', Lx/nx);
		savemodel(org,md);
	end %}}}
	if perform(org, 'SuperfineMesh')% {{{
	%	mdref=squaremesh(model(), Lx, Ly, nx*10, ny*10);
		mdref=triangle(model(), 'Exp/square.exp', Lx/nx/10);
		savemodel(org, mdref);
	end %}}}
	if perform(org, 'Param')% {{{

		md=loadmodel(org,'Mesh');

		%velocity
		md=setflowequation(md,'SSA','all');
		md.initialization.vx = vx0*ones(md.mesh.numberofvertices, 1);
		md.initialization.vy = vy0*ones(md.mesh.numberofvertices, 1);
		md.initialization.vel = sqrt(md.initialization.vx.^2 + md.initialization.vy.^2);

		%Set mask and geometry
		md=setmask(md,'','');
		md.geometry.bed  = zeros(md.mesh.numberofvertices,1);
		md.geometry.base = zeros(md.mesh.numberofvertices,1);
		md.geometry.thickness = ones(md.mesh.numberofvertices,1);
		md.geometry.surface   = md.geometry.base+md.geometry.thickness;

		savemodel(org,md);
	end%}}}
	if perform(org, 'SetMask')% {{{

		md=loadmodel(org,'Param');

		%calving and levelset
		md.frontalforcings.meltingrate = zeros(md.mesh.numberofvertices,1);
		md.calving.calvingrate = zeros(md.mesh.numberofvertices,1);
		md.levelset.spclevelset = NaN(md.mesh.numberofvertices,1);

		% set ice mask
		mdref = loadmodel(org, 'SuperfineMesh');
		ice_levelset = reinitializelevelset(mdref, setLevelset(mdref.mesh.x, mdref.mesh.y, cx, cy, radius));
		md.mask.ice_levelset = InterpFromMeshToMesh2d(mdref.mesh.elements, mdref.mesh.x, mdref.mesh.y, ice_levelset, md.mesh.x, md.mesh.y);

		md.transient.issmb            = 0;
		md.transient.ismasstransport  = 0;
		md.transient.isoceantransport = 0;
		md.transient.isstressbalance  = 0;
		md.transient.isthermal        = 0;
		md.transient.ismovingfront    = 1;

		savemodel(org,md);
	end%}}}
	if perform(org, 'SetRectMask')% {{{

		md=loadmodel(org,'Param');

		%calving and levelset
		md.frontalforcings.meltingrate = zeros(md.mesh.numberofvertices,1);
		md.calving.calvingrate = zeros(md.mesh.numberofvertices,1);
		md.levelset.spclevelset = NaN(md.mesh.numberofvertices,1);

		% set ice mask
		mdref = loadmodel(org, 'SuperfineMesh');
		ice_levelset = reinitializelevelset(mdref, setRectangleLevelset(mdref.mesh.x, mdref.mesh.y, cx, cy, radius));
		md.mask.ice_levelset = InterpFromMeshToMesh2d(mdref.mesh.elements, mdref.mesh.x, mdref.mesh.y, ice_levelset, md.mesh.x, md.mesh.y);

		md.transient.issmb            = 0;
		md.transient.ismasstransport  = 0;
		md.transient.isoceantransport = 0;
		md.transient.isstressbalance  = 0;
		md.transient.isthermal        = 0;
		md.transient.ismovingfront    = 1;

		savemodel(org,md);
	end%}}}
	if perform(org, 'Transient_AdRe')% {{{

		md=loadmodel(org, 'SetMask');

		% set time
		md.timestepping.start_time = 0;
		md.timestepping.final_time = 2*finalTime;
		md.timestepping.time_step  = min(dt, cfl_step(md, md.initialization.vx, md.initialization.vy));

		% set stabilization
		md.levelset.stabilization = levelsetStabilization;
		disp(['  Levelset function uses stabilization ', num2str(md.levelset.stabilization)]);
		md.levelset.reinit_frequency = levelsetReinit;
		disp(['  Levelset function reinitializes every ', num2str(md.levelset.reinit_frequency), ' time steps']);

		% compute analytical solutions
		time = [dt:dt:finalTime, finalTime-dt:-dt:0];
		cxt = time.*vx0 + cx;
		cyt = time.*vy0 + cy;
		% analytial solutions
		md.results.analyticalSolution = setLevelset(md.mesh.x, md.mesh.y, cxt, cyt, radius);
		% save analytical settings
		md.results.analyticalSettings.cxt =cxt;
		md.results.analyticalSettings.cyt =cyt;
		md.results.analyticalSettings.radius = radius;
		md.results.analyticalSettings.domain = 'Semicircle';

		% prepare the initial condition
		timepoints = [md.timestepping.start_time, finalTime, finalTime+dt, md.timestepping.final_time];
		interpinit = [ones(md.mesh.numberofvertices+1, 2), -ones(md.mesh.numberofvertices+1, 2)];

		md.initialization.vx = vx0*interpinit;
		md.initialization.vy = vy0*interpinit;
		md.initialization.vel = sqrt(md.initialization.vx.^2 + md.initialization.vy.^2);
		md.initialization.vx(end,:) = timepoints;
		md.initialization.vy(end,:) = timepoints;
		md.initialization.vel(end,:) = timepoints;

		disp(['  ==== Start to solve '])

		%solve
		md.miscellaneous.name = [savePath];
		md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
		md.cluster = cluster;
		md.settings.waitonlock = waitonlock; % do not wait for complete
		md.verbose.solution = 0;

		% Advance run
		md=solve(md,'tr');

		savemodel(org,md);
		if ~strcmp(savePath, './')
			system(['mkdir -p ', projPath, '/Models/', savePath]);
			system(['mv ', projPath, '/Models/Model_', glacier, '_', org.steps(org.currentstep).string, '.mat ', projPath, '/Models/', savePath, '/Model_', glacier, '_Transient.mat']);
		end
	end%}}}
	if perform(org, 'Transient_AdRe_0side')% {{{

		md=loadmodel(org, 'SetMask');

		% set time
		md.timestepping.start_time = 0;
		md.timestepping.final_time = 2*finalTime;
		md.timestepping.time_step  = min(dt, cfl_step(md, md.initialization.vx, md.initialization.vy));

		% set stabilization
		md.levelset.stabilization = levelsetStabilization;
		disp(['  Levelset function uses stabilization ', num2str(md.levelset.stabilization)]);
		md.levelset.reinit_frequency = levelsetReinit;
		disp(['  Levelset function reinitializes every ', num2str(md.levelset.reinit_frequency), ' time steps']);

		% compute analytical solutions
		time = [dt:dt:finalTime, finalTime-dt:-dt:0];
		cxt = time.*vx0 + cx;
		cyt = time.*vy0 + cy;
		% analytial solutions
		md.results.analyticalSolution = setLevelset(md.mesh.x, md.mesh.y, cxt, cyt, radius);
		% save analytical settings
		md.results.analyticalSettings.cxt =cxt;
		md.results.analyticalSettings.cyt =cyt;
		md.results.analyticalSettings.radius = radius;
		md.results.analyticalSettings.domain = 'Semicircle';

		% prepare the initial condition
		timepoints = [md.timestepping.start_time, finalTime, finalTime+dt, md.timestepping.final_time];
		interpinit = [ones(md.mesh.numberofvertices+1, 2), -ones(md.mesh.numberofvertices+1, 2)];

		md.initialization.vx = vx0*interpinit;
		md.initialization.vy = vy0*interpinit;
		% remove the side
		pos = (md.mesh.y >= cy+radius) | (md.mesh.y <= cy - radius);
		md.initialization.vx(pos,:) = 0;

		md.initialization.vel = sqrt(md.initialization.vx.^2 + md.initialization.vy.^2);
		md.initialization.vx(end,:) = timepoints;
		md.initialization.vy(end,:) = timepoints;
		md.initialization.vel(end,:) = timepoints;

		disp(['  ==== Start to solve '])

		%solve
		md.miscellaneous.name = [savePath];
		md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
		md.cluster = cluster;
		md.settings.waitonlock = waitonlock; % do not wait for complete
		md.verbose.solution = 0;

		% Advance run
		md=solve(md,'tr');

		savemodel(org,md);
		if ~strcmp(savePath, './')
			system(['mkdir -p ', projPath, '/Models/', savePath]);
			system(['mv ', projPath, '/Models/Model_', glacier, '_', org.steps(org.currentstep).string, '.mat ', projPath, '/Models/', savePath, '/Model_', glacier, '_Transient.mat']);
		end
	end%}}}
	if perform(org, 'Transient_AdRe_rectangle')% {{{

		md=loadmodel(org, 'SetRectMask');

		% set time
		md.timestepping.start_time = 0;
		md.timestepping.final_time = 2*finalTime;
		md.timestepping.time_step  = min(dt, cfl_step(md, md.initialization.vx, md.initialization.vy));

		% set stabilization
		md.levelset.stabilization = levelsetStabilization;
		disp(['  Levelset function uses stabilization ', num2str(md.levelset.stabilization)]);
		md.levelset.reinit_frequency = levelsetReinit;
		disp(['  Levelset function reinitializes every ', num2str(md.levelset.reinit_frequency), ' time steps']);

		% compute analytical solutions
		time = [dt:dt:finalTime, finalTime-dt:-dt:0];
		cxt = time.*vx0 + cx;
		cyt = time.*vy0 + cy;
		% analytial solutions
		md.results.analyticalSolution = setRectangleLevelset(md.mesh.x, md.mesh.y, cxt, cyt, radius);
		% save analytical settings
		md.results.analyticalSettings.cxt =cxt;
		md.results.analyticalSettings.cyt =cyt;
		md.results.analyticalSettings.radius = radius;
		md.results.analyticalSettings.domain = 'rectangle';

		% prepare the initial condition
		timepoints = [md.timestepping.start_time, finalTime, finalTime+dt, md.timestepping.final_time];
		interpinit = [ones(md.mesh.numberofvertices+1, 2), -ones(md.mesh.numberofvertices+1, 2)];

		md.initialization.vx = vx0*interpinit;
		md.initialization.vy = vy0*interpinit;

		md.initialization.vel = sqrt(md.initialization.vx.^2 + md.initialization.vy.^2);
		md.initialization.vx(end,:) = timepoints;
		md.initialization.vy(end,:) = timepoints;
		md.initialization.vel(end,:) = timepoints;

		disp(['  ==== Start to solve '])

		%solve
		md.miscellaneous.name = [savePath];
		md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
		md.cluster = cluster;
		md.settings.waitonlock = waitonlock; % do not wait for complete
		md.verbose.solution = 0;

		% Advance run
		md=solve(md,'tr');

		savemodel(org,md);
		if ~strcmp(savePath, './')
			system(['mkdir -p ', projPath, '/Models/', savePath]);
			system(['mv ', projPath, '/Models/Model_', glacier, '_', org.steps(org.currentstep).string, '.mat ', projPath, '/Models/', savePath, '/Model_', glacier, '_Transient.mat']);
		end
	end%}}}
	if perform(org, 'Transient_AdRe_rectangle_0Side')% {{{

		md=loadmodel(org, 'SetRectMask');

		% set time
		md.timestepping.start_time = 0;
		md.timestepping.final_time = 2*finalTime;
		md.timestepping.time_step  = min(dt, cfl_step(md, md.initialization.vx, md.initialization.vy));

		% set stabilization
		md.levelset.stabilization = levelsetStabilization;
		disp(['  Levelset function uses stabilization ', num2str(md.levelset.stabilization)]);
		md.levelset.reinit_frequency = levelsetReinit;
		disp(['  Levelset function reinitializes every ', num2str(md.levelset.reinit_frequency), ' time steps']);

		% compute analytical solutions
		time = [dt:dt:finalTime, finalTime-dt:-dt:0];
		cxt = time.*vx0 + cx;
		cyt = time.*vy0 + cy;
		% analytial solutions
		md.results.analyticalSolution = setRectangleLevelset(md.mesh.x, md.mesh.y, cxt, cyt, radius);
		% save analytical settings
		md.results.analyticalSettings.cxt =cxt;
		md.results.analyticalSettings.cyt =cyt;
		md.results.analyticalSettings.radius = radius;
		md.results.analyticalSettings.domain = 'rectangle';


		% prepare the initial condition
		timepoints = [md.timestepping.start_time, finalTime, finalTime+dt, md.timestepping.final_time];
		interpinit = [ones(md.mesh.numberofvertices+1, 2), -ones(md.mesh.numberofvertices+1, 2)];

		md.initialization.vx = vx0*interpinit;
		md.initialization.vy = vy0*interpinit;
		% remove the side
		pos = (md.mesh.y >= cy+radius) | (md.mesh.y <= cy - radius);
		md.initialization.vx(pos,:) = 0;

		md.initialization.vel = sqrt(md.initialization.vx.^2 + md.initialization.vy.^2);
		md.initialization.vx(end,:) = timepoints;
		md.initialization.vy(end,:) = timepoints;
		md.initialization.vel(end,:) = timepoints;

		disp(['  ==== Start to solve '])

		%solve
		md.miscellaneous.name = [savePath];
		md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
		md.cluster = cluster;
		md.settings.waitonlock = waitonlock; % do not wait for complete
		md.verbose.solution = 0;

		% Advance run
		md=solve(md,'tr');

		savemodel(org,md);
		if ~strcmp(savePath, './')
			system(['mkdir -p ', projPath, '/Models/', savePath]);
			system(['mv ', projPath, '/Models/Model_', glacier, '_', org.steps(org.currentstep).string, '.mat ', projPath, '/Models/', savePath, '/Model_', glacier, '_Transient.mat']);
		end
	end%}}}
	if perform(org, 'Transient_circle_vx_vary')% {{{

		md=loadmodel(org, 'SetMask');

		% set time
		md.timestepping.start_time = 0;
		md.timestepping.final_time = 2*finalTime*repeatNt;

		% save the time settings to results
		md.results.timesettings.finalTime = finalTime;
		md.results.timesettings.repeatNt = repeatNt;

		% set stabilization
		md.levelset.stabilization = levelsetStabilization;
		disp(['  Levelset function uses stabilization ', num2str(md.levelset.stabilization)]);
		md.levelset.reinit_frequency = levelsetReinit;
		disp(['  Levelset function reinitializes every ', num2str(md.levelset.reinit_frequency), ' time steps']);

		pos = find(md.mesh.vertexonboundary);
		md.levelset.spclevelset(pos) = md.mask.ice_levelset(pos);

		% no analytical solutions
		% prepare the velocity field
		disp(['  Use ', vxshape, ' shape for the velocity field']);
		if (strcmp(vxshape, 'parabola'))
			vx = vx0 *(1 -(md.mesh.y./cy -1).^2);
		elseif (strcmp(vxshape, 'gaussian'))
			sigma = 2*radius / 3.0;
			vx = vx0 .* exp((-(md.mesh.y - cy).^2)./(2*sigma.^2));
		elseif (strcmp(vxshape, 'triangle'))
			vx = vx0 .* (1.0 - abs(md.mesh.y./cy-1));
		elseif (strcmp(vxshape, 'uniform'))
			vx = vx0 *ones(md.mesh.numberofvertices,1);
		else
			error('unknown shape of the horizontal velocity')
		end
		vy = vy0 *ones(md.mesh.numberofvertices,1);

		% follow the time points
		timepoints = zeros(1, 4*repeatNt);
		interpinit = zeros(1, 4*repeatNt);
		for i = 1:repeatNt
			timepoints((i-1)*4+1:i*4) = [(i-1)*2*finalTime+dt*3/4, ((i-1)*2+1)*finalTime+dt/4, ((i-1)*2+1)*finalTime+dt*3/4, (2*i)*finalTime+dt/4];
			interpinit((i-1)*4+1:i*4) = [1, 1, -1, -1];
		end

		md.initialization.vx = zeros(md.mesh.numberofvertices+1, 4*repeatNt);
		md.initialization.vy = zeros(md.mesh.numberofvertices+1, 4*repeatNt);
		md.initialization.vx(1:end-1, :) = vx * interpinit;
		md.initialization.vy(1:end-1, :) = vy * interpinit;
		md.initialization.vel = sqrt(md.initialization.vx.^2 + md.initialization.vy.^2);

		md.initialization.vx(end,:) = timepoints;
		md.initialization.vy(end,:) = timepoints;
		md.initialization.vel(end,:) = timepoints;

		pos = find(md.mesh.vertexonboundary);
		md.initialization.vx(pos,:) = 0;
		md.initialization.vy(pos,:) = 0;
		md.initialization.vel(pos,:) = 0;

		md.timestepping.time_step  = min(dt, cfl_step(md, md.initialization.vx(1:end-1, 1), md.initialization.vy(1:end-1,1)));
		md.settings.output_frequency = output_frequency;
		disp(['  ==== The output frequency is set to ', num2str(output_frequency), ', with the timestep dt=', num2str(md.timestepping.time_step)]);

		disp(['  ==== Start to solve '])

		%solve
		md.miscellaneous.name = [savePath];
		md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
		md.cluster = cluster;
		md.settings.waitonlock = waitonlock; % do not wait for complete
		md.verbose.solution = 0;

		% Advance run
		md=solve(md,'Transient','runtimename',false);

		savemodel(org,md);
		if ~strcmp(savePath, './')
			system(['mkdir -p ', projPath, '/Models/', savePath]);
			system(['mv ', projPath, '/Models/Model_', glacier, '_', org.steps(org.currentstep).string, '.mat ', projPath, '/Models/', savePath, '/Model_', glacier, '_Transient.mat']);
		end
	end%}}}

	%%%%%% Step 11--20
	if perform(org, 'Transient_rectangle_vx_vary')% {{{

		md=loadmodel(org, 'SetRectMask');

		% set time
		md.timestepping.start_time = 0;
		md.timestepping.final_time = 2*finalTime*repeatNt;

		% save the time settings to results
		md.results.timesettings.finalTime = finalTime;
		md.results.timesettings.repeatNt = repeatNt;

		% set stabilization
		md.levelset.stabilization = levelsetStabilization;
		disp(['  Levelset function uses stabilization ', num2str(md.levelset.stabilization)]);
		md.levelset.reinit_frequency = levelsetReinit;
		disp(['  Levelset function reinitializes every ', num2str(md.levelset.reinit_frequency), ' time steps']);

		pos = find(md.mesh.vertexonboundary);
		md.levelset.spclevelset(pos) = md.mask.ice_levelset(pos);

		% no analytical solutions
		% prepare the velocity field
		disp(['  Use ', vxshape, ' shape for the velocity field']);
		if (strcmp(vxshape, 'parabola'))
			vx = vx0 *(1 -(md.mesh.y./cy -1).^2);
		elseif (strcmp(vxshape, 'gaussian'))
			sigma = 2*radius / 3.0;
			vx = vx0 .* exp((-(md.mesh.y - cy).^2)./(2*sigma.^2));
		elseif (strcmp(vxshape, 'triangle'))
			vx = vx0 .* (1.0 - abs(md.mesh.y./cy-1));
		elseif (strcmp(vxshape, 'uniform'))
			vx = vx0 *ones(md.mesh.numberofvertices,1);
		else
			error('unknown shape of the horizontal velocity')
		end
		vy = vy0 *ones(md.mesh.numberofvertices,1);

		% follow the time points
		timepoints = zeros(1, 4*repeatNt);
		interpinit = zeros(1, 4*repeatNt);
		for i = 1:repeatNt
			timepoints((i-1)*4+1:i*4) = [(i-1)*2*finalTime+dt*3/4, ((i-1)*2+1)*finalTime+dt/4, ((i-1)*2+1)*finalTime+dt*3/4, (2*i)*finalTime+dt/4];
			interpinit((i-1)*4+1:i*4) = [1, 1, -1, -1];
		end

		md.initialization.vx = zeros(md.mesh.numberofvertices+1, 4*repeatNt);
		md.initialization.vy = zeros(md.mesh.numberofvertices+1, 4*repeatNt);
		md.initialization.vx(1:end-1, :) = vx * interpinit;
		md.initialization.vy(1:end-1, :) = vy * interpinit;
		md.initialization.vel = sqrt(md.initialization.vx.^2 + md.initialization.vy.^2);

		md.initialization.vx(end,:) = timepoints;
		md.initialization.vy(end,:) = timepoints;
		md.initialization.vel(end,:) = timepoints;

		pos = find(md.mesh.vertexonboundary);
		md.initialization.vx(pos,:) = 0;
		md.initialization.vy(pos,:) = 0;
		md.initialization.vel(pos,:) = 0;

		md.timestepping.time_step  = min(dt, cfl_step(md, md.initialization.vx(1:end-1, 1), md.initialization.vy(1:end-1,1)));
		md.settings.output_frequency = output_frequency;
		disp(['  ==== The output frequency is set to ', num2str(output_frequency), ', with the timestep dt=', num2str(md.timestepping.time_step)]);

		disp(['  ==== Start to solve '])

		%solve
		md.miscellaneous.name = [savePath];
		md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
		md.cluster = cluster;
		md.settings.waitonlock = waitonlock; % do not wait for complete
		md.verbose.solution = 0;

		% Advance run
		md=solve(md,'Transient','runtimename',false);

		savemodel(org,md);
		if ~strcmp(savePath, './')
			system(['mkdir -p ', projPath, '/Models/', savePath]);
			system(['mv ', projPath, '/Models/Model_', glacier, '_', org.steps(org.currentstep).string, '.mat ', projPath, '/Models/', savePath, '/Model_', glacier, '_Transient.mat']);
		end
	end%}}}
	varargout{1} = md;
	return;
