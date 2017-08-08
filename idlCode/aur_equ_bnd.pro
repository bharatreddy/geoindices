FUNCTION POES_FIT_FUNCT_MLT, X, PAR
  RETURN, PAR[0] + PAR[1]* cos( 2*!pi*(X/24.) + PAR[2] )
END

FUNCTION POES_FIT_FUNCT_MAGN, X, PAR
  RETURN, PAR[0] + PAR[1]* cos( 2*!pi*(X/360.) + PAR[2] )
END

FUNCTION aur_equ_bnd, date, time, coords=coords

common pos_data_blk


; check hemisphere and north and south 
if ~keyword_set(hemisphere) then begin 
	if keyword_set(north) then $ 
		hemisphere = 1. $ 
	else if keyword_set(south) then $ 
		hemisphere = -1. $ 
	else $ 
		hemisphere = 1. 
endif

;; Check and set the latitude and mlt/mlon limits 
if (~keyword_set( mlat_lim )) then begin
	mlat_lim = [50.,90.] 
	print, 'setting MLAT Limits to 50-90'
endif

if (~keyword_set(coords)) then begin
	coords = 'mlt'
	print, 'setting coords to MLT'
endif


if ( coords eq 'mlt' ) then begin
	if ( ~keyword_set(mlon_lim) ) then begin
		mlon_lim = [0., 24.]
		print, 'setting MLT Limits to 0-24'
	endif
endif

if ( coords eq 'magn' ) then begin
	if (~keyword_set(mlon_lim)) then begin
		mlon_lim = [0., 360.]
		print, 'setting MLON Limits to 0-360'
	endif
endif

if ( ~keyword_set( fitline_style ) ) then $ 
	fitline_style = 0
	
if ( ~keyword_set( fitline_thick ) ) then $ 
	fitline_thick = 1
	
if ( ~keyword_set( fitline_color ) ) then $ 
	fitline_color = get_black()




;; we set -0.75 to be the TED value (in log scale) of boundary cutoff --> auroral oval boundary
Oval_bndry_cut_off = -0.75

;; Loop through each of the POES satellites to find files
poes_sats = [ 15, 16, 17, 18, 19 ] ;; These are the current poes files available

;; We begin with assuming each satellite crosses the equatorward boundary of the oval at two locations
;; So we define two arrays each associated with one boundary
oval_bnd_coords1 = fltarr( n_elements(poes_sats), 2 )+1000.
oval_bnd_coords2 = fltarr( n_elements(poes_sats), 2 )+1000.

;; Need to set the time range to search the satellite tracks - I'm setting this to 45 min
sfjul, date, time, jul_poes
jul_range_poes = [jul_poes - 45./1440.d, jul_poes + 45./1440.d] 
sfjul, date_range_poes, time_range_poes, jul_range_poes, /jul_to_date


;; The variable below is used for checking if the time of observations is such that 
;; We are looking for data during 2 days - like when we are searching for a time like 0000 hrs
;; then our search range is 2330 to 0030 over 2 days....so we need an additional array and append them both
is_poes_over_2days = 0


for sats = 0, n_elements(poes_sats)-1 do begin

;; We need to see if POES has data in our time, mlat and mlt range
;; if not we skip to the next step
this_sat_has_data_day1 = 0
this_sat_has_data_day2 = 0

;; In this part we store the POES data....
;; In this part we store the POES data....
;; In this part we store the POES data....
;; In this part we store the POES data....
	sat_num = poes_sats[sats]

;; We need to check if we have two different dates, especially when looking at times close to 0000 UT 
;; In that case we need to oplot each date and take care of the time too....

	if (date_range_poes[0] ne date_range_poes[1]) then begin
		time_plot_poes = [time_range_poes[0],2400]
		time_plot_poes2 = [0000,time_range_poes[1]] 
	endif else begin
		time_plot_poes = time_range_poes
	endelse
	
	
	poes_checkffile = poes_find_files( date_range_poes[0], sat_num, time = time_plot_poes )
	if (poes_checkffile ne '') then begin

		poes_read, date_range_poes[0], sat_num
