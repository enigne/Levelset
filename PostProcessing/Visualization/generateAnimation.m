% Generate animations 
function generateAnimation(varargin)

	%Check inputs {{{
	%recover options
	options=pairoptions(varargin{:});
	% }}}
	%GET glacier: 'Levelset'{{{
	glacier = getfieldvalue(options,'glacier', 'Levelset');
	% }}}
	%GET home dirctory: '/totten_1/chenggong/'{{{
	homeDir = getfieldvalue(options,'home directory', '/totten_1/chenggong/');
	projPath = [homeDir, glacier, '/'];
	addpath([projPath, '/PostProcessing/']);
	% }}}
	%GET Id : 0{{{
	Id = getfieldvalue(options,'Id', 0);
	% }}}
	%GET movie name : ''{{{
	movieSuffix = getfieldvalue(options,'movie name', '');
	movieName = [projPath, 'PostProcessing/Figures/Animations/', glacier, '_', movieSuffix];
	% }}}
	%GET nRows : 1{{{
	nRows = getfieldvalue(options,'nRows', 1);
	% }}}
	%GET nCols : 1{{{
	nCols = getfieldvalue(options,'nCols', 1);
	% }}}
	%GET index : [1]{{{
	subind = getfieldvalue(options,'index', [1]);
	% }}}
	%GET frame step : 2 {{{
	nstep = getfieldvalue(options,'frame step', 2);
	% }}}


	%% Load data {{{
	[folderList, titleList] = getFolderList(Id, 0);
	% Load simulations from levelsetSolutions.mat
	outSol = loadData(folderList, 'levelset', [projPath, 'Models/']);
	% load model
	md = loadRefMd([projPath, 'Models/'], 'Param');
	%}}}
	%% Get all the levelsets {{{
	icemask = cellfun(@(x)sign(x.ice_levelset), {outSol{:}}, 'UniformOutput', 0);
	anamask = cellfun(@(x)x.analytical_levelset, {outSol{:}}, 'UniformOutput', 0);
	time = outSol{1}.time;
	%}}}
	%% Create Movie for friction and ice rheology {{{
	set(0,'defaultfigurecolor',[1, 1, 1])
	Nt = length(time);
	Ndata = length(outSol);
	nframes = floor(Nt/nstep);
	xl = [0.2, 1]*2e4;
	yl = [0.1,0.9]*2e4;

	clear mov;
	close all;
	figure('position',[0,500,1000,1500])
	mov(1:nframes) = struct('cdata', [],'colormap', []);
	count = 1;
	for i = 1:nstep:Nt
		for j = 1:Ndata	
			if (i <= size(icemask{j}, 2))
				plotmodel(md,'data', icemask{j}(:,i)-anamask{j}(:,i),...
					'ylim', yl, 'xlim', xl,...
					'caxis', [-2, 2], 'colorbar', 'off',...
					'xtick', [], 'ytick', [], ...
					'tightsubplot#all', 1,...
					'hmargin#all', [0.01,0.0], 'vmargin#all',[0,0.06], 'gap#all',[.0 .0],...
					'subplot', [nRows,nCols,subind(j)]);
				title(titleList{j}, 'interpreter','latex')
				set(gca,'fontsize',12);
				set(colorbar,'visible','off')
			end
		end
		h = colorbar('Position', [0.1 0.9  0.75  0.01], 'Location', 'northoutside');
		%title(h, datestr( decyear2date(time(i)), 'yyyy-mm-dd'))
		title(h, ['year: ', num2str(time(i))])
		colormap('jet')
		img = getframe(1);
		img = img.cdata;
		mov(count) = im2frame(img);
		set(h, 'visible','off');
		clear h;
		fprintf(['step ', num2str(count),' done\n']);
		count = count+1;
		clf;
	end
	% create video writer object
	writerObj = VideoWriter([movieName, '.avi']);
	% set the frame rate to one frame per second
	set(writerObj,'FrameRate', 20);
	% open the writer
	open(writerObj);

	for i=1:nframes
		img = frame2im(mov(i));
		[imind,cm] = rgb2ind(img,256,'dither');
		% convert the image to a frame using im2frame
		frame = im2frame(img);
		% write the frame to the video
		writeVideo(writerObj,frame);
	end
	close(writerObj);
	command=sprintf('ffmpeg -y -i %s.avi -c:v libx264 -crf 19 -preset slow -c:a libfaac -b:a 192k -ac 2 -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" %s.mp4',movieName,movieName);
	system(command);
	%}}}

