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
	%GET size of the domain: 1e6x1e6{{{
	Lx = getfieldvalue(options,'Lx',1e6);
	Ly = getfieldvalue(options,'Ly',Lx);
	% }}}
	%GET number of elements: 200x200{{{
	nx = getfieldvalue(options,'nx',200);
	ny = getfieldvalue(options,'ny',nx);
	% }}}
	%GET constant velocity fielld: (7500, 0){{{
	vx = getfieldvalue(options,'vx', 7500);
	vy = getfieldvalue(options,'vy', 0);
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
	%GET dt: 0.25{{{
	dt = getfieldvalue(options,'dt', 0.25);
	% }}}
	%GET finalTime: 50{{{
	finalTime = getfieldvalue(options,'finalTime', 50);
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
		md=squaremesh(model(), Lx, Ly, nx, ny);
		savemodel(org,md);
	end %}}}
	if perform(org, 'Param')% {{{

		md=loadmodel(org,'Mesh');

		%velocity
		md=setflowequation(md,'SSA','all');
		md.initialization.vx = vx*ones(md.mesh.numberofvertices, 1);
		md.initialization.vy = vy*ones(md.mesh.numberofvertices, 1);
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
		md.mask.ice_levelset = reinitializelevelset(md, setLevelset(md.mesh.x, md.mesh.y, cx, cy, radius));

		savemodel(org,md);
	end%}}}
	if perform(org, 'Transient_Prep'),% {{{

		md=loadmodel(org, 'SetMask');
		%transient settings
		md.transient.issmb            = 0;
		md.transient.ismasstransport  = 0;
		md.transient.isoceantransport = 0;
		md.transient.isstressbalance  = 0;
		md.transient.isthermal        = 0;
		md.transient.ismovingfront    = 1;

		md.timestepping.start_time = 0;
		md.timestepping.final_time = finalTime;
		md.timestepping.time_step  = min(dt, cfl_step(md, md.initialization.vx, md.initialization.vy));

		savemodel(org,md);
	end%}}}
	if perform(org, 'Transient')% {{{

		md=loadmodel(org, 'Transient_Prep');

		% set stabilization
		md.levelset.stabilization = levelsetStabilization;
		disp(['  Levelset function uses stabilization ', num2str(md.levelset.stabilization)]);
		md.levelset.reinit_frequency = levelsetReinit;
		disp(['  Levelset function reinitializes every ', num2str(md.levelset.reinit_frequency), ' time steps']);

		% append Lx, Ly, cx, cy, radius, vx and vy to results
		analyticalSolution.Lx = Lx;
		analyticalSolution.Ly = Ly;
		analyticalSolution.cx = cx;
		analyticalSolution.cy = cy;
		analyticalSolution.vx = vx;
		analyticalSolution.vy = vy;
		analyticalSolution.radius = radius;
		md.results.analyticalSolution = analyticalSolution;

		%solve
		md.miscellaneous.name = [savePath];
		md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
		md.cluster = cluster;
		md.settings.waitonlock = waitonlock; % do not wait for complete
		md.verbose.solution = 1;
		md=solve(md,'tr');

		savemodel(org,md);
		if ~strcmp(savePath, './')
			system(['mkdir -p ', projPath, '/Models/', savePath]);
			system(['mv ', projPath, '/Models/Model_', glacier, '_Transient.mat ', projPath, '/Models/', savePath, '/Model_', glacier, '_Transient.mat']);
		end
	end%}}}
	if perform(org, 'Transient_Advance_Retreat')% {{{

		md=loadmodel(org, 'Transient_Prep');

		% set stabilization
		md.levelset.stabilization = levelsetStabilization;
		disp(['  Levelset function uses stabilization ', num2str(md.levelset.stabilization)]);
		md.levelset.reinit_frequency = levelsetReinit;
		disp(['  Levelset function reinitializes every ', num2str(md.levelset.reinit_frequency), ' time steps']);

		%solve
		md.miscellaneous.name = [savePath];
		md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
		md.cluster = cluster;
		md.settings.waitonlock = waitonlock; % do not wait for complete
		md.verbose.solution = 1;

		% Advance run
		md=solve(md,'tr');

		% compute analytical solutions
		time = cell2mat({md.results.TransientSolution(:).time});
		cxt = time.*vx + cx;
		cyt = time.*vy + cy;
		analytical_levelset = setLevelset(md.mesh.x, md.mesh.y, cxt, cyt, radius);
		md.results.analyticalSolution = analytical_levelset;

		disp(['  ==== Advance run done! '])
		% save advance run
		advanceSolutions = md.results.TransientSolution;
		% reset initial condition
		md.initialization.vx = -vx*ones(md.mesh.numberofvertices, 1);
		md.initialization.vy = vy*ones(md.mesh.numberofvertices, 1);
		md.initialization.vel = sqrt(md.initialization.vx.^2 + md.initialization.vy.^2);
		% use the final step advance solution as initial
		md.mask.ice_levelset = reinitializelevelset(md, md.results.TransientSolution(end).MaskIceLevelset);

		% change time
		finalTime = md.results.TransientSolution(end).time;
		md.timestepping.start_time = finalTime;
		md.timestepping.final_time = finalTime*2;

		disp(['  ==== Start to run retreat '])
		% Retreat run
		md=solve(md,'tr');
		
		% analytial solutions
      cxt = fliplr(cxt);
      analytical_levelset = setLevelset(md.mesh.x, md.mesh.y, cxt, cyt, radius);

		% append the retreat solution to the advance
		md.results.TransientSolution = [advanceSolutions, md.results.TransientSolution];
		md.results.analyticalSolution = [md.results.analyticalSolution, analytical_levelset];

		savemodel(org,md);
		if ~strcmp(savePath, './')
			system(['mkdir -p ', projPath, '/Models/', savePath]);
			system(['mv ', projPath, '/Models/Model_', glacier, '_Transient_Advance_Retreat.mat ', projPath, '/Models/', savePath, '/Model_', glacier, '_Transient.mat']);
		end
	end%}}}
	varargout{1} = md;
	return;
