% Set levelset function according to the given center and radius 

function ice_levelset = setLevelset(x, y, cx, cy, radius)
	% change x and y to column vectors
	x= x(:);
	y= y(:);
	% make cx and cy to row vectors
	cx = cx(:)';
	cx = cy(:)';

	numberofvertices = length(x);
	numberoftime = length(cx);
	ice_levelset = -ones(numberofvertices, numberoftime);
	fjord = ((x-cx).^2+(y-cy).^2 < radius^2);
	fjord = fjord | ((x>cx) & (y > cy-radius) & (y < cy+radius));
	ice_levelset(fjord) = 1;