;;; Set the time range to search for data and store the data into arrays
		sfjul, date_range_poes[0], time_plot_poes, spoes_sjul, fpoes_fjul
		print, sat_num, poes_checkffile
		jinds_poes = where(pos_data.juls ge spoes_sjul and pos_data.juls le fpoes_fjul , cc)
		if ( jinds_poes[0] eq -1 ) then $
			continue
			
			
		poes_mlat = pos_data.mlat[jinds_poes]
		poes_mlt = pos_data.mlt[jinds_poes]
		poes_mlon = pos_data.mlon[jinds_poes]
		poes_ted = pos_data.ted[jinds_poes]
		
		
		
;; Now check if we have data in our search limits.....
;; we need to take care of hemisphere too..




		if (hemisphere eq 1) then $
			jinds_for_poes_data = where( (poes_mlat ge mlat_lim[0]) and (poes_mlat le mlat_lim[1]) and (poes_mlt ge mlon_lim[0]) and (poes_mlt le mlon_lim[1]) ) $
		else $
			jinds_for_poes_data = where( ( poes_mlat lt 0. ) and (abs( poes_mlat ) ge abs( mlat_lim[0]*hemisphere )) and (abs( poes_mlat ) le abs( mlat_lim[1]*hemisphere )) and (poes_mlt ge mlon_lim[0]) and (poes_mlt le mlon_lim[1]) )	
		
		
		if ( jinds_for_poes_data[0] ne -1 ) then begin
			this_sat_has_data_day1 = 1
			poes_mlat_data_arr1 = poes_mlat[jinds_for_poes_data]
			if ( coords eq 'mlt' ) then $
				poes_mlt_data_arr1 = poes_mlt[jinds_for_poes_data] $
			else $
				poes_mlt_data_arr1 = poes_mlon[jinds_for_poes_data]
			
			poes_ted_data_arr1 = alog10( poes_ted[jinds_for_poes_data] )
		
		endif


		
		
		
	endif
	
	

	
	if (date_range_poes[0] ne date_range_poes[1]) then begin
	
		is_poes_over_2days = 1
		
		poes_checkffile = poes_find_files( date_range_poes[1], sat_num, time = time_plot_poes2 )
		if (poes_checkffile ne '') then begin
		
			poes_read, date_range_poes[1], sat_num

;;; Set the time range to search for data and store the data into arrays
			sfjul, date_range_poes[1], time_plot_poes2, spoes_sjul, fpoes_fjul
			jinds_poes = where(pos_data.juls ge spoes_sjul and pos_data.juls le fpoes_fjul , cc)
			if ( jinds_poes[0] eq -1 ) then $
				continue
			
			
			poes_mlat = pos_data.mlat[jinds_poes]
			poes_mlt = pos_data.mlt[jinds_poes]
			poes_mlon = pos_data.mlon[jinds_poes]
			poes_ted = pos_data.ted[jinds_poes]
			
			
;; Now check if we have data in our search limits.....
;; we need to take care of hemisphere too..




			if (hemisphere eq 1) then $
				jinds_for_poes_data = where( (poes_mlat ge mlat_lim[0]) and (poes_mlat le mlat_lim[1]) and (poes_mlt ge mlon_lim[0]) and (poes_mlt le mlon_lim[1]) ) $
			else $                          
				jinds_for_poes_data = where( ( poes_mlat lt 0. ) and (abs( poes_mlat ) ge abs( mlat_lim[0]*hemisphere )) and (abs( poes_mlat ) le abs( mlat_lim[1]*hemisphere )) and (poes_mlt ge mlon_lim[0]) and (poes_mlt le mlon_lim[1]) )	
			
			if ( jinds_for_poes_data[0] ne -1 ) then begin
				this_sat_has_data_day2 = 1
				poes_mlat_data_arr2 = poes_mlat[jinds_for_poes_data]
				if ( coords eq 'mlt' ) then $
					poes_mlt_data_arr2 = poes_mlt[jinds_for_poes_data] $
				else $
					poes_mlt_data_arr2 = poes_mlon[jinds_for_poes_data]
				
				poes_ted_data_arr2 = alog10( poes_ted[jinds_for_poes_data] )
			endif

			
			
		endif	
	
	endif
	
	

	if ( ( this_sat_has_data_day1 eq 1 ) or ( this_sat_has_data_day2 eq 1 ) ) then begin
	
		if ( ( is_poes_over_2days eq 0) and ( this_sat_has_data_day1 eq 1 ) and ( this_sat_has_data_day2 eq 0 ) ) then begin
			poes_mlat_data_arr = poes_mlat_data_arr1
			poes_mlt_data_arr = poes_mlt_data_arr1
			poes_ted_data_arr = poes_ted_data_arr1
		endif 
		
		if ( ( is_poes_over_2days eq 1) and ( this_sat_has_data_day1 eq 0 ) and ( this_sat_has_data_day2 eq 1 ) ) then begin
			poes_mlat_data_arr = poes_mlat_data_arr2
			poes_mlt_data_arr = poes_mlt_data_arr2
			poes_ted_data_arr = poes_ted_data_arr2
		endif
		
		if ( ( is_poes_over_2days eq 1) and ( this_sat_has_data_day1 eq 1 ) and ( this_sat_has_data_day2 eq 1 ) ) then begin
			poes_mlat_data_arr = [ poes_mlat_data_arr1, poes_mlat_data_arr2 ]
			poes_mlt_data_arr = [ poes_mlt_data_arr1, poes_mlt_data_arr1 ]
			poes_ted_data_arr = [ poes_ted_data_arr1, poes_ted_data_arr1 ]			
		endif
		
	endif else begin

		continue

	endelse
	
	
	
