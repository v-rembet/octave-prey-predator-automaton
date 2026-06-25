
function Prey_Predator_Automaton()

  DEF.GRASS_GROW    = 0.05;
  DEF.GRASS_DENSITY = 0.28;
  DEF.PREY_DENSITY  = 0.12;
  DEF.PRED_DENSITY  = 0.05;
  DEF.PREY_REPRO    = 0.22;
  DEF.PREY_STARVE   = 0.08;
  DEF.PRED_KILL     = 0.35;
  DEF.PRED_REPRO    = 0.18;
  DEF.PRED_STARVE   = 0.05;
  DEF.GRID_ROWS     = 100;
  DEF.GRID_COLS     = 200;

  WIN_W = 1100;
  WIN_H = 660;
  TB_H  = 80;
  CFG_W = 380;
  AX_H  = WIN_H - TB_H;

  data.world      = zeros(DEF.GRID_ROWS, DEF.GRID_COLS);
  data.generation = 0;
  data.edit_dlg   = true;
  data.cfg_open   = false;
  data.p          = DEF;

  ss    = get(0, 'screensize');
  fig_x = max(1, round((ss(3) - WIN_W) / 2));
  fig_y = max(1, round((ss(4) - WIN_H) / 2));

  data.fig = figure( ...
    'name',        'Prey-Predator Automata', ...
    'numbertitle', 'off', ...
    'menubar',     'none', ...
    'resize',      'off', ...
    'color',       [0.08 0.08 0.18], ...
    'position',    [fig_x fig_y WIN_W WIN_H]);

  data.axs = axes( ...
    'parent',   data.fig, ...
    'units',    'pixels', ...
    'position', [1 TB_H+1 WIN_W AX_H]);
  colormap(data.axs, [0.10 0.10 0.10;
                      0.20 0.65 0.20;
                      0.20 0.40 0.90;
                      0.90 0.20 0.20]);

  data.img = imagesc('parent', data.axs, data.world, [0 3]);
  axis(data.axs, 'off');

  BH = 52; BY = 14;

  data.reset_btn = uicontrol('parent', data.fig, ...
    'style','pushbutton','units','pixels','position',[10 BY 130 BH], ...
    'backgroundcolor',[0.75 0.45 0.35],'foregroundcolor',[1 1 1], ...
    'string','Reset','fontsize',14,'callback',@click_reset);

  data.play_btn = uicontrol('parent', data.fig, ...
    'style','togglebutton','units','pixels','position',[150 BY 130 BH], ...
    'backgroundcolor',[0.30 0.70 0.30],'foregroundcolor',[1 1 1], ...
    'string','Play','fontsize',14,'callback',@click_play);

  data.edit_btn = uicontrol('parent', data.fig, ...
    'style','pushbutton','units','pixels','position',[290 BY 130 BH], ...
    'backgroundcolor',[0.45 0.45 0.45],'foregroundcolor',[1 1 1], ...
    'string','Edit','fontsize',14,'callback',@click_edit);

  uicontrol('parent', data.fig, ...
    'style','text','units','pixels','position',[432 BY+34 130 16], ...
    'backgroundcolor',[0.08 0.08 0.18],'foregroundcolor',[0.75 0.75 0.75], ...
    'string','Speed','fontsize',10,'horizontalalignment','center');
  data.speed_sld = uicontrol('parent', data.fig, ...
    'style','slider','units','pixels','position',[432 BY 130 30], ...
    'min',0,'max',1,'value',0.3,'sliderstep',[0.05 0.2]);

  cx = 580; lw = 70; vw = 80;
  uicontrol('parent',data.fig,'style','text','units','pixels', ...
    'position',[cx 46 lw 20],'backgroundcolor',[0.08 0.08 0.18], ...
    'foregroundcolor',[0.30 0.80 0.30],'string','Grass', ...
    'fontsize',10,'fontweight','bold','horizontalalignment','right');
  data.grass_lbl = uicontrol('parent',data.fig,'style','text','units','pixels', ...
    'position',[cx+lw+4 46 vw 20],'backgroundcolor',[0.08 0.08 0.18], ...
    'foregroundcolor',[0.50 0.90 0.50],'string','0','fontsize',10);

  uicontrol('parent',data.fig,'style','text','units','pixels', ...
    'position',[cx 28 lw 20],'backgroundcolor',[0.08 0.08 0.18], ...
    'foregroundcolor',[0.50 0.70 1.00],'string','Prey', ...
    'fontsize',10,'fontweight','bold','horizontalalignment','right');
  data.prey_lbl = uicontrol('parent',data.fig,'style','text','units','pixels', ...
    'position',[cx+lw+4 28 vw 20],'backgroundcolor',[0.08 0.08 0.18], ...
    'foregroundcolor',[0.65 0.80 1.00],'string','0','fontsize',10);

  uicontrol('parent',data.fig,'style','text','units','pixels', ...
    'position',[cx 10 lw 20],'backgroundcolor',[0.08 0.08 0.18], ...
    'foregroundcolor',[1.00 0.45 0.45],'string','Pred', ...
    'fontsize',10,'fontweight','bold','horizontalalignment','right');
  data.pred_lbl = uicontrol('parent',data.fig,'style','text','units','pixels', ...
    'position',[cx+lw+4 10 vw 20],'backgroundcolor',[0.08 0.08 0.18], ...
    'foregroundcolor',[1.00 0.65 0.65],'string','0','fontsize',10);

  data.save_btn = uicontrol('parent', data.fig, ...
    'style','pushbutton','units','pixels','position',[790 BY 100 BH], ...
    'backgroundcolor',[0.50 0.50 0.80],'foregroundcolor',[1 1 1], ...
    'string','Save','fontsize',13,'callback',@click_save);
  data.load_btn = uicontrol('parent', data.fig, ...
    'style','pushbutton','units','pixels','position',[900 BY 100 BH], ...
    'backgroundcolor',[0.50 0.50 0.80],'foregroundcolor',[1 1 1], ...
    'string','Load','fontsize',13,'callback',@click_load);
  data.help_btn = uicontrol('parent', data.fig, ...
    'style','pushbutton','units','pixels','position',[1010 BY 40 BH], ...
    'backgroundcolor',[0.65 0.65 0.25],'foregroundcolor',[1 1 1], ...
    'string','?','fontsize',16,'callback',@click_help);
  data.cfg_btn = uicontrol('parent', data.fig, ...
    'style','togglebutton','units','pixels','position',[1058 BY 36 BH], ...
    'backgroundcolor',[0.35 0.55 0.45],'foregroundcolor',[1 1 1], ...
    'string','Cfg','fontsize',11,'callback',@click_cfg);
