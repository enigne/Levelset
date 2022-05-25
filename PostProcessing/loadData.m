function dataList = loadData(folderList, datatype, parentFolder)
%loadData - to load the data file from the list of folders into a list of struct
%
% Author: Cheng Gong
% Last modified: 2022-05-25
if nargin < 3
	parentFolder = '../Models/';
	if nargin < 2
		datatype = 'levelset'; % by default load transient solutions
	end
end

if strcmp(datatype, 'levelset')
	filename = 'levelsetSolutions.mat';
else
	warning('Unknown data type, load transientSolutions.mat by default');
	filename = 'levelsetSolutions.mat';
end

Nf = length(folderList);
dataList = cell(Nf, 1);

parfor i = 1: Nf
	dataList{i} = load([parentFolder, folderList{i}, filename]);
end