;; In this part we store the POES data....
;; In this part we store the POES data....
;; In this part we store the POES data....
;; In this part we store the POES data....


;; Now in this part we identify the boundaries
;; Now in this part we identify the boundaries
;; Now in this part we identify the boundaries
;; Now in this part we identify the boundaries



;; Here we assume satellite observes two equatorward boundaries along its path
;; although it does not necessarily do so....sometimes it might just observe 1 or
;; sometimes it does not observe any.. so we define two variables eq_bnd_cutoff1 and eq_bnd_cutoff2
;; later we check if it indeed does so and define it






	if ( n_elements( poes_ted_data_arr ) gt 0 ) then begin
		;; we set -0.75 to be the value of boundary cutoff
		Jinds_val_high_ted = where ( poes_ted_data_arr gt Oval_bndry_cut_off )
	
		if ( Jinds_val_high_ted[0] ne -1 ) then begin

			poes_hival_mlats = poes_mlat_data_arr[Jinds_val_high_ted]
			poes_hival_mlts = poes_mlt_data_arr[Jinds_val_high_ted]
			poes_hival_teds = poes_ted_data_arr[Jinds_val_high_ted]
			
			eq_bnd_cutoff_mlatarr_ltoh = fltarr( n_elements( poes_hival_mlats ) ) + 1000. ; Making each element 1000. for later use
			eq_bnd_cutoff_mltarr_ltoh = fltarr( n_elements( poes_hival_mlats ) ) + 1000. ; Making each element 1000. for later use
			

			eq_bnd_cutoff_mlatarr_htol = fltarr( n_elements( poes_hival_mlats ) ) + 1000. ; Making each element 1000. for later use
			eq_bnd_cutoff_mltarr_htol = fltarr( n_elements( poes_hival_mlats ) ) + 1000. ; Making each element 1000. for later use	

;; Also need to check if the boundary is equatorward or poleward..
;; When satellite is moving from high-lat to low-lat decrease in flux would mean equatorward boundary
;; When satellite is moving from low-lat to high-lat increase in flux would mean equatorward boundary
;; that is what we are trying to check here

			for aa = 0, n_elements( poes_hival_mlats ) -2 do begin
				
				; check if the satellite is moving from low-lat to high-lat or vice-versa
				
				if ( abs( poes_hival_mlats[aa] ) lt abs( poes_hival_mlats[aa+1] ) ) then begin
				
					if ( poes_hival_teds[aa] lt poes_hival_teds[aa+1] ) then begin
						eq_bnd_cutoff_mlatarr_ltoh[aa] = poes_hival_mlats[aa]
						eq_bnd_cutoff_mltarr_ltoh[aa] = poes_hival_mlts[aa]
					endif
						
				
				endif
				
				if ( abs( poes_hival_mlats[aa] ) gt abs( poes_hival_mlats[aa+1] ) ) then begin
				
					if ( poes_hival_teds[aa] gt poes_hival_teds[aa+1] ) then begin
						eq_bnd_cutoff_mlatarr_htol[aa] = poes_hival_mlats[aa]
						eq_bnd_cutoff_mltarr_htol[aa] = poes_hival_mlts[aa]
					endif
					
				endif
			
			
			endfor
			
			
		
		endif
		
