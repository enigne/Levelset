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
	%GET constant velocity fielld: (1000, 0){{{
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
	%GET finalTime: 500{{{
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
		md.mask.ice_levelset = -ones(md.mesh.numberofvertices, 1);
		fjord = ((md.mesh.x-cx).^2+(md.mesh.y-cy).^2 < radius^2);
		fjord = fjord | (md.mesh.x>cx) & (md.mesh.y > cy-radius) & (md.mesh.y < cy+radius);
		md.mask.ice_levelset(fjord) = 1;
		md.mask.ice_levelset = reinitializelevelset(md, md.mask.ice_levelset);

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
		md.timestepping.time_step  = cfl_step(md, md.initialization.vx, md.initialization.vy);
		md.timestepping.final_time = finalTime;

		savemodel(org,md);
	end%}}}
	if perform(org, 'Transient')% {{{

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
		md=solve(md,'tr');

		savemodel(org,md);
		if ~strcmp(savePath, './')
			system(['mkdir -p ', projPath, '/Models/', savePath]);
			system(['mv ', projPath, '/Models/Model_', glacier, '_Transient.mat ', projPath, '/Models/', savePath, '/Model_', glacier, '_Transient.mat']);
		end
	end%}}}
