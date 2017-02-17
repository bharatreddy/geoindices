pro rad_mapex_summ, date=date, time=time, long=long, $
	coords=coords, index=index, scale=scale, new_page=new_page, $
	north=north, south=south, hemisphere=hemisphere, $
	xrange=xrange, yrange=yrange, $
	cross=cross, coast=coast, no_fill=no_fill, orig_fan=orig_fan, $
	model=model, merge=merge, true=true, los=los, grad=grad, $
	vec_radar_ids=vec_radar_ids, fan_radar_ids=fan_radar_ids, $
	vectors=vectors, potential=potential, efield=efield, $
	comp_east_west=comp_east_west, comp_north_south=comp_north_south, $
	isotropic=isotrpoic,dt_diff_newplot=dt_diff_newplot, contour_fill = contour_fill, $
	rad_sct_flg_val = rad_sct_flg_val, no_fov_names = no_fov_names, no_plot_imf_ind = no_plot_imf_ind, $
	dms_ssj_overlay = dms_ssj_overlay, dms_ssies_overlay = dms_ssies_overlay, poes_flux_overlay = poes_flux_overlay, $
	overlay_r1_oval = overlay_r1_oval, overlay_r2_oval = overlay_r2_oval, noOverlayHMB = noOverlayHMB

common rad_data_blk
common omn_data_blk
common aur_data_blk
common kpi_data_blk
common pos_data_blk
common r12oval_data_blk


if ~keyword_set(vectors) and ~keyword_set(potential) and ~keyword_set(efield) then begin
	if ~keyword_set(silent) then $
		prinfo, 'Nothing selected to plot, choosing vectors and potential.'
	vectors = 1
	potential = 1
	efield = 0
endif


; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif


hemi_orig_chosen=hemisphere
date_orig_chosen = date
time_orig_chosen = time

if ~keyword_set(rad_sct_flg_val) then $
	rad_sct_flg_val = 0

if (~keyword_set(contour_fill)) then $
	contour_fill_final = 1	$
else $
	contour_fill_final = 0

if ~keyword_set(dt_diff_newplot) then $
	dt_diff_newplot = 2.


if ~keyword_set(scale) then $
	scale = [0,800]

if n_elements(yrange) ne 2 then $
	yrange = [-45,45]

if n_elements(xrange) ne 2 then $
	xrange = [-45,45]

if ~keyword_set(no_fov_names) then $
	no_fov_names = 0	


aspect = float(xrange[1]-xrange[0])/float(yrange[1]-yrange[0])

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

if rad_map_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if n_elements(index) ne 0 then $
	sfjul, date, time, (*rad_map_data[int_hemi]).mjuls[index], /jul

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, (*rad_map_data[int_hemi]).sjuls[0], month, day, year
	date = year*10000L + month*100L + day
endif


sfjul, date, time, sjul

; sample time of maps
; in minutes
if rad_map_info[int_hemi].nrecs ge 3L then $
	dt = mean(deriv((*rad_map_data[int_hemi]).mjuls*1440.d)) $
else $
	dt = dt_diff_newplot

; account for sjul being before the
; date/time of the first map
sjul = ( sjul > (*rad_map_data[int_hemi]).sjuls[0] )

npanels = 1
; calculate number of panels per page
if npanels eq 1 then begin
	xmaps = 1
	ymaps = 1
endif else if npanels eq 2 then begin
	xmaps = 2
	ymaps = 1
endif else if npanels le 4 then begin
	xmaps = 2
	ymaps = 2
endif else if npanels le 6 then begin
	xmaps = 3
	ymaps = 2
endif else begin
	xmaps = floor(sqrt(npanels)) > 1
	ymaps = ceil(npanels/float(xmaps)) > 1
endelse

; take into account format of page
; if landscape, make xmaps > ymaps
fmt = get_format(landscape=ls, sardines=sd)
if ls then begin
	if ymaps gt xmaps then begin
		tt = xmaps
		xmaps = ymaps
		ymaps = tt
	endif
; if portrait, make ymaps > xmaps
endif else begin
	if xmaps gt ymaps then begin
		tt = ymaps
		ymaps = xmaps
		xmaps = tt
	endif
endelse

clear_page
set_format, /sardi

mpos = define_panel(xmaps, 1, xmaps-1, 0, aspect=aspect, /bar) - [.6, -.055, .8, -.15];[.06, .075, .06, .075]
; if (~keyword_set(new_page)) then begin
; 	cb_pos = define_cb_position(mpos, height=35, gap=.1*(mpos[2]-mpos[0]))
; 	if keyword_set(vectors) then $
; 		plot_colorbar, /square, scale=scale, parameter='velocity', position=cb_pos,/keep_first_last_label, $
; 			/no_rotate, charsize = 0.65
; 	if keyword_set(orig_fan) then begin
; 		cb_pos = define_cb_position(mpos, height=35, gap=.065*(mpos[2]-mpos[0]))
; 		plot_colorbar, /square, scale=.5*[-scale[1],scale[1]], parameter='velocity',/keep_first_last_label, $
; 			/left, position=cb_pos, legend=' ', charsize = 0.5
; 	endif
; endif



; loop through panels
b=0
; for b=0, npanels-1 do begin
	
