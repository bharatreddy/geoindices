pro count_npoints_map_pot, date_rng

common rad_data_blk

if (~Keyword_set(date_rng)) then begin
	date_rng = [ 20000101, 20151231 ]
endif



time_rng=[0000,2358]

sfjul,date_rng,time_rng,sjul_search,fjul_search

dt_skip_time=1440.d ;;; we search data the grd file every 60 min
del_jul=dt_skip_time/1440.d ;;; This is the time step used to read the data --> Selected to be 60 min

nele_search=((fjul_search-sjul_search)/del_jul)+1 ;; Num of 2-min times to be searched..


;; write data to the file
fname_count_north='/home/bharatr/Docs/data/data-points-north-2.txt' 
openw,1,fname_count_north

for srch=0.d,double(nele_search-1) do begin

	;;;Calculate the current jul
	juls_curr=sjul_search+srch*del_jul
    sfjul,datesel,timesel,juls_curr,/jul_to_date
    ;;print, datesel, timesel

	;;Now read the gridded data from both hemispheres
	;;Before that check if date is already loaded if so skip reading --> saves time
    rad_grd_check=rad_grd_check_loaded(datesel,1,/silent)
    ;if (rad_grd_check eq 0) then $	
	rad_grd_read,datesel,/north,/silent

	;;get time and count info
	julData = (*rad_grd_data[0]).mjuls
	countNorthArr = (*rad_grd_data[0]).vcnum
	;; loop through julData and get all the values
	for jInd = 0,n_elements(countNorthArr)-1 do begin
		sfjul, dateData, timeData, julData[jInd], /jul_to_date
		print, "NORTH", dateData,timeData, countNorthArr[jInd]
		printf,1, dateData,timeData, countNorthArr[jInd], $
								format = '(I8, 2I5)'
	endfor
	
endfor

close, 1

fname_count_south='/home/bharatr/Docs/data/data-points-south-2.txt' 
openw,1,fname_count_south

for srch=0.d,double(nele_search-1) do begin

	;;;Calculate the current jul
	juls_curr=sjul_search+srch*del_jul
    sfjul,datesel,timesel,juls_curr,/jul_to_date
    ;;print, datesel, timesel

	;;Now read the gridded data from both hemispheres
	;;Before that check if date is already loaded if so skip reading --> saves time
    rad_grd_check=rad_grd_check_loaded(datesel,1,/silent)
    ;if (rad_grd_check eq 0) then $	
	rad_grd_read,datesel,/south,/silent

	;;get time and count info
	julData = (*rad_grd_data[1]).mjuls
	countSouthArr = (*rad_grd_data[1]).vcnum
	;; loop through julData and get all the values
	for jInd = 0,n_elements(countSouthArr)-1 do begin
		sfjul, dateData, timeData, julData[jInd], /jul_to_date
		print, "SOUTH", dateData,timeData, countSouthArr[jInd]
		printf,1, dateData,timeData, countSouthArr[jInd], $
								format = '(I8, 2I5)'
	endfor
	
endfor

close, 1

end
