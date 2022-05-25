% Set levelset function according to the given center and radius 

function ice_levelset = setLevelset(x, y, cx, cy, radius)
	numberofvertices = length(x);
	ice_levelset = -ones(numberofvertices, 1);
	fjord = ((x-cx).^2+(y-cy).^2 < radius^2);
	fjord = fjord | ((x>cx) & (y > cy-radius) & (y < cy+radius));
	ice_levelset(fjord) = 1;
