pro test_saps_events, date_rng

common rad_data_blk

if (~Keyword_set(date_rng)) then begin
	date_rng = [ 20110101, 20120831 ]
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
fname_saps_raw_north = '/home/bharatr/Docs/data/rawsaps-north-2011-2012.txt' 
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

			equ_oval_bnd_data_arr = aur_equ_bnd( date_curr, time_curr )

			;; Get the equ. elec. prec bnd data
			;;if ( ( abs(fitPOESjul -jul_curr) gt 30.d/1440.d) or srch eq 0 ) then begin
				;;equ_oval_bnd_data_arr = aur_equ_bnd( date_curr, time_curr )
				;;fitPOESjul = jul_curr
			;;endif

			if ( equ_oval_bnd_data_arr[0,0] eq 0. ) then begin
				print, "no data in poes!"
				continue
			endif

			saps_check_vel1 = vdata[2,*]
			saps_check_lat1 = vdata[0,*]
			saps_check_mlt1 = mlt_vdata[*]
			saps_check_azim1 = vdata[3,*]
			saps_check_st_ids = vdata[4,*]
			
			poesMLTLoopSize = size(equ_oval_bnd_data_arr)
			for mltLoopPntr = 0, poesMLTLoopSize[1]-1 do begin

				;; sometimes we get 0 in lats, skip those vals
				if ( equ_oval_bnd_data_arr[mltLoopPntr,0] eq 0. ) then begin
					continue
				endif

				;print, "n elemnts mlt search-->", equ_oval_bnd_data_arr[mltLoopPntr,*]
				;; get the corresponding MLT from SD data

				Jinds_curr_mlt_POES_SD = where( round(saps_check_mlt1) eq equ_oval_bnd_data_arr[mltLoopPntr,1] )

				if (Jinds_curr_mlt_POES_SD[0] eq -1 ) then begin
					;print, "no mlt match found for saps and poes-->", equ_oval_bnd_data_arr[mltLoopPntr,*]
					continue;
				endif

				saps_Lats_this_mlt = saps_check_lat1[Jinds_curr_mlt_POES_SD]
				saps_Mlts_this_mlt = saps_check_mlt1[Jinds_curr_mlt_POES_SD]
				saps_Vels_this_mlt = saps_check_vel1[Jinds_curr_mlt_POES_SD]
				saps_Azims_this_mlt = saps_check_azim1[Jinds_curr_mlt_POES_SD]
				saps_station_ids = saps_check_st_ids[Jinds_curr_mlt_POES_SD]

				POS_eq_eloval_bnd_this_mlt = equ_oval_bnd_data_arr[mltLoopPntr,*]

				Jinds_Final_SAPS_scatter = where( ( saps_Azims_this_mlt gt saps_azim_range[0] and saps_Azims_this_mlt lt saps_azim_range[1] ) and $
							( saps_Lats_this_mlt lt POS_eq_eloval_bnd_this_mlt[0] and saps_Lats_this_mlt lt 65. ) and $
							( saps_Vels_this_mlt gt saps_vel_cutoff ) )
			
				;; Now calculate the stuff we need
				if (Jinds_Final_SAPS_scatter[0] ne -1 ) then begin
					Final_SAPS_Lats = saps_Lats_this_mlt[ Jinds_Final_SAPS_scatter ]
					Final_SAPS_Mlts = saps_Mlts_this_mlt[ Jinds_Final_SAPS_scatter ]
					Final_SAPS_Vels = saps_Vels_this_mlt[ Jinds_Final_SAPS_scatter ]
					Final_SAPS_Stations = saps_station_ids[ Jinds_Final_SAPS_scatter ]
					Final_EPR_lat = POS_eq_eloval_bnd_this_mlt[0]
					
					for fsp = 0, n_elements(Final_SAPS_Lats)-1 do begin
						print, "SAPS --> lats, mlt, vel, eprlat", date_curr, time_curr, Final_SAPS_Lats[fsp], Final_SAPS_Mlts[fsp], Final_SAPS_Vels[fsp], POS_eq_eloval_bnd_this_mlt, Final_SAPS_Stations[fsp]
						printf,1, date_curr, time_curr, Final_SAPS_Lats[fsp], Final_SAPS_Mlts[fsp], Final_SAPS_Vels[fsp], Final_SAPS_Stations[fsp], POS_eq_eloval_bnd_this_mlt[0],POS_eq_eloval_bnd_this_mlt[1], $
	                                                                format = '(I8, I5, 2f9.4, f11.4, f9.4, 2f9.4)'
					endfor
					
				endif else begin
					;print, "no lat lon found 1"
					continue
				endelse

			endfor


	endfor
	

endfor

end
