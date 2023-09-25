clear
close all

nRows = 5;
nCols = 4;
subind = [1:20];
framesteps = 10;
%Ids = [301, 302, 303, 304];   % circle parabola
%movieNames = {'circle_parabola_v1000', 'circle_triangle_v1000', 'circle_gaussian_v1000', 'circle_uniform_v1000'};
%Ids = [304, 404, 314, 414];   % 
Ids = [314, 414];   % 
%movieNames = {'circle_uniform_v1000', 'rectangle_uniform_v1000', 'circle_uniform_v5000', 'rectangle_uniform_v5000'};
movieNames = {'circle_uniform_v5000', 'rectangle_uniform_v5000'};
for i = 1: length(Ids)
	generateAnimation('Id', Ids(i), 'movie name', movieNames{i}, 'nRows', nRows, 'nCols', nCols, 'index', subind, 'frame step', framesteps);
end

%nRows = 5;
%nCols = 3;
%subind = [1:15];

%Id = 101;   % 10km rect
%movieName = 'stabtest_rect_10km_refine';
%generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind);
%Id = 111;   % 10km rect, side zero
%movieName = 'stabtest_rect_zeroSide_10km_refine';
%generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind);
%Id = 121;   % 10km circle
%movieName = 'stabtest_circle_10km_refine';
%generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind);
%Id = 131;   % 10km circle, side zero
%movieName = 'stabtest_circle_zeroSide_10km_refine';
%generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind);

%nRows = 4;
%nCols = 2;
%subind = [1:2:7, 2:2:8];
%Id = 141;   % stab=6, circle
%movieName = 'stabtest_circle_stab6';
%generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind);
%Id = 151;   % stab=6, rectangle
%movieName = 'stabtest_rectangle_stab6';
%generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind);


%nRows = 4;
%nCols = 3;
%subind = [1:12];
%framesteps = 10;
%Id = 202;   % circle parabola
%movieName = 'stabtest_circle_parabola';
%generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind, 'frame step', framesteps);
%Id = 203;   % circle gaussian
%movieName = 'stabtest_circle_gaussian';
%generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind, 'frame step', framesteps);
%Id = 204;   % circle triangle
%movieName = 'stabtest_circle_triangle';
%generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind, 'frame step', framesteps);
%Id = 212;   % rectangle parabola
%movieName = 'stabtest_rectangle_parabola';
%generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind, 'frame step', framesteps);
%Id = 213;   % rectangle gaussian
%movieName = 'stabtest_rectangle_gaussian';
%generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind, 'frame step', framesteps);
%Id = 214;   % rectangle triangle
%movieName = 'stabtest_rectangle_triangle';
%generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind, 'frame step', framesteps);
