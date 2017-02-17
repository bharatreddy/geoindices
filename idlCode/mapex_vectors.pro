
pro mapex_vectors, date=date, time=time, long=long, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, scale=scale, ignore_bnd=ignore_bnd, $
	model=model, merge=merge, true=true, los=los, grad=grad, $
	factor=factor, radar_ids=radar_ids, $
	silent=silent, symsize=symsize, thick=thick, $
	fixed_length=fixed_length, fixed_color=fixed_color, $
	no_plot_model_below_hmb=no_plot_model_below_hmb, $
	no_vector_scale=no_vector_scale,no_fov_names=no_fov_names, $
	no_show_Nvc = no_show_Nvc, map_rotate = map_rotate, map_pot_shift_rad_locs = map_pot_shift_rad_locs, $
	no_symbol_background=no_symbol_background

common rad_data_blk
common recent_panel
common radarinfo

if ~keyword_set(symsize) then $
	symsize = .2

if ~keyword_set(thick) then $
	thick = !p.thick

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~strcmp(coords, 'mlt') and ~strcmp(coords, 'magn') then begin
	prinfo, 'Coordinate system must be MLT or MAGN, setting to MLT'
	coords = 'mlt'
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

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

if rad_map_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if n_elements(index) gt 0 then begin

	sfjul, date, time, (*rad_map_data[int_hemi]).mjuls[index], /jul_to_date
	parse_date, date, year, month, day
	sfjul, date, time, jul
	
endif else begin

	if ~keyword_set(date) then begin
		if ~keyword_set(silent) then $
			prinfo, 'No DATE given, trying for map date.'
		caldat, (*rad_map_data[int_hemi]).sjuls[0], month, day, year
		date = year*10000L + month*100L + day
	endif
	parse_date, date, year, month, day

	if n_elements(time) lt 1 then $
		time = 0000

	if n_elements(time) gt 1 then begin
		if ~keyword_set(silent) then $
			prinfo, 'TIME must be a scalar, selecting first element: '+string(time[0], format='(I4)')
		time = time[0]
	endif
	sfjul, date, time, jul, long=long

	; calculate index from date and time


	dd = min( abs( (*rad_map_data[int_hemi[0]]).mjuls-jul[0] ), index)
    
        
	; check if time distance is not too big
	if dd*1440.d gt 60. then $
		prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

endelse

if ~keyword_set(scale) then begin
	scale = get_default_range('velocity')
	scale -= min(scale)
endif

if n_elements(scale) ne 2 then begin
	prinfo, 'SCALE must be 2-element vector.'
	return
endif

; get longitude shift
lon_shft = (*rad_map_data[int_hemi]).lon_shft[index]

utsec = (jul - julday(1, 1, year, 0, 0))*86400.d
; calculate lon_shft, i.e. shift magnetic longitude into mlt coordinates
if coords eq 'mlt' then $
	lon_shft += mlt(year, utsec, 0.)*15.

; get boundary data
bnd = (*(*rad_map_data[int_hemi]).bvecs[index])
num_bnd = (*rad_map_data[int_hemi]).bndnum[index]

if ~keyword_set(size) then $
	size = 1.

if ~keyword_set(factor) then $
	factor = 480. $
else $
	factor = factor*480.

if ~keyword_set(radar_ids) then $
	r_ids = [0] $
else $
	r_ids = radar_ids

if ~keyword_set(los) and ~keyword_set(merge) and ~keyword_set(grad) and ~keyword_set(true) then $
	grad = 1

; get color preferences
colortable = get_colortable()
rad_load_colortable,/website
foreground  = get_foreground()
color_steps = 100.
ncolors     = get_ncolors()
bottom      = get_bottom()

; Set color bar and levels
cin = FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps



ncols = 5
count_not_plot_radars = 0
IF keyword_set(model) THEN BEGIN

	model_nvec = (*rad_map_data[int_hemi]).modnum[index]
	if model_nvec le 0 then begin
		prinfo, 'No model vectors found.'
		return
	endif
	; get model velocity data
	model_vec = (*(*rad_map_data[int_hemi]).mvecs[index])
	vdata = make_array(ncols, model_nvec, /float, value=-9999.9)
	vdata[0:1, *] = transpose([[model_vec[*].mlat], [model_vec[*].mlon]])
	vdata[2:3, *] = transpose([[model_vec[*].vel.median], [model_vec[*].azm]])
	npdat = model_nvec
	
