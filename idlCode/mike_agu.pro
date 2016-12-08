pro mike_agu

common rad_data_blk
common radarinfo
common tec_data_blk
common omn_data_blk
common aur_data_blk
common kpi_data_blk



dateSel = 20150616;20150409;
timeRange = [ 0600,1200 ];[ 0730,0930 ]
timeSel = [ 0900 ];[ 0900 ];

;; POES PLOT DEATIALS
poesSymSize = 0.5
;; read data from the poes files
fNamePoesEle = "/home/bharatr/Docs/data/eleflux-jun172015.txt"
fNamePoesPro = "/home/bharatr/Docs/data/proflux-jun172015.txt"


rad_fan_ids = [ 208, 209, 206, 207, 204, 205, 33, 32, 40 ]


;; we need to adjust the xticks with the number of hours plotted...
;; we need to adjust the xticks with the number of hours plotted...
;; we need to adjust the xticks with the number of hours plotted...
num_hours_for_plot = round( ( timeRange[1]/100 ) - ( timeRange[0]/100 ) )


xticks_major_num = 8
xminor_ticks_num = 6
if ( (num_hours_for_plot eq 24.) or (num_hours_for_plot eq 22.)) then begin
	xticks_major_num = num_hours_for_plot/2
	xminor_ticks_num = 6
endif

if ( (num_hours_for_plot eq 23.) ) then begin
	xticks_major_num = 9
	xminor_ticks_num = 6
endif

if ( (num_hours_for_plot ge 13.) and (num_hours_for_plot le 21.) ) then begin
	xticks_major_num = 9
	xminor_ticks_num = 4
endif

if ( (num_hours_for_plot ge 6.) and (num_hours_for_plot le 12.) ) then begin
	xticks_major_num = num_hours_for_plot
	xminor_ticks_num = 6
endif


if ( (num_hours_for_plot ge 3.) and (num_hours_for_plot lt 6.) ) then begin
	xticks_major_num = 2*num_hours_for_plot
	xminor_ticks_num = 6
endif

if ( (num_hours_for_plot gt 1.) and (num_hours_for_plot le 2.) ) then begin
	xticks_major_num = 12
	xminor_ticks_num = 5
endif


if ( (num_hours_for_plot le 1.) ) then begin
	xticks_major_num = 12
	xminor_ticks_num = 5
endif
;; we need to adjust the xticks with the number of hours plotted...
;; we need to adjust the xticks with the number of hours plotted...
;; we need to adjust the xticks with the number of hours plotted...


;;;; Print the date in a proper format on the plot, so get year, month and day from date variable.
;;;; Print the date in a proper format on the plot, so get year, month and day from date variable.
;;;; Print the date in a proper format on the plot, so get year, month and day from date variable.
year_plot=fix(dateSel/1e4)
mndy=double(dateSel)-double(year_plot*1e4)
month_plot=fix(mndy/1e2)
day_plot=fix(mndy-month_plot*1e2)
month_list_plot=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']

date_in_plot_format=month_list_plot[month_plot-1]+'/'+strtrim(string(day_plot),2)+'/'+strtrim(string(year_plot),2)
;;;; Print the date in a proper format on the plot, so get year, month and day from date variable.
;;;; Print the date in a proper format on the plot, so get year, month and day from date variable.
;;;; Print the date in a proper format on the plot, so get year, month and day from date variable.














;; POES LOAD DATA
;; POES LOAD DATA
;; POES LOAD DATA

aacgm_lat_foot = fltarr(1)
aacgm_lon_foot = fltarr(1)
MLT = fltarr(1)
log_ele_flux = fltarr(1)
MLT = fltarr(1)
dateStr = dblarr(1)
timeCurr = fltarr(1)

nel_arr_all = 1000000.d

mlatArrEle = fltarr(nel_arr_all)
mlonArrEle = fltarr(nel_arr_all)
mltArrEle = fltarr(nel_arr_all)
logEleFluxArrEle = fltarr(nel_arr_all)
satArrEle = intarr(nel_arr_all)
dateArrEle = lonarr(nel_arr_all)
timeArrEle = lonarr(nel_arr_all)
julsArrEle = dblarr(nel_arr_all)


