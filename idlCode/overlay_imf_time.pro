PRO overlay_imf_time, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	gap=gap, position=position, panel_position=panel_position, $
	hemisphere=hemisphere, north=north, south=south, $
	int_hemisphere=int_hemisphere, index=index, $
	imf=imf, size=size, thick=thick, $
	lag_time=lag_time, charsize=charsize, $
	color=color, scale=scale

common rad_data_blk

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
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
if ~keyword_set(int_hemisphere) then $
	int_hemisphere = (hemisphere lt 0)

if n_elements(index) gt 0 then begin

	sfjul, date, time, (*rad_map_data[int_hemisphere]).mjuls[index], /jul_to_date
	parse_date, date, year, month, day
	sfjul, date, time, jul
	
endif else begin

	if ~keyword_set(date) then begin
		if ~keyword_set(silent) then $
			prinfo, 'No DATE given, trying for scan date.'
		caldat, (*rad_map_data[int_hemisphere]).sjuls[0], month, day, year
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
	if n_elements(index) eq 0 then $
		dd = min( abs( (*rad_map_data[int_hemisphere]).mjuls-jul ), index) $
	else $
		dd = 0.

endelse

if ~keyword_set(panel_position) then $
	panel_position = define_panel(xmaps, ymaps, xmap, ymap, /square)

if ~keyword_set(size) then $
	size = .15*(panel_position[2]-panel_position[0])

if ~keyword_set(position) then $
	position = define_imfpanel(panel_position, gap=gap, size=size)

if ~keyword_set(imf) then begin
	if n_elements(index) lt 1 then begin
		prinfo, 'I have no idea from what time to take the IMF. I am guessing the first.'
		index = 0
	endif
	if n_elements(int_hemisphere) lt 1 then $
		int_hemisphere = 0
	imf = reform((*rad_map_data[int_hemisphere]).b_imf[index,1:2])
	
	if (abs(imf[0]) gt 100.) then imf[0] = 0.
	if (abs(imf[1]) gt 100.) then imf[1] = 0.

	
endif


if ~keyword_set(scale) then begin

	imf_max_range_val = max([abs(imf[0]),abs(imf[1])])
	
	if (imf_max_range_val lt 5.) then scale = [-5,5]
	
	if ((imf_max_range_val ge 5.) and (imf_max_range_val lt 10.)) then scale = [-10,10]
	
	if ((imf_max_range_val ge 10.) and (imf_max_range_val lt 20.)) then scale = [-20,20]

	if ((imf_max_range_val ge 20.) and (imf_max_range_val lt 30.)) then scale = [-30,30]
	
	if (imf_max_range_val ge 30.) then scale = [-35,35]
	
endif
range = scale[1]-scale[0]



if ~keyword_set(lag_time) then begin
	if n_elements(index) lt 1 then begin
		prinfo, 'I have no idea from what time to take the IMF. I am guessing the first.'
		index = 0
	endif
	if n_elements(int_hemisphere) lt 1 then $
		int_hemisphere = 0
	lag_time = (*rad_map_data[int_hemisphere]).imf_delay[index]
endif

if ~keyword_set(color) then $
	color = 253

if ~keyword_set(thick) then $
	thick = 1

if ~keyword_set(charsize) then $
	charsize = 0.4

gray = get_gray()




; plot coordinate system without axis
plot, [0,0], /nodata, position=position, xstyle=5, ystyle=5, $
	xrange=scale, yrange=scale
; plot cross
oplot, [0,0], !y.crange, color=get_black()
oplot, !x.crange, [0,0], color=get_black()
; make some tickmarks
for i=scale[0], scale[1] do begin
	oplot, [i,i], [0, -.02*range], color=gray
	oplot, [0,.02*range], [i,i], color=gray


endfor


; draw IMF vector
arrow, 0, 0, imf[0], imf[1], /data, color=color, $
	hthick=thick, thick=3., hsize=300./(1.+(!d.name eq 'X')*64.)*charsize

; oplot, [0, 0], [imf[0], imf[1]], color=get_red()



	
; label axes
xyouts, .1*range, scale[1], '+Z ('+strtrim(string(scale[1]),2)+' nT)', $
	charsize=charsize, alignment=0.0, color=color
xyouts, scale[1], -.1*range, '+Y', $
	charsize=charsize, alignment=0.0, color=color

; tell about delay
xyouts, (position[2]+position[0])/2., position[1]-.05*charsize*(position[3]-position[1])-.01*get_charsize(xmaps,ymaps), $
	'OMNI IMF', /norm, $
  charsize=charsize, alignment=0.5, color=color
;; tell about model  
 
 
 xyouts, (position[2]+position[0])/2., position[1]-0.5*charsize*(position[3]-position[1])-.01*get_charsize(xmaps,ymaps), $ 
 	'Stat Mod: RG96 !C'+(*rad_map_data[int_hemisphere]).imf_model[index], /norm, $
  charsize=charsize, alignment=0.5, color=color





; tell about delay
;xyouts, (position[2]+position[0])/2., position[1]-.3*charsize*(position[3]-position[1])-3.*.01*get_charsize(xmaps,ymaps), $
;xyouts, 0., scale[0]-charsize, $
;	'('+(*rad_map_data[int_hemisphere]).imf_model[index]+')', /norm, $
;  charsize=charsize, alignment=0.5, color=color

END