;; Now we looped through the selected satellite data and identified boundaries (if any)
		if ( n_elements(eq_bnd_cutoff_mlatarr_ltoh) gt 0) then begin
			Jinds_eq_bnd_cutoff_val_ltoh = where( abs(eq_bnd_cutoff_mlatarr_ltoh) eq min( abs(eq_bnd_cutoff_mlatarr_ltoh) ) ) ;; The absolute is for southern hemisphere
			;; I chose only 1 element of Jinds because if no bndry is detected then all values are same 1000.
			oval_bnd_coords1[ sats, 0 ] = eq_bnd_cutoff_mlatarr_ltoh[ Jinds_eq_bnd_cutoff_val_ltoh[0] ]
			oval_bnd_coords1[ sats, 1 ] = eq_bnd_cutoff_mltarr_ltoh[ Jinds_eq_bnd_cutoff_val_ltoh[0] ]
		
		endif else begin
			oval_bnd_coords1[ sats, 0 ] = 1000.
			oval_bnd_coords1[ sats, 1 ] = 1000.
		endelse
		
		if ( n_elements(eq_bnd_cutoff_mlatarr_htol) gt 0) then begin
			Jinds_eq_bnd_cutoff_val_htol = where( abs(eq_bnd_cutoff_mlatarr_htol) eq min( abs(eq_bnd_cutoff_mlatarr_htol) ) ) ;; The absolute is for southern hemisphere
			oval_bnd_coords2[ sats, 0 ] = eq_bnd_cutoff_mlatarr_htol[ Jinds_eq_bnd_cutoff_val_htol[0] ]
			oval_bnd_coords2[ sats, 1 ] = eq_bnd_cutoff_mltarr_htol[ Jinds_eq_bnd_cutoff_val_htol[0] ]
		endif else begin
			oval_bnd_coords2[ sats, 0 ] = 1000.
			oval_bnd_coords2[ sats, 1 ] = 1000.
		endelse

		

	endif
	
;; Now in this part we identify the boundaries
;; Now in this part we identify the boundaries
;; Now in this part we identify the boundaries



endfor


;; we have the boundary data, now try the fitting part...
;; we have the boundary data, now try the fitting part...
;; we have the boundary data, now try the fitting part...



;; We need to setup arrays such that we have x and y values for the fit
;; Also we need to setup some kind of error bars/variances
;; Since I need it to be more accurate near midnight and don't mind lesser accuracy near noon
;; I'll putup error bars based on MLT --> I know this is not good...
;; MLTs 19 to 4 -> 1%, MLTs 9 to 15 -> 20%, others -> 1.5%

Jinds_goodvals_bnd1 = where( oval_bnd_coords1[*,0] ne 1000. )
Jinds_goodvals_bnd2 = where( oval_bnd_coords2[*,0] ne 1000. )

;;define the arrays (lats and mlts) that go into the fitting

