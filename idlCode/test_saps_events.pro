pro test_saps_events, date_rng

common rad_data_blk

if (~Keyword_set(date_rng)) then begin
	date_rng = [ 20110105, 20110109 ]
endif



time_rng=[0000,1200]

del_skip_time = 30.d
del_juls = del_skip_time/1440.d ;;; This is the time step used to read the data
saps_vel_cutoff = 200.

saps_azim_range = [ -105, -75 ]
int_hemi = 0
coords = 'magn'


dt_skip_time=1440.d ;;; we search data the grd file every 60 min
del_jul=dt_skip_time/1440.d ;;; This is the time step used to read the data --> Selected to be 60 min
sfjul, date_rng, time_rng, sjul_day, fjul_day
ndays_search=((fjul_day-sjul_day)/del_jul)+1 ;; Num of 2-min times to be searched..

;; write data to the file
fname_saps_raw_north = '/home/bharatr/Docs/data/saps-north-2011-2015.txt' 
openw,1,fname_saps_raw_north

for srchDay=0.d,double(ndays_search) do begin

	;;;Calculate the current jul
	juls_day=sjul_day+srchDay*del_jul
    sfjul,dateDay,timeDay,juls_day,/jul_to_date
    print, "date and time sel--->", dateDay,timeDay

    rad_map_read, dateDay
	sfjul, dateDay, time_rng, sjjCurr, fjjCurr
	nele_search=((fjjCurr-sjjCurr)/del_juls)+1 

	for srch=0, double(nele_search)-1 do begin

			jul_curr = sjjCurr + srch*del_juls 

			sfjul, date_curr, time_curr, jul_curr, /jul_to_date
	
			date_curr = date_curr[0]

			fitPOESjul = jul_curr
			; calculate index from date and time
			dd = min( abs( (*rad_map_data[int_hemi]).mjuls-jul_curr ), index)
			
			
			; get longitude shift
			lon_shft = (*rad_map_data[int_hemi]).lon_shft[index]

			parse_date, date_curr, year, month, day
			utsec = (jul_curr - julday(1, 1, year, 0, 0))*86400.d
			; calculate lon_shft, i.e. shift magnetic longitude into mlt coordinates
			if coords eq 'mlt' then $
				lon_shft += mlt(year, utsec, 0.)*15.

			; get boundary data
			bnd = (*(*rad_map_data[int_hemi]).bvecs[index])
			num_bnd = (*rad_map_data[int_hemi]).bndnum[index]
			
			
			real_nvec  = (*rad_map_data[int_hemi]).vcnum[index]
			
			if real_nvec le 0 then begin
				prinfo, 'No data vectors found.'
				continue
			endif
			
			st_ids     = (*(*rad_map_data[int_hemi]).gvecs[index])[*].st_id
			
			ncols = 5 ; We need 5 columns in the array holding our data
			;; We just need the grad vectors
			real = rad_map_calc_grad_vecs(int_hemi, index)
				
			vdata = make_array(ncols, real_nvec, /float, value=-9999.9)
			vdata[0:1, *] = real.pos
			vdata[2:3, *] = real.vectors
			vdata[4, *]   = st_ids


			;; The vdata array now has
			;vdata(0,*)=gmlat  vdata(1,*)=gmlong  vdata(2,*)=magnitude  vdata(3,*)=azimuth  vdata(4,*)=radar_id
			;; we have mlon vals we need mlts
			mlt_vdata = fltarr( n_elements( vdata[1,*] ) )

			caldat,jul_curr, evnt_month, evnt_day, evnt_year, strt_hour, strt_min, strt_sec
			for mm = 0, n_elements( vdata[1,*] )-1 do begin
				mlt_vdata[mm] = mlt( evnt_year, timeymdhmstoyrsec( evnt_year, evnt_month, evnt_day, strt_hour, strt_min, strt_sec ), vdata[1,mm] )		
			endfor

			;; Get the equ. elec. prec bnd data
			if ( ( abs(fitPOESjul -jul_curr) gt 30.d/1440.d) or srch eq 0 ) then begin
				equ_oval_bnd_data_arr = aur_equ_bnd( date_curr, time_curr )
				fitPOESjul = jul_curr
			endif

			if ( equ_oval_bnd_data_arr[0,0] eq 0. ) then begin
				print, "no data in poes!"
				continue
			endif

			saps_check_vel1 = vdata[2,*]
			saps_check_lat1 = vdata[0,*]
			saps_check_mlt1 = mlt_vdata[*]
			saps_check_azim1 = vdata[3,*]
			
			poesMLTLoopSize = size(equ_oval_bnd_data_arr)
			for mltLoopPntr = 0, poesMLTLoopSize[1]-1 do begin
				print, "n elemnts mlt search-->", poesMLTLoopSize, poesMLTLoopSize[1], equ_oval_bnd_data_arr[mltLoopPntr,*]
			endfor

			saps_Lats_this_mlt = saps_check_lat1
			saps_Mlts_this_mlt = saps_check_mlt1
			saps_Vels_this_mlt = saps_check_vel1
			saps_Azims_this_mlt = saps_check_azim1
			
		
			POS_eq_eloval_bnd_this_mlt = equ_oval_bnd_data_arr
			
			;print, "POES data--->", equ_oval_bnd_data_arr
			;print, "POES data MLT SEL--->", equ_oval_bnd_data_arr[0,*] ;; [lat,mlt]

			;print, "saps_Mlts_this_mlt---->", saps_Mlts_this_mlt
			;print, "saps_Lats_this_mlt---->", saps_Lats_this_mlt
			;print, "saps_Vels_this_mlt---->", saps_Vels_this_mlt
		
		

	endfor
	

endfor

end
