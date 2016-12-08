pro amp_current, date=date, time=time, long=long, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, scale=scale, min_value=min_value, $
	n_levels=n_levels, $
	thick=thick, neg_linestyle=neg_linestyle, pos_linestyle=pos_linestyle, $
	neg_color=neg_color, pos_color=pos_color, $
	c_charsize=c_charsize, c_charthick=c_charthick, $
	silent=silent, fill=fill, c_thick=c_thick

common amp_data_blk
common recent_panel

; get color preferences
foreground  = get_foreground()
ncolors     = get_ncolors()
bottom      = get_bottom()

; set some default input
if ~keyword_set(thick) then $
	thick = !p.thick

if n_elements(neg_linestyle) eq 0 then $
	neg_linestyle = 0

if n_elements(pos_linestyle) eq 0 then $
	pos_linestyle = 5

if ~keyword_set(scale) then begin
	scale = [-1.6,1.6]
endif

if ~keyword_set(min_value) then begin
	min_value = 0.2
endif

if ~keyword_set(n_levels) then begin
	n_levels = 7
endif

if n_elements(neg_color) eq 0 and n_elements(pos_color) eq 0 then begin
	ctname = get_colortable()
	rad_load_colortable, /bluewhitered
	ncol2 = ncolors/2
	neg_color = round((1.-findgen(n_levels+1)/(n_levels))*ncol2) + bottom
	neg_color[0] -= 7
	pos_color = round(findgen(n_levels+1)/(n_levels)*(ncol2-1)) + ncol2 + bottom + 1
	pos_color[0] += 7
	reset_colorbar = 1
endif else begin
	if n_elements(neg_color) eq 0 then $
		neg_color = get_blue()
	if n_elements(pos_color) eq 0 then $
		pos_color = get_red()
endelse

npos_color = n_elements(pos_color)
if npos_color ne n_levels+1 then begin
	if npos_color gt 1 then $
		prinfo, 'Number of positive colors not equal to N_LEVELS+1 or 1, choosing first.'
	pos_color = replicate(pos_color[0], n_levels+1)
endif

nneg_color = n_elements(neg_color)
if nneg_color ne n_levels+1 then begin
	if nneg_color gt 1 then $
		prinfo, 'Number of negative colors not equal to N_LEVELS+1 or 1, choosing first.'
	neg_color = replicate(neg_color[0], n_levels+1)
endif

if ~keyword_set(c_charsize) then $
	c_charsize = get_charsize(rxmaps, rymaps)

if ~keyword_set(c_thick) then $
	c_thick = 1.

if ~keyword_set(c_charthick) then $
	c_charthick = !p.charthick

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~strcmp(coords, 'mlt',/fold) and ~strcmp(coords, 'magn',/fold) then begin
	prinfo, 'Coordinate system must be MLT or MAGN. Setting to MLT'
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

if amp_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if n_elements(index) gt 0 then begin

	sfjul, date, time, (*amp_data[int_hemi]).mjuls[index], /jul_to_date
	parse_date, date, year, month, day
	sfjul, date, time, jul

endif else begin

	if ~keyword_set(date) then begin
		if ~keyword_set(silent) then $
			prinfo, 'No DATE given, trying for map date.'
		caldat, (*amp_data[int_hemi]).sjuls[0], month, day, year
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
	dd = min( abs( (*amp_data[int_hemi]).mjuls-jul ), index)

	; check if time distance is not too big
	if dd*1440.d gt 60. then $
		prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

endelse

if strcmp(coords,'mlt',/fold) then $
	mlt0inmlonh = 0. $
else $
	mlt0inmlonh = -mlt(year,(jul-julday(1,1,year,0))*86400.d,0.)