ENDIF ELSE BEGIN

	real_nvec  = (*rad_map_data[int_hemi]).vcnum[index]
	if real_nvec le 0 then begin
		prinfo, 'No data vectors found.'
		return
	endif
	st_ids     = (*(*rad_map_data[int_hemi]).gvecs[index])[*].st_id
	if keyword_set(merge) then begin
		real = rad_map_calc_merge_vecs(int_hemi, index, indeces=indeces)
		real_nvec = (real.pos[0,0] eq -9999.9 ? 0 : n_elements(real.pos[0,*]))
		st_ids = st_ids[indeces]
		ncols = 6
		if real[0].pos[0] eq -9999.9 then $
			return
	endif else if keyword_set(true) then $
		real = rad_map_calc_true_vecs(int_hemi, index) $
	else if keyword_set(los) then $
		real = rad_map_calc_los_vecs(int_hemi, index) $
	else if keyword_set(grad) then $
		real = rad_map_calc_grad_vecs(int_hemi, index)
	vdata = make_array(ncols, real_nvec, /float, value=-9999.9)
	vdata[0:1, *] = real.pos
	vdata[2:3, *] = real.vectors
	if keyword_set(merge) then $
		vdata[4:5, *]   = st_ids $
	else $
		vdata[4, *]   = st_ids
	npdat = real_nvec

	; plot radar positions
	; that provides an easy view of who
	; contributed data.
	load_usersym, /circle
	sinds = sort(st_ids)
	uids = st_ids[ sinds[ uniq( st_ids[sinds] ) ] ]

	; *** Print number of radars ***	
	nradstr = textoidl('N_{rads} = ')+strtrim(n_elements(uids),2)
	yloc_missed_rad_plot = !y.crange[0]+((count_not_plot_radars+1.)/2)*0.05*(!y.crange[1]-!y.crange[0])
	xyouts, !x.crange[0]+0.025*(!x.crange[1]-!x.crange[0]), yloc_missed_rad_plot, nradstr, charthick=!p.charthick, $
		charsize=.65, orientation=orientation, noclip=0, align=0, color=get_black()
	count_not_plot_radars = count_not_plot_radars + 1
	; *** Print number of radars ***

	for i=0, n_elements(uids)-1 do begin
		caldat, jul, mm, dd, yy, hh, ii, ss
		rtmp = radargetradar(network, uids[i])
		site = radarymdhmsgetsite(rtmp, yy, mm, dd, hh, ii, ss)
		ttt = cnvcoord(site.geolat, site.geolon, 0.)
		mlat = ttt[0]
		mlon = ttt[1]
		if coords eq 'mlt' then $
			mlon = mlt(year, utsec, mlon)
		tt = calc_stereo_coords(mlat, mlon, mlt=(coords eq 'mlt'), rotate = map_rotate)

		align = 0.
		offset = [.5,-3.]
		if (rtmp.id eq 8 or rtmp.id eq 13 or rtmp.id eq 16 or rtmp.id eq 33 or rtmp.id eq 204 or rtmp.id eq 206 or rtmp.id eq 208) then begin
			
				offset[0] = -0.5
				align = 1.
			
				
		endif
		
		
		; get boundary data
		bnd_hm = (*(*rad_map_data[int_hemi]).bvecs[index])
		if bnd_hm[0].lat lt -999 then $
			min_lat_hm = 60. $
		else $
			min_lat_hm = MIN(bnd_hm[*].lat,/ABSOLUTE)
			
		min_lat_hm = abs(min_lat_hm)
		lat_plot_min = 45.
		
		if ( (min_lat_hm ge 52.5) and (min_lat_hm lt 57.5) ) then begin
			lat_plot_min = 50.
		endif
	
		if (min_lat_hm ge 57.5) then begin
			lat_plot_min = 55.
		endif
		
		
		if (~keyword_set(no_fov_names)) then begin
			if abs(mlat) gt lat_plot_min then begin
				plots, tt[0], tt[1], psym=1, thick=3, noclip=0, color=get_gray()
				plots, tt[0], tt[1], psym=8, noclip=0, symsize=0.6, color=get_gray()
			endif
		endif

		astring = strupcase(rtmp.code[0])
		
		; shift the label for FHW a little to the left
		; so that it doesn't interfere with FHE
		; same for sto, bks and ksr

		if abs(mlat) gt lat_plot_min then begin
			if (~keyword_set(no_fov_names)) then begin
				xyouts, tt[0]+offset[0], tt[1]+offset[1], astring, charthick=2.*!p.charthick, $
					charsize=.8*get_charsize(rxmaps, rymaps), orientation=orientation, noclip=0, align=align, color=get_white()
				xyouts, tt[0]+offset[0], tt[1]+offset[1], astring, charthick=!p.charthick, $
					charsize=.8*get_charsize(rxmaps, rymaps), orientation=orientation, noclip=0, align=align, color=get_gray()
			endif
		endif else begin