; 	asjul = sjul + double(b)*dt_diff_newplot/1440.d
	sfjul, date, time, asjul
	


	; calculate index from date and time
	if n_elements(index) eq 0 then begin
		dd = min( abs( (*rad_map_data[int_hemi]).mjuls-asjul ), _index)
		; check if time ditance is not too big
		if dd*1440.d gt 60. then $
			prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'
	endif else begin
		asjul = (*rad_map_data[int_hemi]).sjuls[index]
		sfjul, date, time, (*rad_map_data[int_hemi]).sjuls[index], /jul_to_date
		
		_index = index
	endelse
	amjul = (*rad_map_data[int_hemi]).mjuls[_index]

	if keyword_set(new_page) then begin
		clear_page
		xmaps = 1
		ymaps = 1
		xmap = 0
		ymap = 0
	endif else begin
		xmap = b mod xmaps
		ymap = b/xmaps
	endelse

	if b eq 0 or keyword_set(new_page) then begin
		opos = define_panel(1, 1, 0, 0, aspect=aspect, /bar) - [.6, .005, .06, .005]

		if (n_elements(tm_orig_set) eq 1) then begin
			orange = [(sjul) + [-1.d,1.d]*30.d/1440.d]
		endif else begin
			orange = [sjul-(30.d/1440.d),sjul+(30.d/1440.d)]
		endelse
		
; 		orange = [amjul + [-1.d,1.d]*30.d/1440.d]
		
		
;;;; Plot Sym-H, Ae and Kp indices

;;;; Plot Aur/Sym indices


oopos = [opos[0], 0.766909, opos[2], 0.846909]


;;;;Plot Npts and Phi-PC
			
		oopos = [opos[0], opos[3]+.03, opos[2], opos[3]+.08]
; 		print,odate,otime,b,npanels

endif

	if ~keyword_set(position) then $
		_position = define_panel(xmaps, ymaps, xmap, ymap, aspect=aspect, /bar) - [.06, .1, .06, .1] $ ;[.06, .075, .06, .075] 
	else $
		_position = position
		
		
	

	;rad_map_plot_vector_scale, xmaps, ymaps, xmap, ymap, gap=.05*get_charsize(xmaps,ymaps), $
	;	scale=scale, xrange=xrange, factor=factor*480., panel_position=_position
	

	call_map_funcs, xmaps, ymaps, xmap, ymap, $
		date=date, time=time, long=long, $
		north=north, south=south, hemisphere=hemisphere, $
		coords=coords, index=_index, scale=scale, $
		/no_fill, cross=cross, /coast, $
		model=model, merge=merge, true=true, los=los, grad=grad, $
		xrange=xrange, yrange=yrange, factor=factor, orig_fan=orig_fan, $
		vec_radar_ids=vec_radar_ids, fan_radar_ids=fan_radar_ids, $
		position=_position, fill = contour_fill_final, $
		vectors=vectors, potential=potential, efield=efield, $
		comp_east_west=comp_east_west, comp_north_south=comp_north_south,isotropic=1, rad_sct_flg_val=rad_sct_flg_val, no_fov_names = no_fov_names
	; rad_map_plot_panel somehow recasts hemisphere as a 1 element array, which sucks! ;; Also if plotting southern hemisphere it changes back to +1 after one plot...

	
	_position_imf = [ _position[0], _position[1], _position[2], _position[3]-0.015 ]

	overlay_imf_time, xmaps, ymaps, xmap, ymap, gap=-.1*get_charsize(xmaps,ymaps), $
		index=_index, size=.09/sqrt(xmaps > ymaps)*(_position[2]-_position[0]), $
    	int_hemisphere=int_hemi, panel_position=_position_imf

	colortable = get_colortable()
	rad_load_colortable,/website	
	mpos_col_bar = mpos
	mpos_col_bar[1] = mpos_col_bar[1] + 0.02
	cb_pos = define_cb_position(mpos_col_bar, height=15, gap=.1*(mpos_col_bar[2]-mpos_col_bar[0]))
	plot_colorbar, /square, scale=scale, parameter='velocity', position=cb_pos, $
				/no_rotate, charsize = 0.4, legend = 'Vel [m/s]', nlevels = 4;, level_values = [ 0, scale[1]/2, scale[1] ]	
	rad_load_colortable,colortable
	
	hemisphere = hemi_orig_chosen
	time = time_orig_chosen
	date = date_orig_chosen
	


; 	write_title, position=_position, date=date, time = time, index=_index, $
; 		charsize=get_charsize(1,2), int_hemisphere=int_hemi, /silent

	
	sfjul, date, time, sjul
	fjul = sjul + 2.d/1440.d
	
	pos2 = define_panel(1, 1, 0, 0, /square, /bar)
	sdate = format_juldate(sjul, /date)
	stime = format_juldate(sjul, /short_time)
	ftime = format_juldate(fjul, /short_time)

	ypos = pos2[3]+.001
	
	charsize = 0.5
	
	info_str = sdate+' '+stime+'-'+ftime+' UT'; + $
	;	', FitOrder: '+string((*rad_map_data[int_hemisphere]).fit_order[index],format='(I1)') + $
	;	', '+(rad_map_info[int_hemisphere].mapex ? 'mapEX' : 'APLmap')+' format'

	dsclmr_str='NOTE: FOR PREVIEW PURPOSES ONLY. PLEASE CONTACT VT-SD STAFF FOR VERIFICATION.'

	xyouts, pos2[0]+0.13, ypos-0.12, $
		info_str, /NORMAL, $
		COLOR=foreground, SIZE=0.7, charthick=3.5
		
	if ~keyword_set(no_disclaimer_str) then $	
		xyouts, pos2[0]-0.079,ypos-0.62, $
			dsclmr_str, /NORMAL, $
			COLOR=foreground, SIZE=charsize, charthick=2., ORIENTATION =90.

		
; 	xyouts, pos2[0]+0.67, ypos-0.67, $
; 		'Hour (MLT)', /NORMAL, $
; 		COLOR=foreground, SIZE=1, charthick=charthick


; endfor

end
