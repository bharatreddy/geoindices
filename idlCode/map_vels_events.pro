pro map_vels_events, date, time

common rad_data_blk


int_hemi = 0
coords = 'magn'


;; write data to the file
fname_vels = '/home/bharatr/Docs/data/map-vels-' + strtrim( string(date), 2 ) + '-' + strtrim( string(time), 2 ) + '.txt' 
openw,1,fname_vels


    sfjul,date,time,jul_curr

    rad_map_read, date


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

			

			saps_check_vel1 = vdata[2,*]
			saps_check_lat1 = vdata[0,*]
			saps_check_mlt1 = mlt_vdata[*]
			saps_check_azim1 = vdata[3,*]
			

			saps_Lats_this_mlt = saps_check_lat1
			saps_Mlts_this_mlt = saps_check_mlt1
			saps_Vels_this_mlt = saps_check_vel1
			saps_Azims_this_mlt = saps_check_azim1
			
		
		
			Final_SAPS_Lats = saps_Lats_this_mlt
			Final_SAPS_Mlts = saps_Mlts_this_mlt
			Final_SAPS_Vels = saps_Vels_this_mlt
			
			for fsp = 0, n_elements(Final_SAPS_Lats)-1 do begin
				print, "SAPS --> lats, mlt, vel, eprlat", date_curr, time_curr, Final_SAPS_Lats[fsp], Final_SAPS_Mlts[fsp], Final_SAPS_Vels[fsp]
				printf,1, date_curr, time_curr, Final_SAPS_Lats[fsp], Final_SAPS_Mlts[fsp], Final_SAPS_Vels[fsp], $
                                                            format = '(I8, I5, 3f11.4)'
			endfor
			
		
close,1

end