; 			count_not_plot_radars = i
;			yloc_missed_rad_plot = !y.crange[0]+((count_not_plot_radars+1.)/2)*0.05*(!y.crange[1]-!y.crange[0]);-.06*(!y.crange[1]-!y.crange[0])
			yloc_missed_rad_plot = !y.crange[0]+((count_not_plot_radars+1.)/2)*0.05*(!y.crange[1]-!y.crange[0])+.02*(!y.crange[1]-!y.crange[0])
			
			xyouts, !x.crange[0]+0.025*(!x.crange[1]-!x.crange[0]), yloc_missed_rad_plot, astring, charthick=2.*!p.charthick, $
					charsize=.8*get_charsize(rxmaps, rymaps), orientation=orientation, noclip=0, align=0, color=get_white()
			xyouts, !x.crange[0]+0.025*(!x.crange[1]-!x.crange[0]), yloc_missed_rad_plot, astring, charthick=!p.charthick, $
				charsize=.8*get_charsize(rxmaps, rymaps), orientation=orientation, noclip=0, align=0, color=get_gray()		
			count_not_plot_radars = count_not_plot_radars + 1
		endelse
		
	endfor
		
ENDELSE

; load circle 
load_usersym, /circle

no_plot_count = 0L

;vdata(0,*)=gmlong  vdata(1,*)=gmlat  vdata(2,*)=magnitude  vdata(3,*)=azimuth  vdata(4,*)=radar_id
if npdat gt 0 then begin
  FOR i=0, npdat-1 DO BEGIN
  
    if r_ids[0] ne 0 then begin
			if keyword_set(merge) then begin
				dd = where(r_ids eq vdata[4,i] or r_ids eq vdata[5,i], cc)
				if cc eq 0 then $
					continue
			endif else begin
				dd = where(r_ids eq vdata[4,i], cc)
				if cc eq 0 then $
					continue
			endelse
		endif

		lat = vdata[0,i]
		lon = ( vdata[1,i] + 360. ) mod 360.
		
		; check if vector lies underneath boundary
		; if so, plot it gray
		vec_col = cin[(MAX(where(lvl le ((vdata[2,i] > scale[0]) < scale[1]))) > 0)]
		if ~keyword_set(ignore_bnd) then begin
			dd = min(abs(bnd[*].lon-lon), minind)
			IF abs(lat) LT abs(bnd[minind].lat) THEN begin
				if keyword_set(no_plot_model_below_hmb) then begin
					no_plot_count += 1L
					continue
				endif
				vec_col = get_gray()
			endif
		endif
		if n_elements(fixed_color) gt 0 then $
			vec_col = fixed_color

		if coords eq 'mlt' then $
			plon = (lon+lon_shft)/15. $
		else $
			plon = (lon+lon_shft)
		lon_rad = (lon + lon_shft)*!dtor
		tmp = calc_stereo_coords(lat, plon, hemisphere=hemisphere, mlt=(coords eq 'mlt'), rotate = map_rotate )
		x_pos_vec = tmp[0]
		y_pos_vec = tmp[1]

		vec_azm = vdata[3,i]*!dtor + ( hemisphere lt 0. ? !pi : 0. )
		vec_len = (keyword_set(fixed_length) ? $
			factor*abs(fixed_length)/!re/1e3 : factor*vdata[2,i]/!re/1e3 )*hemisphere

		; Find latitude of end of vector
		vec_lat = asin( $
			( $
				( sin(lat*!dtor)*cos(vec_len) + $
					cos(lat*!dtor)*sin(vec_len)*cos(vec_azm) $
				) < 1. $
			) > (-1.) $
		)*!radeg

		; Find longitude of end of vector
		delta_lon = ( $
			atan( sin(vec_azm)*sin(vec_len)*cos(lat*!dtor), cos(vec_len) - sin(lat*!dtor)*sin(vec_lat*!dtor) ) $
		)

		if coords eq 'mlt' then $
			vec_lon = (lon_rad + delta_lon)*!radeg/15. $
		else $
			vec_lon = (lon_rad + delta_lon)*!radeg

		; Find x and y position of end of vectors
		tmp = calc_stereo_coords(vec_lat, vec_lon, hemisphere=hemisphere, mlt=(coords eq 'mlt'), rotate = map_rotate )
		new_x = tmp[0]
		new_y = tmp[1]

		if ~keyword_set(no_symbol_background) then begin
			oplot, [x_pos_vec], [y_pos_vec], psym=8, $
				symsize=1.4*symsize, color=get_background(), noclip=0
			oplot, [x_pos_vec,new_x], [y_pos_vec,new_y],$
				thick=2.*thick, COLOR=get_background(), noclip=0
		endif
		oplot, [x_pos_vec], [y_pos_vec], psym=8, $
			symsize=symsize, color=vec_col, noclip=0

		if ~keyword_set(ignore_bnd) then begin
			dd = min(abs(bnd[*].lon-lon), minind)
			IF abs(lat) GE abs(bnd[minind].lat) THEN begin
				oplot, [x_pos_vec,new_x], [y_pos_vec,new_y],$
					thick=thick, COLOR=vec_col, noclip=0
			ENDIF
		ENDIF

