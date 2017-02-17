PRO mapex_hm_boundary, date=date, time=time, long=long, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, color=color, thick=thick, linestyle=linestyle, $
	silent=silent, rotate=rotate
;;PRO overlay_hm_boundary
;;----------------------------------------------------------------------------------------
;;overlays the Hepner-Maynard convection boundary on any current mlat-MLT plot

common rad_data_blk
common recent_panel

; set some default input
if ~keyword_set(thick) then $
	thick = 1

if n_elements(color) eq 0 then $
	color = 120

if n_elements(linestyle) eq 0 then $
	linestyle = 2

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
	dd = min( abs( (*rad_map_data[int_hemi]).mjuls-jul ), index)

	; check if time ditance is not too big
	if dd*1440.d gt 60. then $
		prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

endelse

; get boundary data
bnd = (*(*rad_map_data[int_hemi]).bvecs[index])
num_bnd = (*rad_map_data[int_hemi]).bndnum[index]

; get longitude shift
lon_shft = (*rad_map_data[int_hemi]).lon_shft[index]

utsec = (jul - julday(1, 1, year, 0, 0))*86400.d
; calculate lon_shft, i.e. shift magnetic longitude into mlt coordinates
if coords eq 'mlt' then begin
	lon_shft += mlt(year, utsec, 0.)*15.
	lons = ((bnd[*].lon+lon_shft)/15.) mod 24.
endif else $
	lons = (bnd[*].lon+lon_shft)

IF bnd[0].lat LT -999 THEN $
	prinfo, 'No H-M boundary data exists in Map file' $
ELSE BEGIN
	tmp = calc_stereo_coords(bnd[*].lat, lons, mlt=(coords eq 'mlt'))
	
	if n_elements(rotate) ne 0 then begin
		for ii=0,n_elements(tmp[0,*])-1 do begin
			_x1 = cos(rotate*!dtor)*tmp[0,ii] - sin(rotate*!dtor)*tmp[1,ii]
			_y1 = sin(rotate*!dtor)*tmp[0,ii] + cos(rotate*!dtor)*tmp[1,ii]
			tmp[0,ii] = _x1
			tmp[1,ii] = _y1
		endfor
	endif
	
	bnd_x = tmp[0,*]
	bnd_y = tmp[1,*]
	oplot, bnd_x, bnd_y, thick=thick, color=get_foreground()
	oplot, bnd_x, bnd_y, color=color, thick=thick, linestyle=linestyle
endelse

lat_hm = MIN(bnd[*].lat,/ABSOLUTE)

if lat_hm lt 0. then $
	loc_factor_xloc = 0.015 $
else $
	loc_factor_xloc = 0.03

xyouts, !x.crange[1]-loc_factor_xloc*(!x.crange[1]-!x.crange[0]), !y.crange[0]+.075*(!y.crange[1]-!y.crange[0]), $
	textoidl('\Lambda_{HM} = '+( lat_hm lt 0. ? '-' : '' )+string(abs(lat_hm),format='(I2)')+'\circ'), $
	align=1, charsize=.65
	
	
END




