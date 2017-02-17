
pro write_title, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, index=index, int_hemisphere=int_hemisphere, $
	charsize=charsize, charthick=charthick, $
	position=position, silent=silent, no_disclaimer_str = no_disclaimer_str

common rad_data_blk

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if n_elements(int_hemisphere) eq 0 then $
	int_hemisphere = 0

if int_hemisphere eq 0 then $
	str_hemi = 'North' $
else $
	str_hemi = 'South'

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
	sfjul, date, time, jul;, long=long

	; calculate index from date and time
	dd = min( abs( (*rad_map_data[int_hemisphere]).mjuls-jul ), index)
	
	; check if time distance is not too big
	if dd*1440.d gt 60. then $
		prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

endelse

foreground  = get_foreground()



if ~keyword_set(position) then $
	pos = define_panel(xmaps, ymaps, xmap, ymap, /square, /bar) $
else $
	pos = position

fmt = get_format(sardines=sd)
if sd then $
	ypos = pos[3]+0.01 $ ;pos[3]-.03
else $
	ypos = pos[3]+.01

sjul = (*rad_map_data[int_hemisphere]).sjuls[index]
fjul = (*rad_map_data[int_hemisphere]).fjuls[index]


; for j =0,n_elements((*rad_map_data[int_hemisphere]).sjuls)-1 do begin
; 
; 	sfjul, aab, bbb, [ (*rad_map_data[int_hemisphere]).sjuls[j], (*rad_map_data[int_hemisphere]).fjuls[j] ], /jul_to_date
; 	print, 'hiiiiii', aab, bbb
; 	
; 
; endfor
; 
; print, date, time, 'write_title', index
; stop

sdate = format_juldate(sjul, /date)
stime = format_juldate(sjul, /short_time)
ftime = format_juldate(fjul, /short_time)



info_str = sdate+' '+stime+'-'+ftime+' UT'; + $
;	', FitOrder: '+string((*rad_map_data[int_hemisphere]).fit_order[index],format='(I1)') + $
;	', '+(rad_map_info[int_hemisphere].mapex ? 'mapEX' : 'APLmap')+' format'

dsclmr_str='NOTE: FOR PREVIEW PURPOSES ONLY. PLEASE CONTACT VT-SD STAFF FOR VERIFICATION.'

xyouts, pos[0]+0.15, ypos-0.025, $
	info_str, /NORMAL, $
	COLOR=foreground, SIZE=charsize, charthick=4.
	
if ~keyword_set(no_disclaimer_str) then $	
	xyouts, pos[0]-0.02,ypos-0.735, $
		dsclmr_str, /NORMAL, $
		COLOR=foreground, SIZE=0.6, charthick=charthick, ORIENTATION =90.

	
 xyouts, pos[0]+0.57, ypos-0.76, $
 	'Hour (MLT)', /NORMAL, $
 	COLOR=foreground, SIZE=1, charthick=charthick

end
