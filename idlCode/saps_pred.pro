pro saps_pred


load_usersym, /circle

fname_saps='/home/bharat/ESAPS/files/goodCond_saps_2011_2012.txt' 


;format = '(I8, I5, f9.4, 2f10.4, f9.4, f10.4, f9.4, f9.4, f9.4)'

saps_dates_chk = dblarr(1)
saps_times_chk = fltarr(1)
saps_mlts_obs_chk = fltarr(1)
Final_SAPS_Lats_chk = fltarr(1)
Final_SAPS_Vels_chk = fltarr(1)
AE_SAPS_chk = fltarr(1)
Dst_SAPS_chk = fltarr(1)
Kp_SAPS_chk = fltarr(1)
PCND_SAPS_chk = fltarr(1)
HCND_SAPS_chk = fltarr(1)


nel_arr_all = 1000000
SAPS_events_dates = lonarr(nel_arr_all)
SAPS_events_times = intarr(nel_arr_all)
SAPS_orig_Mlts_Final = fltarr(nel_arr_all)
SAPS_Vels_Final_Vals = fltarr(nel_arr_all)
SAPS_orig_lats_Final = fltarr(nel_arr_all)

SAPS_orig_AE_Final = fltarr(nel_arr_all)
SAPS_orig_DST_Final = fltarr(nel_arr_all)
SAPS_orig_KP_Final = fltarr(nel_arr_all)
SAPS_orig_PCOND_Final = fltarr(nel_arr_all)
SAPS_orig_HCOND_Final = fltarr(nel_arr_all)


;;;;Normalizing factors
Norm_DST_val = -300.
Norm_AE_val = 2500.
Norm_KP_val = 9.
Norm_CND_val = 20.
Norm_MLT_val = 10.
Norm_LAT_val = 15.
Norm_VEL_val = 2000.

nv=0.d
OPENR, 1, fname_saps
WHILE not eof(1) do begin
    READF,1,saps_dates_chk, saps_times_chk, saps_mlts_obs_chk, AE_SAPS_chk, Dst_SAPS_chk, Kp_SAPS_chk, Final_SAPS_Vels_chk , Final_SAPS_Lats_chk, PCND_SAPS_chk, HCND_SAPS_chk


    SAPS_events_dates[nv] = ulong(saps_dates_chk)

    SAPS_events_times[nv] = uint(saps_times_chk)
    
    if saps_mlts_obs_chk gt 3. then $
    	saps_mlts_obs_chk = saps_mlts_obs_chk - 18. $
    else $
    	saps_mlts_obs_chk = saps_mlts_obs_chk + 6.
    
    SAPS_orig_Mlts_Final[nv] = saps_mlts_obs_chk/Norm_MLT_val
    
    SAPS_orig_AE_Final[nv] = AE_SAPS_chk/Norm_AE_val
    SAPS_orig_DST_Final[nv] = (Dst_SAPS_chk-50.)/Norm_DST_val
    SAPS_orig_KP_Final[nv] = Kp_SAPS_chk/Norm_KP_val
        
    SAPS_Vels_Final_Vals[nv] = Final_SAPS_Vels_chk/Norm_VEL_val  
    SAPS_orig_lats_Final[nv] = (Final_SAPS_Lats_chk-50.)/Norm_LAT_val
    
    SAPS_orig_PCOND_Final[nv] = PCND_SAPS_chk/Norm_CND_val
    SAPS_orig_HCOND_Final[nv] = HCND_SAPS_chk/Norm_CND_val
    

    nv=nv+1   
ENDWHILE         
close,1



; 	
SAPS_events_dates = SAPS_events_dates[0:nv-1] 
SAPS_events_times = SAPS_events_times[0:nv-1] 
SAPS_orig_Mlts_Final = SAPS_orig_Mlts_Final[0:nv-1] 
SAPS_orig_lats_Final = SAPS_orig_lats_Final[0:nv-1] 
SAPS_Vels_Final_Vals = SAPS_Vels_Final_Vals[0:nv-1]

SAPS_orig_AE_Final = SAPS_orig_AE_Final[0:nv-1]
SAPS_orig_DST_Final = SAPS_orig_DST_Final[0:nv-1]
SAPS_orig_KP_Final = SAPS_orig_KP_Final[0:nv-1]
SAPS_orig_PCOND_Final = SAPS_orig_PCOND_Final[0:nv-1]
SAPS_orig_HCOND_Final = SAPS_orig_HCOND_Final[0:nv-1]




; print, 'min, max - AE', min(SAPS_orig_AE_Final), max(SAPS_orig_AE_Final), 'min, max - Dst', min(SAPS_orig_DST_Final), max(SAPS_orig_DST_Final), 'min, max - Kp', min(SAPS_orig_KP_Final), max(SAPS_orig_KP_Final), $
; 		'min, max - Vel', min(SAPS_Vels_Final_Vals), max(SAPS_Vels_Final_Vals), 'min, max - lat', min(SAPS_orig_lats_Final), max(SAPS_orig_lats_Final), 'min, max - PC', min(SAPS_orig_PCOND_Final), max(SAPS_orig_PCOND_Final), $
; 		'min, max - HCND',min(SAPS_orig_HCOND_Final), max(SAPS_orig_HCOND_Final),'min, max - mlt',min(SAPS_orig_Mlts_Final), max(SAPS_orig_Mlts_Final)  

	
		
		
		
fname_NN_saps1='/home/bharat/NN-S/neuSAPS.txt' 

