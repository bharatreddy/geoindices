
pro call_map_funcs_paul, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	position=position, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, xrange=xrange, yrange=yrange, scale=scale, $
	coast=coast, no_fill=no_fill, cross=cross, $
	model=model, merge=merge, true=true, los=los, grad=grad, $
	factor=factor, symsize=symsize, thick=thick, vec_radar_ids=vec_radar_ids, $
	orig_fan=orig_fan, fan_radar_ids=fan_radar_ids, $
	ignore_bnd=ignore_bnd, fill=fill, $
	silent=silent, bar=bar, $
	vectors=vectors, potential=potential, efield=efield, $
	comp_east_west=comp_east_west, comp_north_south=comp_north_south, $
	isotropic=isotrpoic,rad_sct_flg_val = rad_sct_flg_val, no_fov_names = no_fov_names, noOverlayHMB = noOverlayHMB

common rad_data_blk

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

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

if rad_map_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

index = 0
;if n_elements(index) gt 0 then begin
if index ne 0 then begin

	sfjul, date, time, (*rad_map_data[int_hemi]).mjuls[index], /jul_to_date
	parse_date, date, year, month, day
	sfjul, date, time, jul

endif else begin

	if ~keyword_set(date) then begin
		if ~keyword_set(silent) then $
			prinfo, 'No DATE given, trying for scan date.'
		caldat, (*rad_map_data[int_hemi]).sjuls[0], month, day, year
		date = year*10000L + month*100L + day
	endif
	parse_date, date, year, month, day

	if ~keyword_set(time) then $
		time = 0000

	if n_elements(time) gt 1 then begin
		if ~keyword_set(silent) then $
			prinfo, 'TIME must be a scalar, selecting first element: '+string(time[0], format='(I4)')
		time = time[0]
	endif
	sfjul, date, time, jul, long=long

	; calculate index from date and time
	dd = min( abs( (*rad_map_data[int_hemi]).sjuls-jul ), index)

	; check if time distance is not too big
	if dd*1440.d gt 60. then $
		prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

endelse

if ~keyword_set(scale) then $
	scale = [0,2000]

if ~keyword_set(no_fov_names) then $
	no_fov_names = 0
	
if n_elements(yrange) ne 2 then $
	yrange = [-46,46]

if n_elements(xrange) ne 2 then $
	xrange = [-46,46]

if n_params() lt 4 then begin
	if ~keyword_set(silent) and ~keyword_set(position) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif
aspect = float(xrange[1]-xrange[0])/float(yrange[1]-yrange[0])
if ~keyword_set(position) then $
	position = define_panel(xmaps, ymaps, xmap, ymap, aspect=aspect, bar=bar)

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~strcmp(coords, 'geog') and ~strcmp(coords, 'magn') and ~strcmp(coords, 'mlt') then begin
	prinfo, 'Coordinate system must be GEOG, MAGN or MLT. Setting to MLT'
	coords = 'mlt'
endif

;help, north, south, hemisphere

; plot map panel with coast
map_plot_panel, xmaps, ymaps, xmap, ymap, position=position, $
	date=date, time=time, long=long, $
	coords=coords, xrange=xrange, yrange=yrange, $
	no_coast=~keyword_set(coast), no_fill=no_fill, $
	no_axis=keyword_set(cross), coast_linecolor=get_gray(), $
  hemisphere=hemisphere, south=south, north=north,isotropic=isotrpoic, grid_charsize = 0.65

