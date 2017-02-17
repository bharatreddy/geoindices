pro rad_map_can_archive,date_rng=date_rng,plot_both_hemi=plot_both_hemi,plot_south=plot_south,plot_north=plot_north

common rad_data_blk
common radarinfo

set_format, /sard, /portrait

;;;check and set the proper plotting keywords


rad_load_colortable,/leicester

if (~keyword_set(plot_both_hemi) and ~keyword_set(plot_south) and ~keyword_set(plot_north)) then $
		plot_both_hemi=1

sc_vals=[0,50,100,125,150,200,300,350,400,450,500]
;; check and set the date_rng parameter
if (~Keyword_set(date_rng)) then begin
	date_rng = [ 20090101, 20090131 ]
	prinfo,'date not set...setting it to entire Jan 2009'
endif

time_rng=[0000,2358]

sfjul,date_rng,time_rng,sjul_search,fjul_search

dt_skip_time=60.d ;;; we search data the grd file every 60 min
del_jul=dt_skip_time/1440.d ;;; This is the time step used to read the data --> Selected to be 60 min

nele_search=((fjul_search-sjul_search)/del_jul)+1 ;; Num of 2-min times to be searched..

;; this is to check the current month, we use this later in the code to update new pages
caldat,sjul_search,curr_month,curr_day,curr_year,strt_hour,strt_min,strt_sec
;; we need day1 too for plotting
curr_day_1=curr_day


;;; Before starting we need to setup stuff like xranges and yranges for plots

xrange=[0.,31.]
dy_in_curr_mnth=12;days_in_month(curr_month,year=curr_year)
yrng_days=[0,dy_in_curr_mnth]


scale = [0,800]

if (keyword_set(plot_both_hemi)) then begin
	plot_north=1
	plot_south=1
endif
	
xrange_nth = [-45, 45]
yrange_nth = [-45, 45]

xrange_sth = [-45, 45]
yrange_sth = [-45, 45]

baseStrNth = '/home/davit2/Desktop/cnvsmry/plots/'
baseStrSth = '/home/davit2/Desktop/cnvsmry/plots/'


for srch=0.d,double(nele_search-1) do begin

;;;Calculate the current jul
	juls_curr=sjul_search+srch*del_jul
        sfjul,datesel,timesel,juls_curr,/jul_to_date

        parse_date, datesel, year_curr, month_curr, day_curr
        year_curr_str = strtrim( string( year_curr ), 2 )

;;;;Now read the map potential data from both hemispheres
;;Before that check if date is already loaded if so skip reading --> saves time
        rad_map_check=rad_map_check_loaded(datesel,1,/silent)
        if (rad_map_check eq 0) then $	
		rad_map_read,datesel,north=plot_north,south=plot_south,both=plot_both_hemi,/silent
		
		
		
	;; need to do some calculations for adjusting stuff
	int_hemi_nth = 0
	int_hemi_sth = 1
	
	;; Northern hemisphere stuff
	; calculate index from date and time
	if keyword_set(plot_north) then begin	
		dd_nth = min( abs( (*rad_map_data[int_hemi_nth]).mjuls-juls_curr ), index_nth)
		; get boundary data
		bnd_nth = (*(*rad_map_data[int_hemi_nth]).bvecs[index_nth])
		if bnd_nth[0].lat lt -999 then $
			min_lat_hm_nth = 60. $
		else $
			min_lat_hm_nth = MIN(bnd_nth[*].lat,/ABSOLUTE)
	endif
	
	;; Southern hemisphere stuff
	if keyword_set(plot_south) then begin
		dd_sth = min( abs( (*rad_map_data[int_hemi_sth]).mjuls-juls_curr ), index_sth)
		; get boundary data
		bnd_sth = (*(*rad_map_data[int_hemi_sth]).bvecs[index_sth])
		if bnd_sth[0].lat lt -999 then $
			min_lat_hm_sth = -60. $
		else $
			min_lat_hm_sth = MIN(bnd_sth[*].lat,/ABSOLUTE)
	endif
		
	;; set the map boundaries (xrange/yrange) according to the HM boundary
	if keyword_set(plot_north) then begin
		if ( (min_lat_hm_nth ge 52.5) and (min_lat_hm_nth lt 57.5) ) then begin
			xrange_nth = [-40, 40]
			yrange_nth = [-40, 40]
		endif
	
		if (min_lat_hm_nth ge 57.5) then begin
			xrange_nth = [-35, 35]
			yrange_nth = [-35, 35]
		endif
	endif
	
	;; set the map boundaries (xrange/yrange) according to the HM boundary
	if keyword_set(plot_south) then begin
		if ( (abs(min_lat_hm_sth) ge 52.5) and (abs(min_lat_hm_sth) lt 57.5) ) then begin
			xrange_sth = [-40, 40]
			yrange_sth = [-40, 40]
		endif
	
		if (abs(min_lat_hm_sth) ge 57.5) then begin
			xrange_sth = [-35, 35]
			yrange_sth = [-35, 35]
		endif
	endif