%config panel code
  BG  = [0.10 0.12 0.22];
  FG  = [0.85 0.85 0.95];
  SBG = [0.18 0.20 0.35];

  data.cfg_panel = uipanel('parent', data.fig, ...
    'units','pixels', ...
    'position',[WIN_W-CFG_W TB_H+1 CFG_W AX_H], ...
    'backgroundcolor', BG, ...
    'foregroundcolor', FG, ...
    'title','  Configuration', ...
    'fontsize', 12, 'fontweight','bold', ...
    'visible','off');

  function section_header(panel, y, txt)
    uicontrol('parent',panel,'style','text','units','pixels', ...
      'position',[0 y CFG_W 2],'backgroundcolor',[0.30 0.35 0.55]);
    uicontrol('parent',panel,'style','text','units','pixels', ...
      'position',[10 y+3 360 16], ...
      'backgroundcolor',[0.10 0.12 0.22],'foregroundcolor',[0.60 0.65 0.90], ...
      'string',txt,'fontsize',9,'fontweight','bold','horizontalalignment','left');
  end

  function sld = make_row(panel, y, lbl, col, lo, hi, val, field, fmt)
    uicontrol('parent',panel,'style','text','units','pixels', ...
      'position',[10 y+22 360 18], ...
      'backgroundcolor',BG,'foregroundcolor',col, ...
      'string',lbl,'fontsize',10,'fontweight','bold','horizontalalignment','left');
    sld = uicontrol('parent',panel,'style','slider','units','pixels', ...
      'position',[10 y 285 22], ...
      'backgroundcolor',SBG,'min',lo,'max',hi,'value',val, ...
      'sliderstep',[0.01 0.05], ...
      'callback',{@cfg_changed, field, fmt});
    uicontrol('parent',panel,'style','text','units','pixels', ...
      'position',[302 y 64 22], ...
      'backgroundcolor',BG,'foregroundcolor',FG, ...
      'string',sprintf(fmt,val),'fontsize',10, ...
      'tag',['val_' field],'horizontalalignment','center');
  end

  section_header(data.cfg_panel, 540, '  WORLD SIZE (applies on next reset)');
  data.cfg_rows_sld = make_row(data.cfg_panel, 492, 'Grid rows (height)',  [0.70 0.85 0.70], 20,  200, DEF.GRID_ROWS,     'GRID_ROWS',     '%g');
  data.cfg_cols_sld = make_row(data.cfg_panel, 446, 'Grid columns (width)',[0.70 0.85 0.70], 40,  400, DEF.GRID_COLS,     'GRID_COLS',     '%g');

  section_header(data.cfg_panel, 418, '  INITIAL DENSITY (applies on next reset)');
  data.cfg_gd_sld    = make_row(data.cfg_panel, 372, 'Grass density',   [0.40 0.85 0.40], 0, 0.80, DEF.GRASS_DENSITY, 'GRASS_DENSITY', '%.2f');
  data.cfg_preyd_sld = make_row(data.cfg_panel, 326, 'Prey density',    [0.50 0.70 1.00], 0, 0.60, DEF.PREY_DENSITY,  'PREY_DENSITY',  '%.2f');
  data.cfg_predd_sld = make_row(data.cfg_panel, 280, 'Predator density',[1.00 0.50 0.50], 0, 0.30, DEF.PRED_DENSITY,  'PRED_DENSITY',  '%.2f');

  section_header(data.cfg_panel, 252, '  GRASS');
  data.cfg_gg_sld = make_row(data.cfg_panel, 206, 'Growth chance per step',[0.40 0.85 0.40], 0, 0.30, DEF.GRASS_GROW, 'GRASS_GROW', '%.2f');

  section_header(data.cfg_panel, 178, '  PREY');
  data.cfg_pr_sld = make_row(data.cfg_panel, 132, 'Reproduction chance (after eating)', [0.50 0.70 1.00], 0, 1,    DEF.PREY_REPRO,  'PREY_REPRO',  '%.2f');
  data.cfg_ps_sld = make_row(data.cfg_panel, 86,  'Starvation chance (no grass nearby)',[0.50 0.70 1.00], 0, 0.50, DEF.PREY_STARVE, 'PREY_STARVE', '%.2f');

  section_header(data.cfg_panel, 58, '  PREDATOR');
  data.cfg_pk_sld  = make_row(data.cfg_panel, 12, 'Kill chance (adjacent prey)',       [1.00 0.50 0.50], 0, 1,    DEF.PRED_KILL,   'PRED_KILL',   '%.2f');