; overlay original radar data
if keyword_set(orig_fan) then begin
	st_ids = (*(*rad_map_data[int_hemi]).gvecs[index])[*].st_id
	if n_elements(st_ids) gt 0 then begin
		if keyword_set(merge) then begin
			vecs = rad_map_calc_merge_vecs(int_hemi, index, indeces=indeces)
			st_ids = reform(st_ids[indeces], n_elements(indeces))
		endif
		orig_ids = st_ids[uniq(st_ids, sort(st_ids))]
		if keyword_set(fan_radar_ids) then begin
			for i=0, n_elements(fan_radar_ids)-1 do begin
				dd = where(orig_ids eq fan_radar_ids[i], cc)
				if cc gt 0l then begin
					if n_elements(inx) eq 0 then $
						inx = dd $
					else $
						inx = [inx, dd]
				endif
			endfor
			if n_elements(inx) gt 0 then $
				orig_ids = orig_ids[inx] $
			else $
				orig_ids = -1
		endif
		if orig_ids[0] ne -1 then begin
			nscale = .5*[-scale[1], scale[1]]
			sfjul, date, time, jul
			rad_map_overlay_scan, orig_ids, jul, scale=nscale, coords=coords, $
				param='velocity', /fov, rad_sct_flg_val = rad_sct_flg_val
		endif
	endif
endif

; overlay potential contours
if keyword_set(potential) then $
	mapex_contours, date=date, time=time, long=long, $
		index=index, north=north, south=south, hemisphere=hemisphere, $
		coords=coords, thick=2, fill=fill

; overlay the Hepner-Maynard boundary

if ( ~keyword_set( noOverlayHMB ) ) then begin

mapex_hm_boundary, date=date, time=time, long=long, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, thick=2

endif	
	
; overlay velocity vectors
if keyword_set(vectors) then $
	mapex_vectors, date=date, time=time, long=long, $
		index=index, north=north, south=south, hemisphere=hemisphere, $
		coords=coords, scale=scale, ignore_bnd=ignore_bnd, $
		model=model, merge=merge, true=true, los=los, grad=grad, $
		symsize=symsize, thick=thick, radar_ids=vec_radar_ids, no_fov_names = no_fov_names

if keyword_set(efield) then $
	rad_map_overlay_efield, date=date, time=time, long=long, $
		index=index, north=north, south=south, hemisphere=hemisphere, $
		coords=coords, thick=2, fill=fill, $
		comp_east_west=comp_east_west, comp_north_south=comp_north_south




	sfjul, date, time, jul_curr
caldat,jul_curr, year_var, mon_var, dd_var, hh_var, mm_var, sec_var

Mg_crd_CBB=cnvcoord( 69.123, 254.96, 350. )
mlt_crd_CBB = mlt( year_var, timeymdhmstoyrsec(year_var, mon_var, dd_var, hh_var, mm_var, sec_var), Mg_crd_CBB[1] )
stereo_crd_CBB = calc_stereo_coords( Mg_crd_CBB[0] , mlt_crd_CBB , mlt = !true )
oplot, [ stereo_crd_CBB[0] ], [ stereo_crd_CBB[1] ], psym = 8, symsize = 0.5, thick = 2.5, color = get_black()
oplot, [ stereo_crd_CBB[0] ], [ stereo_crd_CBB[1] ], psym = 1, symsize = 1., thick = 4.5, color = get_black()
xyouts, stereo_crd_CBB[0]+2., stereo_crd_CBB[1], 'CBB', charsize='0.5', charthick=2

Mg_crd_LYR=cnvcoord( 78.20, 15.82, 350. )
mlt_crd_LYR = mlt( year_var, timeymdhmstoyrsec(year_var, mon_var, dd_var, hh_var, mm_var, sec_var), Mg_crd_LYR[1] )
stereo_crd_LYR = calc_stereo_coords( Mg_crd_LYR[0] , mlt_crd_LYR , mlt = !true )
oplot, [ stereo_crd_LYR[0] ], [ stereo_crd_LYR[1] ], psym = 8, symsize = 0.5, thick = 2.5, color = get_black()
oplot, [ stereo_crd_LYR[0] ], [ stereo_crd_LYR[1] ], psym = 1, symsize = 1., thick = 4.5, color = get_black()
xyouts, stereo_crd_LYR[0]+2., stereo_crd_LYR[1], 'LYR', charsize='0.5', charthick=2


		
end
