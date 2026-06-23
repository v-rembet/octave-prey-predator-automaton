% Innit variablen

clear all;
close all;

data.world = zeros(50, 100);  % 0=empty, 1=prey, 2=predator
data.generation = 0;
data.edit_dlg = true;


% Window en buttons

screensize = get(0.0, 'screensize')(3:4);
data.fig = figure(
  'name', "Prey-Predator Automata",
  'numbertitle', 'off',
  'menubar', 'none',
  'resize', 'off',
  'color', [0.1 0.1 0.5],
  'position', [1+(screensize(1)-1600)/2 1+(screensize(2)-900)/2 1600 900]
);
data.axs = axes(
  'units', 'pixels',
  'position', [1 101 1600 800],
  'colormap', [0.15 0.15 0.15; 0.2 0.4 0.9; 0.9 0.2 0.2]  % empty=dark, prey=blue, predator=red
);
data.reset_btn = uicontrol(
  'style', 'pushbutton',
  'units', 'pixels',
  'position', [21 21 200 60],
  'backgroundcolor', [0.8 0.6 0.5],
  'foregroundcolor', [1.0 1.0 1.0],
  'string', '♻   reset',
  'fontsize', 24,
  'tooltipstring', 'Reset the world with random prey and predators',
  'callback', @click_reset
);
data.step_btn = uicontrol(
  'style', 'pushbutton',
  'units', 'pixels',
  'position', [241 21 200 60],
  'backgroundcolor', [0.5 0.9 0.5],
  'foregroundcolor', [1.0 1.0 1.0],
  'string', '▶  ️ step',
  'fontsize', 24,
  'tooltipstring', 'Calculate the next generation',
  'callback', @click_step
);
data.edit_btn = uicontrol(
  'style', 'pushbutton',
  'units', 'pixels',
  'position', [461 21 200 60],
  'backgroundcolor', [0.5 0.5 0.5],
  'foregroundcolor', [1.0 1.0 1.0],
  'string', '✎   edit',
  'fontsize', 24,
  'tooltipstring', 'Toggle cells in the world grid',
  'callback', @click_edit
);

data.prey_title_lbl = uicontrol(
  'style', 'text',
  'units', 'pixels',
  'position', [691 46 100 28],
  'backgroundcolor', [0.1 0.1 0.5],
  'foregroundcolor', [0.5 0.7 1.0],
  'string', '🐇 Prey',
  'fontsize', 14,
  'fontweight', 'bold',
  'horizontalalignment', 'right'
);
data.prey_lbl = uicontrol(
  'style', 'text',
  'units', 'pixels',
  'position', [799 46 110 28],
  'backgroundcolor', [0.1 0.1 0.5],
  'foregroundcolor', [0.6 0.8 1.0],
  'string', '0',
  'fontsize', 14,
  'horizontalalignment', 'left'
);

data.pred_title_lbl = uicontrol(
  'style', 'text',
  'units', 'pixels',
  'position', [691 14 100 28],
  'backgroundcolor', [0.1 0.1 0.5],
  'foregroundcolor', [1.0 0.5 0.5],
  'string', '🐺 Pred',
  'fontsize', 14,
  'fontweight', 'bold',
  'horizontalalignment', 'right'
);
data.pred_lbl = uicontrol(
  'style', 'text',
  'units', 'pixels',
  'position', [799 14 110 28],
  'backgroundcolor', [0.1 0.1 0.5],
  'foregroundcolor', [1.0 0.6 0.6],
  'string', '0',
  'fontsize', 14,
  'horizontalalignment', 'left'
);