%GUI Data
  guidata(data.fig, data);
  do_reset(data.fig);

  % --- Call backs -----------------
  function click_reset(src, ~)
    do_reset(src);
  end

  function do_reset(src)
    d  = guidata(data.fig);
    p  = d.p;
    nr = round(p.GRID_ROWS);
    nc = round(p.GRID_COLS);
    r  = rand(nr, nc);
    w  = zeros(nr, nc);
    w(r < p.GRASS_DENSITY) = 1;
    w(r >= p.GRASS_DENSITY & r < p.GRASS_DENSITY + p.PREY_DENSITY) = 2;
    top = p.GRASS_DENSITY + p.PREY_DENSITY;
    w(r >= top & r < top + p.PRED_DENSITY) = 3;
    d.world      = w;
    d.generation = 0;
    set(d.img, 'cdata', d.world);
    update_meters(d);
    guidata(data.fig, d);
  end

  function click_play(src, ~)
    d = guidata(data.fig);
    if get(src, 'value') == 1
      set(src, 'string','Stop','backgroundcolor',[0.80 0.30 0.30]);
      while ishandle(src) && get(src,'value') == 1
        d           = guidata(data.fig);
        d.world     = step_world(d.world, d.p);
        d.generation = d.generation + 1;
        set(d.img, 'cdata', d.world);
        update_meters(d);
        guidata(data.fig, d);
        spd = get(d.speed_sld, 'value');
        delay = 0.5 * (1 - spd);
        if delay > 0; pause(delay); end
        drawnow();
      end
      if ishandle(src)
        set(src, 'string','Play','backgroundcolor',[0.30 0.70 0.30],'value',0);
      end
    end
  end

  function click_edit(src, ~)
    d = guidata(data.fig);
    set(d.play_btn, 'value', 0);
    if d.edit_dlg
      msgbox('Left-click: cycle cell state.  Right-click or any other button: exit edit mode.', 'Edit Mode');
      d.edit_dlg = false;
      guidata(data.fig, d);
    end
    oldcol = get(d.edit_btn, 'backgroundcolor');
    set(d.edit_btn, 'backgroundcolor', [1.0 0.4 0.4]);
    going = true;
    while going
      [x, y, btn] = ginput(1);
      if isempty(btn)
        going = false;
      elseif btn == 1
        x = round(x); y = round(y);
        d = guidata(data.fig);
        if x >= 1 && y >= 1 && x <= size(d.world,2) && y <= size(d.world,1)
          d.world(y,x) = mod(d.world(y,x) + 1, 4);
          set(d.img, 'cdata', d.world);
          update_meters(d);
          guidata(data.fig, d);
        end
      else
        going = false;
      end
    end
    set(d.edit_btn, 'backgroundcolor', oldcol);
  end

  function click_cfg(src, ~)
    d = guidata(data.fig);
    if get(src, 'value') == 1
      set(d.cfg_panel, 'visible', 'on');
      set(d.axs, 'position', [1 TB_H+1 WIN_W-CFG_W AX_H]);
      set(src, 'backgroundcolor', [0.55 0.75 0.60]);
      d.cfg_open = true;
    else
      set(d.cfg_panel, 'visible', 'off');
      set(d.axs, 'position', [1 TB_H+1 WIN_W AX_H]);
      set(src, 'backgroundcolor', [0.35 0.55 0.45]);
      d.cfg_open = false;
    end
    guidata(data.fig, d);
  end

  function cfg_changed(src, ~, field, fmt)
    d   = guidata(data.fig);
    val = get(src, 'value');
    if strcmp(field,'GRID_ROWS') || strcmp(field,'GRID_COLS')
      val = round(val);
      set(src, 'value', val);
    end
    d.p.(field) = val;
    lbl = findobj(d.cfg_panel, 'tag', ['val_' field]);
    if ~isempty(lbl)
      set(lbl, 'string', sprintf(fmt, val));
    end
    guidata(data.fig, d);
  end

  function click_save(src, ~)
    d = guidata(data.fig);
    [fname, fpath] = uiputfile({'*.csv','CSV file';'*.png','PNG image'}, 'Save world as');
    if ischar(fname) && length(fname) > 4
      fp = fullfile(fpath, fname);
      if strcmpi(fname(end-3:end), '.csv')
        csvwrite(fp, d.world);
      elseif strcmpi(fname(end-3:end), '.png')
        cmap = colormap(d.axs);
        imwrite(uint8(d.world), cmap, fp);
      end
    end
  end

  function click_load(src, ~)
    [fname, fpath] = uigetfile({'*.csv','CSV file';'*.png','PNG image'}, 'Load world from');
    if ischar(fname) && length(fname) > 4
      d  = guidata(data.fig);
      fp = fullfile(fpath, fname);
      if strcmpi(fname(end-3:end), '.csv')
        d.world = csvread(fp);
      elseif strcmpi(fname(end-3:end), '.png')
        d.world = double(rgb2gray(imread(fp)));
      end
      set(d.img, 'cdata', d.world);
      update_meters(d);
      guidata(data.fig, d);
    end
  end

  function click_help(src, ~)
    web('http://langers.nl/wiki/doku.php?id=predator_prey_2026:welkom');
  end

