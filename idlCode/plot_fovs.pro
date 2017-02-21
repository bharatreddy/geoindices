pro plot_fovs


dateSel = 20170101
timeSel = 1200
coords = "magn"
xrangePlot= [-55,55]
yrangePlot= [-55,55]

radIds = [209, 208, 33, 207, 206, 205, 204, 32]

ps_open, '/home/bharatr/Docs/plots/fov-midlat.ps'

map_plot_panel,date=dateSel[0],time=timeSel[0],coords=coords,/no_fill,xrange=xrangePlot, $
        yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0),/isotropic,grid_charsize='0.5',/north, charsize = 0.5

overlay_fov, coords=coords, date=date, time=time, ids=radIds, fov_fillcolor = get_gray()

map_plot_panel,date=dateSel[0],time=timeSel[0],coords=coords,/no_fill,xrange=xrangePlot, $
        yrange=yrangePlot,pos=define_panel(1,1,0,0),/isotropic,grid_charsize='0.5',/north, charsize = 0.5

overlay_fov, coords=coords, date=date, time=time, ids=radIds, /no_fill

overlay_fov_name, coords=coords, date=date, time=time, ids=radIds, /annotate, charsize=0.5

; latitude rings at 50, 55 and 60 MLAT
FOR grid=30,40,5 DO BEGIN
	lon   = FINDGEN(101)*!pi/50.
	colat = REPLICATE(grid,101)
	OPLOT, colat, lon, /POLAR,thick=10., color=get_gray()
ENDFOR

ps_close,/no_filename


end