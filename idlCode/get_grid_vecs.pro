pro get_grid_vecs

common rad_data_blk
common radarinfo

hemisphere=1
int_hemi = (hemisphere lt 0)

inpSapsDatFn = "../../data/data_for_grid.txt"
outGridFile = "../../gridVecs.txt"

;; read dates from file
nel_arr_all = 200000
sapsDateArr = lonarr(nel_arr_all)
sapsRadIdArr = fltarr(nel_arr_all)
sapsTimeArr = intarr(nel_arr_all)
sapsLatArr = fltarr(nel_arr_all)
sapsMLTArr = fltarr(nel_arr_all)


saps_dates_chk = dblarr(1)
saps_hour_chk = fltarr(1)
sapsLat_chk = fltarr(1)
sapsMLT_chk = fltarr(1)
sapsVel_chk = fltarr(1)
radId_chk = fltarr(1)
poesLat_chk = fltarr(1)
poesMLT_chk = fltarr(1)
dst_date_chk = fltarr(1)
dst_index_chk = fltarr(1)
time_chk = intarr(1)

rcnt=0.d
OPENR, 1, inpSapsDatFn
WHILE not eof(1) do begin
    READF,1,saps_dates_chk, sapsLat_chk, sapsMLT_chk, radId_chk, time_chk

    sapsDateArr[rcnt] = ulong(saps_dates_chk)

    sapsRadIdArr[rcnt] = radId_chk

    
    sapsTimeArr[rcnt] = uint(time_chk)
    
    sapsLatArr[rcnt] = sapsLat_chk
    sapsMLTArr[rcnt] = sapsMLT_chk    

    rcnt=rcnt+1   
ENDWHILE         
close,1

sapsDateArr = sapsDateArr[0:rcnt-1]
sapsRadIdArr = sapsRadIdArr[0:rcnt-1]
sapsTimeArr = sapsTimeArr[0:rcnt-1]
sapsLatArr = sapsLatArr[0:rcnt-1]
sapsMLTArr = sapsMLTArr[0:rcnt-1]

countGridVals = 0.
countLatRadLost = 0.
countMLTLost = 0.

openw, 1, outGridFile

for dtRdCnt=0.d,double(rcnt-1) do begin


	countGridVals += 1.

 	currSapsDate = sapsDateArr[dtRdCnt]
 	currSapsTime = sapsTimeArr[dtRdCnt]
 	currSapsRadid = sapsRadIdArr[dtRdCnt]
 	currSapsLat = sapsLatArr[dtRdCnt]
 	currSapsMLT = sapsMLTArr[dtRdCnt]

	print, "working with --->", currSapsDate, currSapsTime, currSapsRadid, currSapsLat, currSapsMLT
	;; read grid velocity data only if it is not loaded
	dloaded = rad_grd_check_loaded(currSapsDate, hemisphere)
	if dloaded eq 0 then begin
		rad_grd_read, currSapsDate
	endif

	sfjul, currSapsDate, currSapsTime, currSapsJul
	; calculate index from date and time
	dd = min( abs( (*rad_grd_data[int_hemi]).mjuls-currSapsJul ), index)
	vecs = rad_grd_get_vecs(int_hemi, index)
	real_nvec  = (*rad_grd_data[int_hemi]).vcnum[index]
	st_ids     = (*(*rad_grd_data[int_hemi]).gvecs[index])[*].st_id
	ncols = 5
	vdata = make_array(ncols, real_nvec>1, /float, value=-9999.9)
	npdat = real_nvec

	IF real_nvec GT 0 THEN BEGIN
		vdata[0:1, 0:real_nvec-1] = vecs.real.pos
		vdata[2:3, 0:real_nvec-1] = vecs.real.vectors
		vdata[4, 0:real_nvec-1]   = st_ids
	ENDIF

	;vdata(0,*)=gmlat  vdata(1,*)=gmlong  vdata(2,*)=magnitude  vdata(3,*)=azimuth  vdata(4,*)=radar_id

	allGrdDataMlat = vdata[0,*]
	allGrdDataMlon = vdata[1,*]
	allGrdDataVmagn = vdata[2,*]
	allGrdDataVazim = vdata[3,*]
	allGrdDataRadId = vdata[4,*]

	;; get the required lat and radarId
	jindsLatRad = where( ( allGrdDataMlat eq currSapsLat ) and ( allGrdDataRadId eq currSapsRadid ) )
	;print, "jindsLatRad-->", jindsLatRad
	if (jindsLatRad[0] eq -1) then begin
		countLatRadLost += 1.		
		continue
	endif
	latRadGrdMlon = allGrdDataMlon[jindsLatRad]
	latRadGrdMlat = allGrdDataMlat[jindsLatRad]
	latRadGrdVmagn = allGrdDataVmagn[jindsLatRad]
	latRadGrdVazim = allGrdDataVazim[jindsLatRad]
	latRadGrdRadid = allGrdDataRadId[jindsLatRad]
	;; need to convert MLON to MLT
	parse_date, currSapsDate, year, month, day
	utsec = (currSapsJul - julday(1, 1, year, 0, 0))*86400.d
	latRadGrdMLTs = fltarr( n_elements(latRadGrdMlon) )
	for mm = 0, n_elements(latRadGrdMlon)-1 do begin
		latRadGrdMLTs[mm] = mlt(year, utsec, latRadGrdMlon[mm])
		;print, latRadGrdMLTs[mm]-currSapsMLT
	endfor
	;print, latRadGrdMlat, latRadGrdRadid, latRadGrdMLTs

	jindsMLT = where( abs(latRadGrdMLTs - currSapsMLT) lt 0.001 )
	if (jindsMLT[0] eq -1) then begin
		countMLTLost += 1.
		continue
	endif
	;jindsMLT = jindsMLT[0]
	mltGrdMlon = latRadGrdMlon[jindsMLT]
	mltGrdMlat = latRadGrdMlat[jindsMLT]
	mltGrdVmagn = latRadGrdVmagn[jindsMLT]
	mltGrdVazim = latRadGrdVazim[jindsMLT]
	mltGrdRadid = latRadGrdRadid[jindsMLT]

	print, mltGrdMlat, mltGrdMlon, mltGrdVmagn, mltGrdVazim, mltGrdRadid, latRadGrdMLTs[jindsMLT]

	printf,1, currSapsDate, currSapsTime, mltGrdMlat, mltGrdMlon, mltGrdVmagn, mltGrdVazim, mltGrdRadid, latRadGrdMLTs[jindsMLT], $
	                                                                format = '(I8, I5, 2f9.4, 2f11.4, I5, f9.4)'
	
	
endfor

close, 1

print, "countGridVals,countLatRadLost, countMLTLost  found!!!!!----->", countGridVals, countLatRadLost, countMLTLost
end