if ( (Jinds_goodvals_bnd1[0] ne -1) or (Jinds_goodvals_bnd2[0] ne -1) ) then begin

	if ( (Jinds_goodvals_bnd1[0] ne -1) and (Jinds_goodvals_bnd2[0] ne -1) ) then begin
		Lats_into_fit = fltarr( n_elements(Jinds_goodvals_bnd1) + n_elements(Jinds_goodvals_bnd2) )
		Mlts_into_fit = fltarr( n_elements(Jinds_goodvals_bnd1) + n_elements(Jinds_goodvals_bnd2) )
		Errs_into_fit = fltarr( n_elements(Jinds_goodvals_bnd1) + n_elements(Jinds_goodvals_bnd2) )
		
		Count_goodvals = 0

		for kk = 0, n_elements(oval_bnd_coords1[*,0])-1 do begin
			if ( oval_bnd_coords1[ kk,0 ] ne 1000.) then begin
				
				Lats_into_fit[Count_goodvals] = oval_bnd_coords1[ kk,0 ]
				Mlts_into_fit[Count_goodvals] = oval_bnd_coords1[ kk,1 ]
				if ( (oval_bnd_coords1[kk,1] ge 18.) or (oval_bnd_coords1[kk,1] le 4.) ) then $
					Errs_into_fit[Count_goodvals] = 0.03*Lats_into_fit[Count_goodvals] $
				else if ( (oval_bnd_coords1[kk,1] ge 8.) and (oval_bnd_coords1[kk,1] le 16.) ) then $
					Errs_into_fit[Count_goodvals] = 0.15*Lats_into_fit[Count_goodvals] $
				else $
					Errs_into_fit[Count_goodvals] = 0.1*Lats_into_fit[Count_goodvals] 
				
				Count_goodvals = Count_goodvals + 1
			endif
		endfor
		
		
		for kk = 0, n_elements(oval_bnd_coords2[*,0])-1 do begin
			if ( oval_bnd_coords2[ kk,0 ] ne 1000.) then begin
				Lats_into_fit[Count_goodvals] = oval_bnd_coords2[ kk,0 ]
				Mlts_into_fit[Count_goodvals] = oval_bnd_coords2[ kk,1 ]
				if ( (oval_bnd_coords2[kk,1] gt 18.) or (oval_bnd_coords2[kk,1] lt 4.) ) then $
					Errs_into_fit[Count_goodvals] = 0.03*Lats_into_fit[Count_goodvals] $
				else if ( (oval_bnd_coords2[kk,1] gt 9.) and (oval_bnd_coords2[kk,1] lt 15.) ) then $
					Errs_into_fit[Count_goodvals] = 0.15*Lats_into_fit[Count_goodvals] $
				else $
					Errs_into_fit[Count_goodvals] = 0.1*Lats_into_fit[Count_goodvals] 
				
				Count_goodvals = Count_goodvals + 1
			endif
		endfor
		
	endif
	
	if ( (Jinds_goodvals_bnd1[0] ne -1) and (Jinds_goodvals_bnd2[0] eq -1) ) then begin
		Lats_into_fit = fltarr( n_elements(Jinds_goodvals_bnd1) )
		Mlts_into_fit = fltarr( n_elements(Jinds_goodvals_bnd1) )
		Errs_into_fit = fltarr( n_elements(Jinds_goodvals_bnd1) )
		
		
		Count_goodvals = 0
		for kk = 0, n_elements(oval_bnd_coords1[*,0])-1 do begin
			if ( oval_bnd_coords1[ kk,0 ] ne 1000.) then begin
				Lats_into_fit[Count_goodvals] = oval_bnd_coords1[ kk,0 ]
				Mlts_into_fit[Count_goodvals] = oval_bnd_coords1[ kk,1 ]
				if ( (oval_bnd_coords1[kk,1] gt 18.) or (oval_bnd_coords1[kk,1] lt 4.) ) then $
					Errs_into_fit[Count_goodvals] = 0.03*Lats_into_fit[Count_goodvals] $
				else if ( (oval_bnd_coords1[kk,1] gt 9.) and (oval_bnd_coords1[kk,1] lt 15.) ) then $
					Errs_into_fit[Count_goodvals] = 0.15*Lats_into_fit[Count_goodvals] $
				else $
					Errs_into_fit[Count_goodvals] = 0.1*Lats_into_fit[Count_goodvals] 
				
				Count_goodvals = Count_goodvals + 1
			endif
		endfor
	endif
	
	
	if ( (Jinds_goodvals_bnd1[0] eq -1) and (Jinds_goodvals_bnd2[0] ne -1) ) then begin
		Lats_into_fit = fltarr( n_elements(Jinds_goodvals_bnd2) )
		Mlts_into_fit = fltarr( n_elements(Jinds_goodvals_bnd2) )
		Errs_into_fit = fltarr( n_elements(Jinds_goodvals_bnd2) )
		
		Count_goodvals = 0
		for kk = 0, n_elements(oval_bnd_coords2[*,0])-1 do begin
			if ( oval_bnd_coords2[ kk,0 ] ne 1000.) then begin
				Lats_into_fit[Count_goodvals] = oval_bnd_coords2[ kk,0 ]
				Mlts_into_fit[Count_goodvals] = oval_bnd_coords2[ kk,1 ]
				if ( (oval_bnd_coords2[kk,1] gt 18.) or (oval_bnd_coords2[kk,1] lt 4.) ) then $
					Errs_into_fit[Count_goodvals] = 0.03*Lats_into_fit[Count_goodvals] $
				else if ( (oval_bnd_coords2[kk,1] gt 9.) and (oval_bnd_coords2[kk,1] lt 15.) ) then $
					Errs_into_fit[Count_goodvals] = 0.15*Lats_into_fit[Count_goodvals] $
				else $
					Errs_into_fit[Count_goodvals] = 0.1*Lats_into_fit[Count_goodvals]
				
				Count_goodvals = Count_goodvals + 1
			endif
		endfor
	endif
	


