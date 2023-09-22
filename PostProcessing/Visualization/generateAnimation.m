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
	time = outSol{1}.time;
	Nt = length(time);
	icemask = cellfun(@(x)sign(x.ice_levelset), {outSol{:}}, 'UniformOutput', 0);
	anamask = cellfun(@(x)sign(x.analytical_levelset), {outSol{:}}, 'UniformOutput', 0);
	NtoRepeat = cellfun(@(x)(ceil(Nt/x.repeatNt)), {outSol{:}}, 'UniformOutput', 0);
	%}}}
	%% Create Movie for friction and ice rheology {{{
	set(0,'defaultfigurecolor',[1, 1, 1])
	Ndata = length(outSol);
	nframes = floor(Nt/nstep);
	xl = [0, 1]*2e4;
	yl = [0, 1]*2e4;

	clear mov;
	close all;
	figure('position',[0,500,1000,1500])
	mov(1:nframes) = struct('cdata', [],'colormap', []);
	count = 1;
	for i = 1:nstep:Nt
		annotation('textbox',[.4 .91 .2 .05], 'String', ['year: ', num2str(time(i))],'EdgeColor','none', 'FontSize', 15)
		annotation('textbox',[.1 .89 .1 .05], 'String', 'AD','EdgeColor','none', 'FontSize', 12)
		annotation('textbox',[.33 .89 .1 .05], 'String', 'SU','EdgeColor','none', 'FontSize', 12)
		annotation('textbox',[.56 .89 .1 .05], 'String', 'SUPG','EdgeColor','none', 'FontSize', 12)
		annotation('textbox',[.8 .89 .1 .05], 'String', 'SUPG+FAB','EdgeColor','none', 'FontSize', 12)
		annotation('textarrow',[.03 .01], [ .86 .05], 'String', 'n_R=1','HeadStyle', 'none', 'LineStyle', 'none', 'FontSize', 12,'TextRotation',90)
		annotation('textarrow',[.03 .01], [ .67 .05], 'String', 'n_R=10','HeadStyle', 'none', 'LineStyle', 'none', 'FontSize', 12,'TextRotation',90)
		annotation('textarrow',[.03 .01], [ .48 .05], 'String', 'n_R=100','HeadStyle', 'none', 'LineStyle', 'none', 'FontSize', 12,'TextRotation',90)
		annotation('textarrow',[.03 .01], [ .29 .05], 'String', 'n_R=200','HeadStyle', 'none', 'LineStyle', 'none', 'FontSize', 12,'TextRotation',90)
		annotation('textarrow',[.03 .01], [ .1 .05], 'String', 'n_R=\infty','HeadStyle', 'none', 'LineStyle', 'none', 'FontSize', 12,'TextRotation',90)

		for j = 1:Ndata	
			if (i <= size(icemask{j}, 2))
				plotmodel(md,'data', icemask{j}(:,i)-anamask{j}(:,mod(i-1, NtoRepeat{j})+1),...
					'ylim', yl, 'xlim', xl,...
					'caxis', [-2, 2], 'colorbar', 'off',...
					'xtick', [], 'ytick', [], ...
					'tightsubplot#all', 1,...
					'hmargin#all', [0.03,0.0], 'vmargin#all',[0,0.06], 'gap#all',[.0 .0],...
					'subplot', [nRows,nCols,subind(j)]);
				title(titleList{j}, 'interpreter','latex')
				set(gca,'fontsize',12);
				set(colorbar,'visible','off')
			end
		end

		colormap('jet')
		img = getframe(1);
		img = img.cdata;
		mov(count) = im2frame(img);
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
