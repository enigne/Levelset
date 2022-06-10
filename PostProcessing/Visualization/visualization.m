clear
close all


nRows = 5;
nCols = 3;
subind = [1:15];

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

nRows = 4;
nCols = 2;
subind = [1:2:7, 2:2:8];
Id = 141;   % stab=6, circle
movieName = 'stabtest_circle_stab6';
generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind);
Id = 151;   % stab=6, rectangle
movieName = 'stabtest_rectangle_stab6';
generateAnimation('Id', Id, 'movie name', movieName, 'nRows', nRows, 'nCols', nCols, 'index', subind);
