pro jo_agu

common rad_data_blk
common radarinfo
common tec_data_blk



dateSel = 20120327
timeRange = [ 0000,2100 ]


;; set plot/map parameters
xrangePlot = [-44, 44]
yrangePlot = [-44,30]
velScale = [0,800]
tecScale = [0.,20.]
ampScale = [ -1.5, 1.5 ]
cntrMinVal = 0.2
n_levels = 5
coords = "mlt"

tec_read, dateSel
rad_map_read, dateSel
amp_read, dateSel

sfjul,dateSel,timeRange,sjul_search,fjul_search


dt_skip_time=30.d ;;; we search data the grd file every 2 min
del_jul=dt_skip_time/1440.d ;;; This is the time step used to read the data --> Selected to be 60 min

nele_search=((fjul_search-sjul_search)/del_jul)+1 ;; Num of 2-min times to be searched..
npanels = round((fjul_search-sjul_search)*1440.d/dt_skip_time) + 1


;ps_open, '/home/bharatr/Docs/plots/jo-plots' + strtrim( string(dateSel), 2) + '.ps'
ps_open, '/home/bharatr/Docs/plots/jo-plot.ps'

for srch=0,nele_search-1 do begin
	clear_page
	set_format, /sardi
	;;;Calculate the current jul
	juls_curr=sjul_search+srch*del_jul
	juls_curr_tec = juls_curr + 5.d/1440.d

	sfjul,dateCurrPlot,timeCurrPlot,juls_curr,/jul_to_date
	sfjul,dateCurrTEC,timeCurrTEC,juls_curr_tec,/jul_to_date

	_position = define_panel(1, 1, 0, 0, aspect=aspect, /bar) 

	mapPos = define_panel(1,1,0,0,/bar)

	map_plot_panel,date=dateCurrPlot,time=timeCurrPlot,coords=coords,/no_fill,xrange=xrangePlot, $
	        yrange=yrangePlot,pos=mapPos,/isotropic,grid_charsize='0.5',/north, charsize = 0.5


	;; plot the time thing in hh:mm UT format
	;; plot the time thing in hh:mm UT format
	str_hr_mv_ind_curr = strtrim( fix(timeCurrPlot/100), 2 )
	
	min_mv_ind_curr = fix( timeCurrPlot - fix(timeCurrPlot/100)*100 )
	if ( min_mv_ind_curr lt 10 ) then $
		str_min_mv_ind_curr = '0' + strtrim( min_mv_ind_curr, 2 ) $
	else $
		str_min_mv_ind_curr = strtrim( min_mv_ind_curr, 2 )
		
	xyouts, !x.crange[1]-.45*(!x.crange[1]-!x.crange[0]), !y.crange[1]+.02*(!y.crange[1]-!y.crange[0]), $
		str_hr_mv_ind_curr+':'+str_min_mv_ind_curr+' UT', align=1, charsize=0.75


	ndots_anim = npanels-1
	load_usersym, /circle, /no_fill

	;; This strtrim and string stuff is to plot the time in the movies in hh:mm UT format
	str_hr_mv_ind_st = strtrim( fix(timeRange[0]/100), 2 )
	str_hr_mv_ind_end = strtrim( fix(timeRange[1]/100), 2 )

	min_mv_ind_st = fix( timeRange[0] - fix(timeRange[0]/100)*100 )
	if ( min_mv_ind_st lt 10 ) then $
		str_min_mv_ind_st = '0' + strtrim( min_mv_ind_st, 2 ) $
	else $
		str_min_mv_ind_st = strtrim( min_mv_ind_st, 2 )

	min_mv_ind_end = fix( timeRange[1] - fix(timeRange[1]/100)*100 )
	if ( min_mv_ind_end lt 10 ) then $
		str_min_mv_ind_end = '0' + strtrim( min_mv_ind_end, 2 ) $
	else $
		str_min_mv_ind_end = strtrim( min_mv_ind_end, 2 )

	st_time_mv_ind = str_hr_mv_ind_st+':'+str_min_mv_ind_st+' UT'
	xyouts, !x.crange[0]+ndots_anim*0.11*((!x.crange[1]-!x.crange[0])/ndots_anim), !y.crange[1]+.02*(!y.crange[1]-!y.crange[0]), $
				st_time_mv_ind, align=1, charsize=0.75

	end_time_mv_ind = str_hr_mv_ind_end+':'+str_min_mv_ind_end+' UT';strtrim(string(time[1]),2)+' UT'	
	xyouts, !x.crange[0]+(ndots_anim+ndots_anim*0.0075)*((!x.crange[1]-!x.crange[0])/ndots_anim), !y.crange[1]+.02*(!y.crange[1]-!y.crange[0]), $
		end_time_mv_ind, align=1, charsize=0.75

	for jjj = 0, ndots_anim do begin				
		plots, !x.crange[0]+jjj*((!x.crange[1]-!x.crange[0])/ndots_anim), !y.crange[1]+.01*(!y.crange[1]-!y.crange[0]), psym = 8, symsize = 0.5
	endfor
	load_usersym, /circle
	for ddd = 0, srch do begin				
		plots, !x.crange[0]+ddd*((!x.crange[1]-!x.crange[0])/ndots_anim), !y.crange[1]+.01*(!y.crange[1]-!y.crange[0]), psym = 8, symsize = 0.5
	endfor



	;; plot the time thing in hh:mm UT format
	;; plot the time thing in hh:mm UT format



	
	rad_load_colortable, /bw
	;;plot tec vectors
	tec_median_filter,date=dateCurrTEC,time=timeCurrTEC
	overlay_tec_median, date=dateCurrTEC, time=timeCurrTEC, scale=tecScale, coords=coords





	rad_load_colortable, /leicester
	;; plot map potential vectors and contours
	rad_map_overlay_vectors, date = dateCurrPlot, time=timeCurrPlot, coords = coords, $
	                 /no_fov_names, /no_show_Nvc,/no_vector_scale, scale=velScale;,/fixed_color
	rad_map_overlay_contours, date = dateCurrPlot, time=timeCurrPlot, coords = coords, thick=5., /no_cross_pot_label, /no_legend, $
					pos_color = get_black(), neg_color=get_black()

	rad_map_overlay_dmsp, dateCurrPlot, timeCurrPlot, coords=coords, /ssies;,/ssj4
	rad_map_overlay_poes, dateCurrPlot, timeCurrPlot, coords=coords

	amp_overlay_current, date = dateCurrPlot, time=timeCurrPlot, coords = coords, scale=ampScale

	print, "nor,tec-->", dateCurrPlot, timeCurrPlot, dateCurrTEC, timeCurrTEC

	overlay_coast, coords=coords, jul=juls_curr, /no_fill
	map_overlay_grid, grid_linestyle=0, grid_linethick=1, grid_linecolor=get_gray()
	;map_label_grid, coords=coords

	rad_load_colortable, /leicester
	;plot_colorbar, 1., 1., 0., 0., /square,scale=tecScale,legend='Total Electron Content [TECU]', level_format='(f6.2)',param='power',/keep_first_last_label;, /left
	plot_colorbar, 1., 1., 0., 0., /square, scale=velScale, parameter='velocity',/keep_first_last_label

endfor

ps_close, /no_filename


end