; Changed by EGT on 20140321 to add an extra 0 to keep timeselStr 4 digits	        
;	if timesel ge 1000. then $
;		timeselStr = strtrim( string(timesel),2 ) $
;	else if (timesel ge 100.) and (timesel lt 1000.) then $
;		timeselStr = '0'+strtrim( string(timesel),2 ) $
;	else $
;		timeselStr = '00'+strtrim( string(timesel),2 )

	if timesel ge 1000. then $
		timeselStr = strtrim( string(timesel), 2) $
	else if (timesel ge 100.) and (timesel lt 1000.) then $
		timeselStr = '0'+strtrim( string(timesel),2 ) $
	else if (timesel ge 10.) and (timesel lt 100.) then $
		timeselStr = '00'+strtrim( string(timesel),2 ) $
	else $
		timeselStr = '000'+strtrim( string(timesel),2 )		

	xrange_nth = [-40,40]
	yrange_nth = [-40,40]
	xrange_sth = [-40,40]
	yrange_sth = [-40,40]
		
	baseStrNthHemiYear = baseStrNth + year_curr_str + '/' + 'north/'
	baseStrSthHemiYear = baseStrSth + year_curr_str + '/' + 'south/'
	
	plotStrNth = baseStrNthHemiYear + 'map-nth-' + strtrim( string(datesel),2 ) + '-' + timeselStr
	plotStrSth = baseStrSthHemiYear + 'map-sth-' + strtrim( string(datesel),2 ) + '-' + timeselStr
	

	if keyword_set(plot_north) then begin
		ps_open,plotStrNth+'.ps'
		
			rad_mapex_summ, date = datesel, time = timesel, hemisphere = 1, coords = 'mlt', $
				/no_plot_imf_ind, xrange = xrange_nth, yrange = yrange_nth, scale = scale
		
		ps_close,/no_filename

		spawn,'gs -sDEVICE=jpeg -dJEPGQ=100 -dNOPAUSE -dBATCH -dSAFER -r300 -sOutputFile='+plotStrNth+'.jpg '+plotStrNth+'.ps'
		spawn,'mogrify +repage -trim -resize 680x674 '+plotStrNth+'.jpg'
		spawn,'rm '+plotStrNth+'.ps'
	endif

	if keyword_set(plot_south) then begin	
		ps_open,plotStrSth+'.ps'
		
			rad_mapex_summ, date = datesel, time = timesel, hemisphere = -1, coords = 'mlt', $
				/no_plot_imf_ind, xrange = xrange_sth, yrange = yrange_sth, scale = scale
		
		ps_close,/no_filename

		spawn,'gs -sDEVICE=jpeg -dJEPGQ=100 -dNOPAUSE -dBATCH -dSAFER -r300 -sOutputFile='+plotStrSth+'.jpg '+plotStrSth+'.ps'
		spawn,'mogrify +repage -trim -resize 680x674 '+plotStrSth+'.jpg'
		spawn,'rm '+plotStrSth+'.ps'
	endif

endfor

end
