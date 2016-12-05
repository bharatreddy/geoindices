pro jo_agu

common rad_data_blk
common radarinfo
common tec_data_blk

rad_load_colortable, /leicester

dateSel = 20120327
timeRange = [ 0000,2100 ]


;; set plot/map parameters
xrangePlot = [-44, 44]
yrangePlot = [-44,30]
velScale = [0,500]
tecScale = [0.,20.]
cntrMinVal = 0.2
n_levels = 5
coords = "mlt"

tec_read, dateSel
rad_map_read, dateSel

sfjul,dateSel,timeRange,sjul_search,fjul_search

dt_skip_time=60.d ;;; we search data the grd file every 2 min
del_jul=dt_skip_time/1440.d ;;; This is the time step used to read the data --> Selected to be 60 min

nele_search=((fjul_search-sjul_search)/del_jul)+1 ;; Num of 2-min times to be searched..

;ps_open, '/home/bharatr/Docs/plots/jo-plots' + strtrim( string(dateSel), 2) + '.ps'
ps_open, '/home/bharatr/Docs/plots/jo-plot.ps'

for srch=0.d,double(nele_search-1) do begin
	clear_page
	;;;Calculate the current jul
	juls_curr=sjul_search+srch*del_jul
	juls_curr_tec = juls_curr + 5.d/1440.d

	sfjul,dateCurrPlot,timeCurrPlot,juls_curr,/jul_to_date
	sfjul,dateCurrTEC,timeCurrTEC,juls_curr_tec,/jul_to_date

	map_plot_panel,date=dateCurrPlot,time=timeCurrPlot,coords=coords,/no_fill,xrange=xrangePlot, $
	        yrange=yrangePlot,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	        title = strtrim( string(timeCurrPlot), 2) + "UT", charsize = 0.5

	;;plot tec vectors
	tec_median_filter,date=dateCurrTEC,time=timeCurrTEC
	overlay_tec_median, date=dateCurrTEC, time=timeCurrTEC, scale=tecScale, coords=coords


	;; plot map potential vectors and contours
	rad_map_overlay_vectors, date = dateCurrPlot, time=timeCurrPlot, coords = coords, $
	                 /no_fov_names, /no_show_Nvc,/no_vector_scale,/fixed_color, scale=velScale
	rad_map_overlay_contours, date = dateCurrPlot, time=timeCurrPlot, coords = coords, thick=5., /no_cross_pot_label, /no_legend, $
					pos_color = get_black(), neg_color=get_black()

	print, "nor,tec-->", dateCurrPlot, timeCurrPlot, dateCurrTEC, timeCurrTEC

	overlay_coast, coords=coords, jul=juls_curr, /no_fill
	map_overlay_grid, grid_linestyle=0, grid_linethick=1, grid_linecolor=get_gray()
	;map_label_grid, coords=coords

	plot_colorbar, 1., 1., 0., 0., /square,scale=tecScale,legend='Total Electron Content [TECU]', level_format='(f6.2)',param='power',/keep_first_last_label;, /left
	;plot_colorbar, 1., 1., 0.15, 0., /square, scale=velScale, parameter='velocity',/keep_first_last_label

endfor

ps_close, /no_filename


end