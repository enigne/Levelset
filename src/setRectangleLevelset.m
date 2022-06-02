% Set levelset function with a straight calving front

function ice_levelset = setRectangleLevelset(x, y, cx, cy, radius)
	% change x and y to column vectors
	x= x(:);
	y= y(:);
	% make cx and cy to row vectors
	cx = cx(:)';
	cy = cy(:)';

	numberofvertices = length(x);
	numberoftime = length(cx);

	% set levelset
	ice_levelset = -ones(numberofvertices, numberoftime);
	fjord = ((x>cx) & (y > cy-radius) & (y < cy+radius));
	ice_levelset(fjord) = 1;