openw,1,fname_NN_saps1


for jj = 0.d, n_elements(SAPS_orig_DST_Final)-1 do begin


	printf, 1, SAPS_orig_DST_Final[jj], SAPS_orig_AE_Final[jj], SAPS_orig_KP_Final[jj], SAPS_orig_PCOND_Final[jj], $
			SAPS_orig_HCOND_Final[jj], SAPS_orig_Mlts_Final[jj], SAPS_orig_lats_Final[jj], SAPS_Vels_Final_Vals[jj], $
			format = '(f6.4,7f7.4)';'(2f10.4, f9.4, f9.4, f9.4, f9.4, f9.4, f10.4)'

endfor


close,1

ps_open,'/home/bharat/ESAPS/files/model-plots/sapstrend.ps'


plot, SAPS_orig_PCOND_Final, SAPS_orig_lats_Final, psym = 8, symsize = 0.1, pos = define_panel(2,1,0,0), xtitle = 'PedCond', ytitle = 'Lats'

plot, SAPS_orig_PCOND_Final, SAPS_Vels_Final_Vals, psym = 8, symsize = 0.1, pos = define_panel(2,1,1,0), xtitle = 'PedCond', ytitle = 'vels'

ps_close


; ;;;Test Case
; 
; Test_case1_dst = -30.
; Test_case1_dst = ( Test_case1_dst -50. )/ Norm_DST_val
; Test_case1_Ae = 600.
; Test_case1_Ae = Test_case1_Ae / Norm_AE_val
; Test_case1_kp = 4.
; ; Test_case1_kp = Test_case1_kp / Norm_KP_val
; 
; Test_case1_Mlt = [18., 19., 20., 21., 22., 23., 0., 1., 2., 3.]
; ; 
; ; for kk = 0, n_elements(Test_case1_Mlt) -1 do begin
; ; 
; ;     	if Test_case1_Mlt[kk] gt 3. then $
; ;     		Test_case1_Mlt[kk] = Test_case1_Mlt[kk] - 18. $
; ;     	else $
; ;     		Test_case1_Mlt[kk] = Test_case1_Mlt[kk] + 6.
; ; 
; ; endfor
; 
; Test_case1_lat = [51.,52., 53., 54., 55., 56.,57., 58., 59., 60., 61.,62.,63.,64.]
; 
; ; for ll = 0, n_elements(Test_case1_lat) -1 do begin
; ; 
; ; 	Test_case1_lat[ll] = (Test_case1_lat[ll]-50.)/Norm_LAT_val
; ; 
; ; endfor
; 
; Test_case1_PC = fltarr( n_elements(Test_case1_lat) * n_elements(Test_case1_Mlt) )
; Test_case1_HC = fltarr( n_elements(Test_case1_lat) * n_elements(Test_case1_Mlt) )
; 
; Cnt_Cnd = 0
; 
; for kk = 0, n_elements(Test_case1_Mlt) -1 do begin
; 	for ll = 0, n_elements(Test_case1_lat) -1 do begin
; 		Test_date = 20130214
; 		Test_time = 0400
; 		sfjul, Test_date, Test_time, condJul
; 		
; 		for mm = 1., 360. do begin
; 		
; 			caldat, condJul, mon, day, year
; 			yrsec = (condJul-julday(1,1,year,0,0,0))*86400.d
; 			Condmlt_chk = mlt(year, yrsec, mm)
; 			
; 			if ( abs(Condmlt_chk - Test_case1_Mlt[kk]) le 0.1 ) then $
; 				CondMlon_chk = mm
; 		
; 		endfor
; 		
; 		Gcrd = cnvcoord( Test_case1_lat[ll], CondMlon_chk, 200., /geo )
; 		ionos_calc_sig, Test_date, Test_time, Gcrd[0], Gcrd[1], Isig1 = Cond_IRI_Ped, Isig2 = Cond_IRI_Hal
; 
; 		;; Cond due to elec. prec. from Hardy model....DMSP
; 		Cond_Ep_Ped = calc_cond_ep(Test_date, Test_time, Test_case1_kp, 2)
; 		Cond_Ep_Hal = calc_cond_ep(Test_date, Test_time, Test_case1_kp, 1)
; 		
; 		Test_case1_PC[Cnt_Cnd] = ( Cond_Ep_Ped + Cond_IRI_Ped ) /Norm_CND_val
; 		Test_case1_HC[Cnt_Cnd] = ( Cond_Ep_Hal + Cond_IRI_Hal ) /Norm_CND_val
; 		
; 		if Test_case1_Mlt[kk] gt 3. then $
;     			Test_case1_Mlt[kk] = Test_case1_Mlt[kk] - 18. $
;     		else $
;     			Test_case1_Mlt[kk] = Test_case1_Mlt[kk] + 6.
; 		
; 		Test_case1_Mlt[kk] = Test_case1_Mlt[kk]/ Norm_MLT_val
; 		
; 		Test_case1_kp2 = Test_case1_kp / Norm_KP_val
; 		
; 		Test_case1_lat2 = (Test_case1_lat[ll]-50.)/Norm_LAT_val
; 				
; ; 		print, Test_case1_dst, Test_case1_Ae, Test_case1_kp2, Test_case1_PC[Cnt_Cnd], Test_case1_HC[Cnt_Cnd], Test_case1_Mlt[kk], Test_case1_lat2
; 		Cnt_Cnd = Cnt_Cnd + 1
; 	
; 	endfor
; endfor




end








