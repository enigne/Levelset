L = 1000e3;
nx = 100;

%Mesh
md=squaremesh(model(), L, L, nx, nx);
md.miscellaneous.name = 'squaredomainlevelset';
cx = L/2;
cy = L/2;
radius = L/4;
v = 1000;

%Set mask and geometry
md=setmask(md,'','');
md.geometry.bed  = zeros(md.mesh.numberofvertices,1);
md.geometry.base = zeros(md.mesh.numberofvertices,1);
md.geometry.thickness = ones(md.mesh.numberofvertices,1);
md.geometry.surface   = md.geometry.base+md.geometry.thickness;

%velocity
md=setflowequation(md,'SSA','all');
md.initialization.vx = v*ones(md.mesh.numberofvertices, 1);
md.initialization.vy = zeros(md.mesh.numberofvertices, 1);
md.initialization.vel = sqrt(md.initialization.vx.^2 + md.initialization.vy.^2);

%calving and levelset
md.frontalforcings.meltingrate = zeros(md.mesh.numberofvertices,1);
md.calving.calvingrate = zeros(md.mesh.numberofvertices,1);
md.levelset.spclevelset = NaN(md.mesh.numberofvertices,1);
md.levelset.reinit_frequency = 1; %does not really help...
md.levelset.stabilization=1; %1 art diff, 2: streamline up., 5:SUPG

% set ice mask
md.mask.ice_levelset = -ones(md.mesh.numberofvertices, 1);
fjord = ((md.mesh.x-cx).^2+(md.mesh.y-cy).^2 < radius^2);
fjord = fjord | (md.mesh.x>cx) & (md.mesh.y > cy-radius) & (md.mesh.y < cy+radius);
md.mask.ice_levelset(fjord) = 1;
md.mask.ice_levelset = reinitializelevelset(md, md.mask.ice_levelset);

%transient settings
md.transient.issmb            = 0;
md.transient.ismasstransport  = 0;
md.transient.isoceantransport = 0;
md.transient.isstressbalance  = 0;
md.transient.isthermal        = 0;
md.transient.ismovingfront    = 1;

%Time stepping
md.timestepping.start_time = 0;
md.timestepping.time_step  = cfl_step(md, md.initialization.vx, md.initialization.vy);
md.timestepping.final_time = 500;

%solve
md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
md.cluster = generic('np',50);
md=solve(md,'tr');

%save movie
plotmodel(md,'data','transient_movie','transient_movie_field','MaskIceLevelset','contourlevels',{0},'caxis',[-radius radius]/4,'transient_movie_output','temp.mp4',...
	'steps',round(linspace(1,numel(md.results.TransientSolution),150)))