nv=0.d
OPENR, 1, fNamePoesEle
WHILE not eof(1) do begin
    READF,1, aacgm_lat_foot, aacgm_lon_foot, MLT, log_ele_flux, sat, dateStr, timeCurr

    ;print,aacgm_lat_foot, aacgm_lon_foot, MLT, log_ele_flux, sat, dateStr, timeCurr


    mlatArrEle[nv] = aacgm_lat_foot

    mlonArrEle[nv] = aacgm_lon_foot
    
    mltArrEle[nv] = MLT
    
    logEleFluxArrEle[nv] = log_ele_flux
    satArrEle[nv] = sat
    dateArrEle[nv] = ulong( dateStr )
        
    timeArrEle[nv] = uint( timeCurr )

    sfjul, ulong( dateStr ), uint( timeCurr ), juls_curr


    ;if (juls_curr-jul_curr ge 0.) then begin
    ;    print, ulong( dateStr ), uint( timeCurr ), juls_curr, jul_curr, juls_curr-jul_curr
    ;endif else begin
    ;    print, "juls_curr-jul_curr", ulong( dateStr ), uint( timeCurr ), juls_curr-jul_curr
    ;endelse

    julsArrEle[nv] = juls_curr

    nv=nv+1   
ENDWHILE         
close,1


mlatArrEle = mlatArrEle[0:nv-1] 
mlonArrEle = mlonArrEle[0:nv-1] 
mltArrEle = mltArrEle[0:nv-1]

logEleFluxArrEle = logEleFluxArrEle[0:nv-1] 
satArrEle = satArrEle[0:nv-1] 
dateArrEle = dateArrEle[0:nv-1]

timeArrEle = timeArrEle[0:nv-1]
julsArrEle = julsArrEle[0:nv-1]


;; get the time range chosen
sfjul, dateSel, timeSel[0], jul_time_sel
jul_range_poes = [jul_time_sel - 45./1440.d, jul_time_sel + 45./1440.d] 
sfjul, date_range_poes, time_range_poes, jul_range_poes, /jul_to_date
print, "POES times selected-->", date_range_poes, time_range_poes



jindsTimeSel = where( (julsArrEle ge jul_range_poes[0]) and (julsArrEle le jul_range_poes[1]) and ( mlatArrEle ge 50. ) ); 

if (jindsTimeSel[0] ne -1) then begin

	julsSelTimes = julsArrEle[ jindsTimeSel ]
	timesSelTimes = timeArrEle[ jindsTimeSel ]
	mlatSelTimes = mlatArrEle[ jindsTimeSel ]
	mlonSelTimes = mlonArrEle[ jindsTimeSel ]
	mltSelTimes = mltArrEle[ jindsTimeSel ]
	logEleFluxSelTimes = logEleFluxArrEle[ jindsTimeSel ]
	satSelTimes = satArrEle[ jindsTimeSel ]

	poesScale = [ fix(min(logEleFluxSelTimes)), fix(max(logEleFluxSelTimes)) ]
endif


;; POES LOAD DATA
;; POES LOAD DATA
;; POES LOAD DATA



















;; set plot/map parameters
xrangePlot = [-44, 44]
yrangePlot = [-44,30]
velScale = [-500,500]
tecScale = [0.,20.]
ampScale = [ -1.5, 1.5 ]
cntrMinVal = 0.2
n_levels = 5
coords = "mlt"
omnCharsize = 0.5



;tec_read, dateSel
;rad_map_read, dateSel
;amp_read, dateSel

sfjul,dateSel,timeRange,sjul_search,fjul_search


dt_skip_time=30.d ;;; we search data the grd file every 2 min
del_jul=dt_skip_time/1440.d ;;; This is the time step used to read the data --> Selected to be 60 min

nele_search=((fjul_search-sjul_search)/del_jul)+1 ;; Num of 2-min times to be searched..
npanels = round((fjul_search-sjul_search)*1440.d/dt_skip_time) + 1


;ps_open, '/home/bharatr/Docs/plots/jo-plots' + strtrim( string(dateSel), 2) + '.ps'
ps_open, '/home/bharatr/Docs/plots/mike-plot-' + strtrim( string(dateSel[0]), 2) + '.ps'


clear_page
set_format, /sardi
;;;Calculate the current jul
sfjul,dateSel,timeSel[0],juls_curr


;; plot omni data
omn_read,dateSel,time=timeRange
aur_read,dateSel,time=timeRange

pos_omn_panel1=define_panel(1.25,8.5,0,0, aspect=aspect,/bar)
pos_ae_panel=define_panel(1.25,8.5,0,1, aspect=aspect,/bar)