;; We have all the data arrays sorted out
;; Now for the real fitting part
;; We'll fit a function for the circle/oval similar to Lasse's Paper on R1/R2 oval - POES_FIT_FUNCT

;; Here on we need to be very careful to take care of different coords.....
;; the fitting functions and other stuff vary depending on coords...
print,'Mlts/Mlats identified-', Mlts_into_fit, Lats_into_fit
	if ( coords eq 'mlt' ) then $
		Fit_Par = mpfitfun( 'POES_FIT_FUNCT_MLT', Mlts_into_fit, Lats_into_fit,  Errs_into_fit, [1,2,3] ) $
	else $
		Fit_Par = mpfitfun( 'POES_FIT_FUNCT_MAGN', Mlts_into_fit, Lats_into_fit,  Errs_into_fit, [1,2,3] )
	
;; we have the boundary data, now try the fitting part...
;; we have the boundary data, now try the fitting part...
;; we have the boundary data, now try the fitting part...

;; our function is -> PAR[0] + PAR[1]* cos( 2*!pi*(X/24) + PAR[2] )

;; Done with the fitting...
;; Check if the fit is succesful and proceed with plotting

	if ( n_elements( Fit_Par ) eq 3 ) then begin
	
		Fitted_Lats = fltarr(24) ; 24 Mlts
		Fitted_Mlts = fltarr(24) ; 24 Mlts
		
		Stereo_Fitted_coords = fltarr(25,2) ; 24 Mlts + last mlt repeats to close the circle
		fitted_data = fltarr(25,2) ; 24 Mlts + last mlt repeats to close the circle
		

		for ml = 0, 23 do begin
			
			if ( coords eq 'mlt' ) then begin
				Lat_outof_fit = ( Fit_Par[0] + Fit_Par[1]* cos( 2*!pi*(ml/24.) + Fit_Par[2] ) )
			endif else begin
				Lat_outof_fit = ( Fit_Par[0] + Fit_Par[1]* cos( 2*!pi*(ml*15./360.) + Fit_Par[2] ) )
			endelse
			
			if ( coords eq 'mlt' ) then $
				Fitted_Mlts[ml] = ml $
			else $
				Fitted_Mlts[ml] = ml*15.
				
			Fitted_Lats[ml] = Lat_outof_fit
			print, coords, Fitted_Mlts[ml], Fitted_Lats[ml]
			if ( coords eq 'mlt' ) then begin
				stereo_lats_mlts_fit = calc_stereo_coords( Lat_outof_fit, ml, /mlt , rotate = map_rotate )
			endif else begin
				stereo_lats_mlts_fit = calc_stereo_coords( Lat_outof_fit, ml*15. , rotate = map_rotate ) 
			endelse
				
			Stereo_Fitted_coords[ml,0] = stereo_lats_mlts_fit[0]
			Stereo_Fitted_coords[ml,1] = stereo_lats_mlts_fit[1]

			fitted_data[ml,0] = Fitted_Lats[ml]
			fitted_data[ml,1] = Fitted_Mlts[ml]
			
		endfor
		
		Stereo_Fitted_coords[24,0] = Stereo_Fitted_coords[0,0]
		Stereo_Fitted_coords[24,1] = Stereo_Fitted_coords[0,1]

		;;oplot, Stereo_Fitted_coords[*,0], Stereo_Fitted_coords[*,1], color = fitline_color, linestyle = fitline_style, thick = fitline_thick
		return, fitted_data
		
		
	endif else begin
		
		print, ' Fitting Failed..'
		return, fltarr(25,2)*0.
		
	endelse

	
endif else begin
print, 'No boundaries identified...could not continue with fitting'
return, fltarr(25,2)*0.
endelse



end
