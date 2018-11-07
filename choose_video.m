function [video_name, basePath, dataset] = choose_video(datasets)
%CHOOSE_VIDEO
%   Li,Yang, 2015
    sets = {};
    for i=1:numel(datasets)
        sets{i} = datasets{i}.name;
    end

    setChoice = listdlg('ListString',sets, 'Name','Choose data sets', 'SelectionMode','single');
    if isempty(setChoice),  %user cancelled
		basePath = [];
        dataset =[];
        video_name =[];
        return
	end
    basePath= datasets{setChoice}.basePath;
    dataset = datasets{setChoice}.name;
    
	%process path to make sure it's uniform
	if ispc(), basePath = strrep(basePath, '\', '/'); end
	if basePath(end) ~= '/', basePath(end+1) = '/'; end
	
	%list all sub-folders
	contents = dir(basePath);
	names = {};
	for k = 1:numel(contents),
		name = contents(k).name;
		if isdir([basePath name]) && ~any(strcmp(name, {'.', '..'})),
			names{end+1} = name;  %#ok
		end
	end
	
	%no sub-folders found
	if isempty(names), video_name = []; return; end
	
	%choice GUI
	choice = listdlg('ListString',names, 'Name','Choose video', 'SelectionMode','single');
	
	if isempty(choice),  %user cancelled
		video_name = [];
	else
		video_name = names{choice};
	end
	
end