jinds_omn_by_finite=where(finite(omn_data.by_gsm))
jinds_omn_bz_finite=where(finite(omn_data.bz_gsm))
yrange_omn_min_val=min([min(omn_data.by_gsm[jinds_omn_by_finite]),min(omn_data.bz_gsm[jinds_omn_bz_finite])])
yrange_omn_max_val=max([10,max(omn_data.by_gsm[jinds_omn_by_finite]),max(omn_data.bz_gsm[jinds_omn_bz_finite])])
yrange_omn=[5*(round(yrange_omn_min_val/5)-1),5*(round(yrange_omn_max_val/5)+1)]
jinds_omn_PD_check=where(finite(omn_data.pd))
if (jinds_omn_PD_check[0] ne -1) then begin
        max_omn_PD=max(omn_data.pd[jinds_omn_PD_check])
endif else begin    
    max_omn_PD=10
endelse


omn_plot_panel,date=dateSel, time=timeRange, position=pos_omn_panel1,ytickname=replicate(' ', 40), $
    param='pd',charsize=omnCharsize,xtickformat=_xtickformat, xminor= xminor_ticks_num, xticks= xticks_major_num, $
    linecolor=get_green(), ytitle=' ', linethick=2,ystyle=1,yminor=4,yticks=1,yrange=[0,5*(fix(max_omn_PD/5)+1)]

;omn_plot_panel,date=dateCurrPlot,time=timeRange, position=pos_omn_panel1,ytickname=replicate(' ', 40), $
			;param='vt',charsize=omnCharsize,xtickformat='label_date', xstyle=1, xticks= xticks_major_num,xminor= xminor_ticks_num,$
			;linecolor=get_blue(),linethick=2, ytitle=' ',ystyle=1,yminor=4,yticks=1,yrange=[0,800]


    ;axis,fjul_search+0.065*(fjul_search-sjul_search),yaxis=1, ytitle="Vel[km/s]",color=get_blue(), $
    			;charsize=omnCharsize,ystyle=1,yminor=4,yticks=4,yrange=[0,800],ticklen=-0.005

oplot,[juls_curr,juls_curr],[!y.crange[0],!y.crange[1]],linestyle=2,thick=3, color=get_black()

axis,yaxis=1, ytitle='OMN-PD[nPa]',color=get_green(),charsize=omnCharsize,ystyle=1,yminor=4,yticks=fix(((yrange_omn[1])-(yrange_omn[0]))/5),$
        yrange=[0,5*(fix(max_omn_PD/5)+1)]

omn_plot_panel, date=dateSel, time=timeRange, position=pos_omn_panel1, yrange=yrange_omn, $
			param='bz_gsm',charsize=omnCharsize,xtickformat=_xtickformat, xminor= xminor_ticks_num, xticks= xticks_major_num, $
			xstyle=1, linecolor=get_red(), ytitle='OMNI-IMF[nT]', linethick=2,ystyle=1,yminor=4,yticks=fix(((yrange_omn[1])-(yrange_omn[0]))/5)

xyouts, sjul_search + 20.d/1440.d, !y.crange[0]+.13*(!y.crange[1]-!y.crange[0]), $
	'Bz', color=get_red(), charsize=omnCharsize, charthick=2
oplot,[omn_data.juls[0],omn_data.juls[n_elements(omn_data.juls)-1]],[0,0],linestyle='2',thick=2
loadct,0
oplot,omn_data.juls,omn_data.by_gsm,color=100

xyouts, sjul_search + 20.d/1440.d, !y.crange[1]-.18*(!y.crange[1]-!y.crange[0]), $
	'By', color=100, charsize=omnCharsize, charthick=2


plot,[0],[0],/nodata,xtickformat='label_date',pos=pos_ae_panel,xticklen=0.05, $
				xticks= xticks_major_num,xminor= xminor_ticks_num,xstyle=1,xrange=[sjul_search,fjul_search],xtitle='TIME (UT)',$
				ytitle='AE Ind[nT]',yrange=[0, 1500],charsize=omnCharsize,ystyle=1,yminor=4, yticks=5
			
			
oplot,aur_data.juls,aur_data.ae_index





oplot,[juls_curr,juls_curr],[!y.crange[0],!y.crange[1]],linestyle=2,thick=3, color=get_black()





rad_load_colortable,/website