end % end main function


%belangrijke helper functions grotendeels voor beweging, eten en reproductie

function update_meters(d)
  set(d.grass_lbl, 'string', int2str(sum(d.world(:) == 1)));
  set(d.prey_lbl,  'string', int2str(sum(d.world(:) == 2)));
  set(d.pred_lbl,  'string', int2str(sum(d.world(:) == 3)));
end

function n = count_neighbours(M)
  n = zeros(size(M));
  for dr = -1:1
    for dc = -1:1
      if dr ~= 0 || dc ~= 0
        n = n + circshift(double(M), [dr dc]);
      end
    end
  end
end

function world = step_world(world, p)
  dirs = {[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]};

  grass = (world == 1);
  prey  = (world == 2);
  pred  = (world == 3);
  empty = (world == 0);

  n_grass = count_neighbours(grass);
  n_prey  = count_neighbours(prey);

  new_world = world;

  % Grass growth
  new_world(empty & (rand(size(world)) < p.GRASS_GROW)) = 1;

  % Starvation
  new_world(prey & (n_grass == 0) & (rand(size(world)) < p.PREY_STARVE)) = 0;
  new_world(pred & (n_prey  == 0) & (rand(size(world)) < p.PRED_STARVE)) = 0;

  % Prey movement + eating
  dorder = randperm(8);
  prey_available = (new_world == 2);
  prey_moved     = false(size(world));
  for di = 1:8
    d = dorder(di); dr = dirs{d}(1); dc = dirs{d}(2);
    nb     = circshift(new_world, [dr dc]);
    eaters = prey_available & ~prey_moved & (nb == 1);
    if any(eaters(:))
      target = circshift(eaters, [-dr -dc]);
      new_world(eaters) = 0;
      new_world(target) = 2;
      prey_moved = prey_moved | eaters;
      offspring  = eaters & (rand(size(world)) < p.PREY_REPRO);
      new_world(offspring) = 2;
    end
  end
  prey_available = (new_world == 2);
  wanderers = prey_available & ~prey_moved;
  for di = 1:8
    d = dorder(di); dr = dirs{d}(1); dc = dirs{d}(2);
    nb     = circshift(new_world, [dr dc]);
    movers = wanderers & (nb == 0);
    if any(movers(:))
      target = circshift(movers, [-dr -dc]);
      new_world(movers) = 0;
      new_world(target) = 2;
      wanderers = wanderers & ~movers;
    end
  end

  % Predator movement + hunting
  dorder2 = randperm(8);
  pred_available = (new_world == 3);
  pred_moved     = false(size(world));
  for di = 1:8
    d = dorder2(di); dr = dirs{d}(1); dc = dirs{d}(2);
    nb      = circshift(new_world, [dr dc]);
    hunters = pred_available & ~pred_moved & (nb == 2) & (rand(size(world)) < p.PRED_KILL);
    if any(hunters(:))
      target = circshift(hunters, [-dr -dc]);
      new_world(hunters) = 0;
      new_world(target)  = 3;
      pred_moved = pred_moved | hunters;
      offspring  = hunters & (rand(size(world)) < p.PRED_REPRO);
      new_world(offspring) = 3;
    end
  end
  pred_available = (new_world == 3);
  wanderers = pred_available & ~pred_moved;
  for di = 1:8
    d = dorder2(di); dr = dirs{d}(1); dc = dirs{d}(2);
    nb     = circshift(new_world, [dr dc]);
    movers = wanderers & (nb == 0);
    if any(movers(:))
      target = circshift(movers, [-dr -dc]);
      new_world(movers) = 0;
      new_world(target) = 3;
      wanderers = wanderers & ~movers;
    end
  end

  world = new_world;
end
