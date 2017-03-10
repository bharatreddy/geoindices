pro jo_sample_multipage

common rad_data_blk
common radarinfo

;; Chosen Date and time range
dateSel = [ 20130317, 20130317 ]
timeRange = [ 0500,2400 ]

;;; we search data the grd file every 10 min
dt_skip_time=10.d 
del_jul=dt_skip_time/1440.d 

;; set plot/map parameters
xticks_major_num = 8
xminor_ticks_num = 6
xrangePlot = [-44, 44]
yrangePlot = [-44,30]
velScale = [0,800]
n_levels = 5
coords = "mlt"
mapPos = define_panel(1,1.4,0,0.4, aspect=aspect,/bar)

;;;; Print the date in a proper format on the plot, so get year, month and day from date variable.
year_plot=fix(dateSel[0]/1e4)
mndy=double(dateSel[0])-double(year_plot*1e4)
month_plot=fix(mndy/1e2)
day_plot=fix(mndy-month_plot*1e2)
month_list_plot=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']

date_in_plot_format=month_list_plot[month_plot-1]+'/'+strtrim(string(day_plot),2)+'/'+strtrim(string(year_plot),2)

;; read the required data
tec_read, dateSel
rad_map_read, dateSel
amp_read, dateSel

sfjul,dateSel,timeRange,sjul_search,fjul_search

;; num of panels/pages in the plot
nele_search=((fjul_search-sjul_search)/del_jul)+1 ;; 
npanels = round((fjul_search-sjul_search)*1440.d/dt_skip_time) + 1

for srch=0,nele_search-1 do begin
	clear_page
	set_format, /sardi
	;;;Calculate the current jul and corresponding date, time
    juls_curr=sjul_search+srch*del_jul
    sfjul,dateCurrPlot,timeCurrPlot,juls_curr,/jul_to_date
    ;; plot the map
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

    ;; overlay superdarn vectors
    rad_map_overlay_vectors, date = dateCurrPlot, time=timeCurrPlot, coords = coords, $
                         /no_fov_names, /no_show_Nvc,/no_vector_scale, scale=velScale, symsize=0.25
    ; plot the colorbar
    plot_colorbar, 1., 1.4, -0.15, 0.4, /square, scale=velScale, parameter='velocity',/keep_first_last_label


endfor


end