;		oplot, [x_pos_vec], [y_pos_vec], psym=8, $
;			symsize=symsize, color=vec_col, noclip=0
;		oplot, [x_pos_vec,new_x], [y_pos_vec,new_y],$
;			thick=thick, COLOR=vec_col, noclip=0

  ENDFOR
ENDIF


if (npdat-no_plot_count) ge 100. then $
	loc_vec_xloc = .03 $
else $
	loc_vec_xloc = .05
	
if (~keyword_set ( no_show_Nvc ) ) then begin

	if keyword_set(model) then $
		xyouts, !x.crange[1]+.2*(!x.crange[1]-!x.crange[0]), !y.crange[0]+.025*(!y.crange[1]-!y.crange[0]), $
			textoidl('n_{md}=')+strtrim(string(npdat-no_plot_count),2)+' pts', align=1, charsize=.75*get_charsize(rxmaps, rymaps) $
	else $
		xyouts, !x.crange[1]-loc_vec_xloc*(!x.crange[1]-!x.crange[0]), !y.crange[0]+.025*(!y.crange[1]-!y.crange[0]), $
			textoidl('N_{vc} = ')+strtrim(string(npdat-no_plot_count),2), align=1, charsize=0.65
	;     xyouts, !x.crange[0]+.45*(!x.crange[1]-!x.crange[0]), !y.crange[1]-.09*(!y.crange[1]-!y.crange[0]), $
	;                  'VT-SuperDARN Provisional plot', align=1, charsize=.75*get_charsize(rxmaps, rymaps)
	
endif

if ~keyword_set(no_vector_scale) then begin

	velMarker = 1000.

	xorig = !x.crange[0]+.02*(!x.crange[1]-!x.crange[0]) ; !x.crange[1]-.13*(!x.crange[1]-!x.crange[0])
	yorig = !y.crange[1]-.25*(!y.crange[1]-!y.crange[0]) ; !y.crange[0]+.125*(!y.crange[1]-!y.crange[0])
	tmp = calc_stereo_coords(xorig, yorig, hemisphere=hemisphere, mlt=(coords eq 'mlt'), /inverse, rotate = map_rotate )
	latorig = tmp[0]
	lonorig = tmp[1]*(coords eq 'mlt' ? 15. : 1.) ; always in degree!
	;print, latorig, lonorig, tmp[1]
	tmp = calc_stereo_coords(xorig+10., yorig, hemisphere=hemisphere, mlt=(coords eq 'mlt'), /inverse, rotate = map_rotate )
	latdest = tmp[0]
	londest = tmp[1]*(coords eq 'mlt' ? 15. : 1.) ; always in degree!
	;print, latdest, londest, tmp[1]
	vec_azm = calc_vector_bearing( [latorig, latdest], [lonorig, londest] )*!dtor
	;print, vec_azm
	vec_len = factor*velMarker/!re/1e3
	;print, vec_len
	; Find latitude of end of vector
	vec_lat = asin( $
		( $
			( sin(latorig*!dtor)*cos(vec_len) + $
				cos(latorig*!dtor)*sin(vec_len)*cos(vec_azm) $
			) < 1. $
		) > (-1.) $
	)*!radeg
	; Find longitude of end of vector
	delta_lon = ( $
		atan( sin(vec_azm)*sin(vec_len)*cos(latorig*!dtor), cos(vec_len) - sin(latorig*!dtor)*sin(vec_lat*!dtor) ) $
	)
	if coords eq 'mlt' then $
		vec_lon = (lonorig + delta_lon*!radeg)/15. $
	else $
		vec_lon = lonorig + delta_lon*!radeg
	; Find x and y position of end of vectors
	tmp = calc_stereo_coords(vec_lat, vec_lon, mlt=(coords eq 'mlt') )
	new_x = tmp[0]
	new_y = tmp[1]

	;print, vec_lat, vec_lon
	;print, xorig, yorig
	;print, new_x, new_y

	oplot, [xorig], [yorig], psym=8, $
		symsize=1.4*symsize, color=get_background(), noclip=0
	oplot, [xorig,new_x], [yorig,new_y],$
		thick=2*thick, COLOR=get_background(), noclip=0
;; We use plots instead of oplot because we are plotting outside the map
	plots, [xorig], [yorig], psym=8, $
		symsize=symsize, color=253;, noclip=0
	plots, [xorig,new_x], [yorig,new_y],$
		thick=thick, COLOR=253;, noclip=0

	xyouts, xorig, yorig+.02*(!y.crange[1]-!y.crange[0]), strtrim(string(velMarker,format='(I)'),2)+' m/s', $
		charsize=.5, align=.1

endif
rad_load_colortable,colortable
end
