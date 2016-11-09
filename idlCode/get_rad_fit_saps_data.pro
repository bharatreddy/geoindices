pro get_rad_fit_saps_data;;, date, time, radId


common rad_data_blk
common radarinfo

date = 20120618
time = 0245
radId = 207
coords = "mlt"


;; get the radar name from id
radInd = where(network[*].id[0] eq radId, cc)
if cc lt 1 then begin
	print, ' Radar not in SuperDARN list: '+radar
	rad_fit_set_data_index, data_index-1
	return
endif
radCode = network[radInd].code[0]

print, "radId, radCode--> ", radId, " ", radCode


rad_fit_read, date, radCode

;; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then begin
	print, "data index is -1!!!"
	return
endif

;; get juls from date and time given
sfjul, date, time, jul
;; get year and yearsec from jul
caldat, jul, mm, dd, year
yrsec = (jul-julday(1,1,year,0,0,0))*86400.d

;; get scan info
scan_number = rad_fit_find_scan(jul)
varr = rad_fit_get_scan(scan_number, scan_startjul=jul)

print, "(*rad_fit_data[data_index]).scan_id", (*rad_fit_data[data_index]).scan_id, (*rad_fit_data[data_index]).channel

;; get mlat, mlon info from fovs
scan_beams = WHERE((*rad_fit_data[data_index]).beam_scan EQ scan_number and $
			(*rad_fit_data[data_index]).channel eq (*rad_fit_info[data_index]).channels[0], $
			no_scan_beams)

rad_define_beams, (*rad_fit_info[data_index]).id, (*rad_fit_info[data_index]).nbeams, $
		(*rad_fit_info[data_index]).ngates, year, yrsec, coords=coords, $
		lagfr0=(*rad_fit_data[data_index]).lagfr[scan_beams[0]], $
		smsep0=(*rad_fit_data[data_index]).smsep[scan_beams[0]], $
		fov_loc_full=fov_loc_full, fov_loc_center=fov_loc_center


mlatArr = (*rad_fit_info[data_index]).mlat
mlonArr = (*rad_fit_info[data_index]).mlon
mltArr = mlt(year, yrsec, mlonArr)

;; get the data
sz = size(varr, /dim)
radar_beams = sz[0]
radar_gates = sz[1]

; loop through and extract
for b=0, radar_beams-1 do begin
	for r=0, radar_gates-1 do begin
		if varr[b,r] NE 10000 then begin
			currLat = fov_loc_center[0,b,r]
			currMLT = fov_loc_center[1,b,r]
			print, "beam, gate, vel--->", b, "-->", r, "--->", varr[b,r], "lat, mlt-->", currLat, ", ", currMLT
		endif
	endfor
endfor


end