data.save_btn = uicontrol(
  'style', 'pushbutton',
  'units', 'pixels',
  'position', [1161 21 200 60],
  'backgroundcolor', [0.8 0.8 0.6],
  'foregroundcolor', [1.0 1.0 1.0],
  'string', '📥   save',
  'fontsize', 24,
  'tooltipstring', 'Save the world to a file',
  'callback', @click_save
);
data.load_btn = uicontrol(
  'style', 'pushbutton',
  'units', 'pixels',
  'position', [1381 21 200 60],
  'backgroundcolor', [0.8 0.8 0.6],
  'foregroundcolor', [1.0 1.0 1.0],
  'string', '📤   load',
  'fontsize', 24,
  'tooltipstring', 'Load the world from a file',
  'callback', @click_load
);
data.img = imagesc(data.axs, data.world, [0.0 2.0]);
axis(data.axs, 'off');

% gui data
guidata(data.fig, data);


% callback functions

function update_meters(source, data)
  n_prey = sum(data.world(:) == 1);
  n_pred = sum(data.world(:) == 2);
  set(data.prey_lbl, 'string', int2str(n_prey));
  set(data.pred_lbl, 'string', int2str(n_pred));
endfunction

function click_reset(source, event)
  if questdlg('Reset the world with random prey and predators?', 'Confirm', 'Yes', 'No', 'No')
    data = guidata(source);
    r = rand(size(data.world));
    data.world = zeros(size(data.world));
    data.world(r < 0.25) = 1;           % prey
    data.world(r >= 0.25 & r < 0.35) = 2;  % predator
    set(data.img, 'cdata', data.world);
    update_meters(source, data);
    guidata(source, data);
  endif
endfunction

function click_step(source, event) %op het moment een placeholder want ik weet nog niet hoe de regels gaan doen
  data = guidata(source);
  set(data.img, 'cdata', data.world);
  update_meters(source, data);
  guidata(source, data);
endfunction

function click_edit(source, event) %1x klikken = prey 2 keer = pred
  data = guidata(source);
  if data.edit_dlg
    helpdlg("Left click: cycle cell (empty -> prey -> predator -> empty).\nRight click to stop.", 'Entering editing mode');
    data.edit_dlg = false;
  endif
  oldcolor = get(data.edit_btn, 'backgroundcolor');
  set(data.edit_btn, 'backgroundcolor', [1.0 0.4 0.4]);
  valid = true;
  while valid
    [x, y, button] = ginput(1);
    x = round(x);
    y = round(y);
    if button == 1 && x > 0 && y > 0 && x <= columns(data.world) && y <= rows(data.world)
      data.world(y, x) = mod(data.world(y, x) + 1, 3);  % 0->1->2->0
    else
      valid = false;
    endif
    set(data.img, 'cdata', data.world);
    update_meters(source, data);
    guidata(source, data);
  endwhile
  set(data.edit_btn, 'backgroundcolor', oldcolor);
endfunction

function click_save(source, event)
  data = guidata(source);
  [filename, filepath] = uiputfile(
    {"*.csv;*.txt", "Text file"; "*.gif;*.bmp;*.png", "Image file"},
    'Specify the filename to save'
  );
  if length(filename) > 4 & ischar(filename)
    if endsWith(filename, '.csv') || endsWith(filename, '.txt')
      csvwrite(strcat(filepath, filename), data.world);
    elseif endsWith(filename, '.gif') || endsWith(filename, '.bmp') || endsWith(filename, '.png')
      colormap = get(data.axs, 'colormap');
      imwrite(uint8(data.world), colormap, strcat(filepath, filename));
    endif
  endif
endfunction

function click_load(source, event)
  [filename, filepath] = uigetfile(
    {"*.csv;*.txt", "Text file"; "*.gif;*.bmp;*.png", "Image file"},
    'Specify the filename to load'
  );
  if length(filename) > 4 & ischar(filename)
    data = guidata(source);
    if endsWith(filename, '.csv') || endsWith(filename, '.txt')
      data.world = csvread(strcat(filepath, filename));
    elseif endsWith(filename, '.gif') || endsWith(filename, '.bmp') || endsWith(filename, '.png')
      data.world = double(imread(strcat(filepath, filename)));
    endif
    set(data.img, 'cdata', data.world);
    update_meters(source, data);
    guidata(source, data);
  endif
endfunction
