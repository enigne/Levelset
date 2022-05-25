function md = loadRefMd(folder, stepName)
%loadRefMd - to load a reference model from parameterization step of the
%               experiment. 
%               Return a model struct.
%
% Author: Cheng Gong
% Last modified: 2022-05-25
if nargin < 2
    stepName = 'Param';
    if nargin < 1
        folder = '/totten_1/chenggong/Levelset/Models/';
    end
end

steps = 0;
glacier = 'Levelset';

org=organizer('repository', folder, 'prefix', ['Model_' glacier '_'], 'steps', steps);
md = loadmodel(org, stepName);