mapPos = define_panel(1,1.4,0,0.4, aspect=aspect,/bar)

map_plot_panel,date=dateSel,time=timeSel[0],coords=coords,/no_fill,xrange=xrangePlot, $
        yrange=yrangePlot,pos=mapPos,/isotropic,grid_charsize='0.5',/north, charsize = 0.5






;; plot the time thing in hh:mm UT format
;; plot the time thing in hh:mm UT format
str_hr_mv_ind_curr = strtrim( fix(timeSel[0]/100), 2 )

min_mv_ind_curr = fix( timeSel[0] - fix(timeSel[0]/100)*100 )
if ( min_mv_ind_curr lt 10 ) then $
	str_min_mv_ind_curr = '0' + strtrim( min_mv_ind_curr, 2 ) $
else $
	str_min_mv_ind_curr = strtrim( min_mv_ind_curr, 2 )
	
xyouts, !x.crange[0]+.45*(!x.crange[1]-!x.crange[0]), !y.crange[1]+.02*(!y.crange[1]-!y.crange[0]), $
	date_in_plot_format + " - " + str_hr_mv_ind_curr+':'+str_min_mv_ind_curr+'UT', align=1, charsize=0.75


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
;xyouts, !x.crange[0]+ndots_anim*0.11*((!x.crange[1]-!x.crange[0])/ndots_anim), !y.crange[1]+.02*(!y.crange[1]-!y.crange[0]), $
;			st_time_mv_ind, align=1, charsize=0.75

end_time_mv_ind = str_hr_mv_ind_end+':'+str_min_mv_ind_end+' UT';strtrim(string(time[1]),2)+' UT'	
;xyouts, !x.crange[0]+(ndots_anim+ndots_anim*0.0075)*((!x.crange[1]-!x.crange[0])/ndots_anim), !y.crange[1]+.02*(!y.crange[1]-!y.crange[0]), $
;	end_time_mv_ind, align=1, charsize=0.75

;for jjj = 0, ndots_anim do begin				
	;plots, !x.crange[0]+jjj*((!x.crange[1]-!x.crange[0])/ndots_anim), !y.crange[1]+.01*(!y.crange[1]-!y.crange[0]), psym = 8, symsize = 0.5
;endfor




;; plot the time thing in hh:mm UT format
;; plot the time thing in hh:mm UT format


;rad_map_overlay_vectors, date = dateSel, time=timeSel[0], coords = coords, $
;                 /no_fov_names, /no_show_Nvc,/no_vector_scale, scale=velScale, symsize=0.35,fixed_color = 215



rad_map_overlay_scan, rad_fan_ids, juls_curr, scale=velScale, coords=coords, $
				param = 'velocity', /vector_scan, rad_sct_flg_val = 2, /AJ_filter;, $
				;sc_values = 0, set_grnd = fix(velScale[1]/40.)



;; PLOT POES DATA
;; PLOT POES DATA
if (jindsTimeSel[0] ne -1) then begin
	for k = 0,n_elements(mlatSelTimes) -1 do begin
	    

	    stereCr_low = calc_stereo_coords( mlatSelTimes[k], mltSelTimes[k], /mlt )

	    colValCurr = get_color_index(logEleFluxSelTimes[k],scale=poesScale,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	    
	    oplot, [stereCr_low[0]], [stereCr_low[1]], color = colValCurr,thick = selSymThick, psym=8, SYMSIZE=poesSymSize
	    
	endfor
endif else begin

	rad_map_overlay_dmsp, dateSel, timeSel[0], coords=coords,/ssj4
	dmsp_ssj_fit_eqbnd, dateSel, timeSel[0], coords = coords

endelse


;; PLOT POES DATA
;; PLOT POES DATA


overlay_coast, coords=coords, jul=juls_curr, /no_fill
map_overlay_grid, grid_linestyle=0, grid_linethick=1, grid_linecolor=get_gray()
;map_label_grid, coords=coords


plot_colorbar, 1., 1.4, -0.02, 0.4, /square,scale=tecScale,legend=TeXtoIDL('Log. POES Elec Flux [#/cm^{2} s^{1} sr^{1} ev^{1}]'), level_format='(f6.2)',param='power', /left, charsize = 0.5
plot_colorbar, 1., 1.4, 0.02, 0.4, /square, scale=velScale, parameter='velocity', charsize = 0.5



ps_close, /no_filename


end