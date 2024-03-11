clear
close all
%
glacier = 'Levelset';
projPath = ['/totten_1/chenggong/', glacier, '/'];
figNamePrefix = [pwd(), '/Figures/'];

Lx = 20e3;
nx = 10;
Ly = Lx;
ny = nx;
% diagonally aligned mesh
md=squaremesh(model(), Lx, Ly, nx, ny);
figure('Position', [0,1000,300,300])
plotmodel(md, 'data', 'mesh')
axis('off')
title('Diagonally aligned mesh')
set(gcf,'color','w');
export_fig([figNamePrefix, 'diagonal_mesh.pdf'])

% unstructured mesh
md=triangle(model(), [pwd(), '/../../Exp/square.exp'], Lx/nx);
plotmodel(md, 'data', 'mesh')
axis('off')
title('Unstructured mesh')
set(gcf,'color','w');
export_fig([figNamePrefix, 'unstructured_mesh.pdf'])

% symmetric mesh
md=squaremesh(model(), Lx, Ly, nx, ny, 1, 3);
plotmodel(md, 'data', 'mesh')
axis('off')
title('Symmetric mesh')
set(gcf,'color','w');
export_fig([figNamePrefix, 'symmetric_mesh.pdf'])