nlats = (*amp_data[int_hemi]).nlat[index]
nlons = (*amp_data[int_hemi]).nlon[index]
plats = 90.-reform((*amp_data[int_hemi]).colat[index, *])
plons = ( reform((*amp_data[int_hemi]).mlt[index, *]) + mlt0inmlonh )*(strcmp(coords,'mlt',/fold) ? 1. : 15.)
tmp = calc_stereo_coords(plats, plons, mlt=strcmp(coords,'mlt',/fold))
xxs = fltarr(nlats, nlons+1)
yys = fltarr(nlats, nlons+1)
jrs = fltarr(nlats, nlons+1)
for a=0, nlats-1 do begin
	for b=0, nlons do begin
		xxs[a,b] = tmp[0,(b mod nlons)*nlats+a]
		yys[a,b] = tmp[1,(b mod nlons)*nlats+a]
		jrs[a,b] = abs((*amp_data[int_hemi]).jr[index,(b mod nlons)*nlats+a]) lt min_value ? 0. : (*amp_data[int_hemi]).jr[index,(b mod nlons)*nlats+a]
	endfor
endfor

; overlay contours
; in order to get the filling of the negative contours right, 
; we take minus the current and use the same levels as
; for the positive contours, just in blue
if keyword_set(fill) then begin
	; negative
	contour, -jrs, xxs, yys, $
		/overplot, xstyle=4, ystyle=4, noclip=0, $
		thick=thick, c_linestyle=neg_linestyle, c_color=neg_color, c_charsize=c_charsize, c_charthick=c_charthick, $
		levels=min_value+(-scale[0]-min_value)*findgen(n_levels+1.)/float(n_levels), /follow, $
		path_xy=path_xy, path_info=path_info
	for i = 0, n_elements(path_info) - 1 do begin
		;print, 'neg: ', path_info[i].high_low
		if path_info[i].high_low eq (keyword_set(south)) then $
			continue
		s = [indgen(path_info[i].n), 0]
		; Plot the closed paths:
		polyfill, path_xy[*, path_info[i].offset + s], /norm, color=neg_color[path_info[i].level], noclip=0
	endfor
	; positive
	contour, jrs, xxs, yys, $
		/overplot, xstyle=4, ystyle=4, noclip=0, $
		thick=thick, c_linestyle=pos_linestyle, c_color=pos_color, c_charsize=c_charsize, c_charthick=c_charthick, $
		levels=min_value+(scale[1]-min_value)*findgen(n_levels+1.)/float(n_levels), /follow, $
		path_xy=path_xy, path_info=path_info
	for i = 0, n_elements(path_info) - 1 do begin
		;print, 'pos: ', path_info[i].high_low
		if path_info[i].high_low eq (keyword_set(south)) then $
			continue
		s = [indgen(path_info[i].n), 0]
		; Plot the closed paths:
		polyfill, path_xy[*, path_info[i].offset + s], /norm, color=pos_color[path_info[i].level], noclip=0
	endfor
	neg_levcols = neg_color[n_levels-1]
	pos_levcols = pos_color[n_levels-1]
endif else begin
	neg_levcols = reverse(neg_color)
	pos_levcols = pos_color
	neg_levcols = neg_color[n_levels-1]
	pos_levcols = pos_color[n_levels-1]
endelse

; negative
contour, jrs, xxs, yys, $
	/overplot, xstyle=4, ystyle=4, noclip=0, $
	thick=thick, c_linestyle=neg_linestyle, c_color=neg_levcols, c_charsize=c_charsize, c_charthick=c_charthick, $
	levels=scale[0]+(-scale[0]-min_value)*findgen(n_levels+1.)/float(n_levels), /follow
; positive
contour, jrs, xxs, yys, $
	/overplot, xstyle=4, ystyle=4, noclip=0, $
	thick=thick, c_linestyle=pos_linestyle, c_color=pos_levcols, c_charsize=c_charsize, c_charthick=c_charthick, $
	levels=min_value+(scale[1]-min_value)*findgen(n_levels+1.)/float(n_levels), /follow

if n_elements(reset_colorbar) ne 0 then $
	rad_load_colortable, ctname

end