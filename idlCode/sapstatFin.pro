pro sapstatFin

load_usersym, /circle

fname_saps='/home/bharat/ESAPS/files/goodCond_saps_2011_2012-new.txt' 

rad_load_colortable,/leicester

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
SAPS_events_months = intarr(nel_arr_all)
SAPS_orig_Mlts_Final = fltarr(nel_arr_all)
SAPS_Vels_Final_Vals = fltarr(nel_arr_all)
SAPS_orig_lats_Final = fltarr(nel_arr_all)

SAPS_orig_AE_Final = fltarr(nel_arr_all)
SAPS_orig_DST_Final = fltarr(nel_arr_all)
SAPS_orig_KP_Final = fltarr(nel_arr_all)
SAPS_orig_PCOND_Final = fltarr(nel_arr_all)
SAPS_orig_HCOND_Final = fltarr(nel_arr_all)



nv=0.d
OPENR, 1, fname_saps
WHILE not eof(1) do begin
    READF,1,saps_dates_chk, saps_times_chk, saps_mlts_obs_chk, AE_SAPS_chk, Dst_SAPS_chk, Kp_SAPS_chk, Final_SAPS_Vels_chk , Final_SAPS_Lats_chk, PCND_SAPS_chk, HCND_SAPS_chk


    SAPS_events_dates[nv] = ulong(saps_dates_chk)

    SAPS_events_times[nv] = uint(saps_times_chk)
    
    _date = SAPS_events_dates[nv]
    
    _year = _date/10000L
    
    MonCheck_chk = (_date - _year*10000L)/100L
    SAPS_events_months[nv] = MonCheck_chk
    
    
;     if (saps_mlts_obs_chk eq 0.) then $
;     	saps_mlts_obs_chk = 23.9
;     if (Dst_SAPS_chk lt -75.) then $
;     	print, _date, uint(saps_times_chk), Dst_SAPS_chk
    
    SAPS_orig_Mlts_Final[nv] = saps_mlts_obs_chk
    
    SAPS_orig_AE_Final[nv] = AE_SAPS_chk
    SAPS_orig_DST_Final[nv] = Dst_SAPS_chk
    SAPS_orig_KP_Final[nv] = Kp_SAPS_chk
        
    SAPS_Vels_Final_Vals[nv] = Final_SAPS_Vels_chk
    SAPS_orig_lats_Final[nv] = Final_SAPS_Lats_chk
    
    SAPS_orig_PCOND_Final[nv] = PCND_SAPS_chk
    SAPS_orig_HCOND_Final[nv] = HCND_SAPS_chk
    

    nv=nv+1   
ENDWHILE         
close,1



; 	
SAPS_events_dates = SAPS_events_dates[0:nv-1] 
SAPS_events_times = SAPS_events_times[0:nv-1] 
SAPS_events_months = SAPS_events_months[0:nv-1]

SAPS_orig_Mlts_Final = SAPS_orig_Mlts_Final[0:nv-1] 
SAPS_orig_lats_Final = SAPS_orig_lats_Final[0:nv-1] 
SAPS_Vels_Final_Vals = SAPS_Vels_Final_Vals[0:nv-1]

SAPS_orig_AE_Final = SAPS_orig_AE_Final[0:nv-1]
SAPS_orig_DST_Final = SAPS_orig_DST_Final[0:nv-1]
SAPS_orig_KP_Final = SAPS_orig_KP_Final[0:nv-1]
SAPS_orig_PCOND_Final = SAPS_orig_PCOND_Final[0:nv-1]
SAPS_orig_HCOND_Final = SAPS_orig_HCOND_Final[0:nv-1]


JinChk1 = where(~finite(SAPS_orig_lats_Final))
JinChk2 = where(~finite(SAPS_Vels_Final_Vals))



;;; Now divide the SAPS stuff into different Dst zones.... and 2 seasons

; 1) Dst lt -75
; 2) Dst ge -75 and lt -50
; 3) Dst ge -50 and lt -25
; 4) Dst ge -25 and lt -10
; 5) Dst ge -10 and lt 10

;; Month ge 10 and le 3 ---> Winter
;; Otherwise Summer


Jinds_Summer_Dst1010 = where( ( ( SAPS_orig_DST_Final ge -10. ) and ( SAPS_orig_DST_Final lt 10. ) ) )
Jinds_Summer_Dst1025 = where( ( ( SAPS_orig_DST_Final ge -25. ) and ( SAPS_orig_DST_Final lt -10. ) ) )
Jinds_Summer_Dst2550 = where( ( ( SAPS_orig_DST_Final ge -50. ) and ( SAPS_orig_DST_Final lt -25. ) ) )
Jinds_Summer_Dst5075 = where( ( ( SAPS_orig_DST_Final ge -75. ) and ( SAPS_orig_DST_Final lt -50. ) ) )
Jinds_Summer_Dst75 = where( ( ( SAPS_orig_DST_Final lt -75. ) )  )

; Jinds_Summer_Dst1010 = where( ( ( SAPS_orig_DST_Final ge -10. ) and ( SAPS_orig_DST_Final lt 10. ) ) and ( SAPS_events_months gt 3. and SAPS_events_months lt 10. ) )
; Jinds_Summer_Dst1025 = where( ( ( SAPS_orig_DST_Final ge -25. ) and ( SAPS_orig_DST_Final lt -10. ) ) and ( SAPS_events_months gt 3. and SAPS_events_months lt 10. ) )
; Jinds_Summer_Dst2550 = where( ( ( SAPS_orig_DST_Final ge -50. ) and ( SAPS_orig_DST_Final lt -25. ) ) and ( SAPS_events_months gt 3. and SAPS_events_months lt 10. ) )
; Jinds_Summer_Dst5075 = where( ( ( SAPS_orig_DST_Final ge -75. ) and ( SAPS_orig_DST_Final lt -50. ) ) and ( SAPS_events_months gt 3. and SAPS_events_months lt 10. ) )
; Jinds_Summer_Dst75 = where( ( ( SAPS_orig_DST_Final lt -75. ) ) and ( SAPS_events_months gt 3. and SAPS_events_months lt 10. ) )


Jinds_Winter_Dst1010 = where( ( ( SAPS_orig_DST_Final ge -10. ) and ( SAPS_orig_DST_Final lt 10. ) ) and ( SAPS_events_months ge 10. or SAPS_events_months le 3. ) )
Jinds_Winter_Dst1025 = where( ( ( SAPS_orig_DST_Final ge -25. ) and ( SAPS_orig_DST_Final lt -10. ) ) and ( SAPS_events_months ge 10. or SAPS_events_months le 3. ) )
Jinds_Winter_Dst2550 = where( ( ( SAPS_orig_DST_Final ge -50. ) and ( SAPS_orig_DST_Final lt -25. ) ) and ( SAPS_events_months ge 10. or SAPS_events_months le 3. ) )
Jinds_Winter_Dst5075 = where( ( ( SAPS_orig_DST_Final ge -75. ) and ( SAPS_orig_DST_Final lt -50. ) ) and ( SAPS_events_months ge 10. or SAPS_events_months le 3. ) )
Jinds_Winter_Dst75 = where( ( ( SAPS_orig_DST_Final lt -75. ) ) and ( SAPS_events_months ge 10. or SAPS_events_months le 3. ) )

title_str_noseas = [ 'Dst < 10 and > -10 nT', 'Dst < -10 and > -25 nT', 'Dst < -25 and > -50 nT', 'Dst < -50 and > -75 nT', 'Dst < -75 nT' ]

; print, n_elements(Jinds_Summer_Dst1010), n_elements(Jinds_Summer_Dst1025), n_elements(Jinds_Summer_Dst2550), n_elements(Jinds_Summer_Dst5075), n_elements(Jinds_Summer_Dst75)
; print, n_elements(Jinds_Winter_Dst1010), n_elements(Jinds_Winter_Dst1025), n_elements(Jinds_Winter_Dst2550), n_elements(Jinds_Winter_Dst5075), n_elements(Jinds_Winter_Dst75)

SAPS_vels_Summer_Dst1010 = SAPS_Vels_Final_Vals[ Jinds_Summer_Dst1010 ]
SAPS_vels_Summer_Dst1025 = SAPS_Vels_Final_Vals[ Jinds_Summer_Dst1025 ]
SAPS_vels_Summer_Dst2550 = SAPS_Vels_Final_Vals[ Jinds_Summer_Dst2550 ]
SAPS_vels_Summer_Dst5075 = SAPS_Vels_Final_Vals[ Jinds_Summer_Dst5075 ]
SAPS_vels_Summer_Dst75 = SAPS_Vels_Final_Vals[ Jinds_Summer_Dst75 ]



SAPS_vels_Winter_Dst1010 = SAPS_Vels_Final_Vals[ Jinds_Winter_Dst1010 ]
SAPS_vels_Winter_Dst1025 = SAPS_Vels_Final_Vals[ Jinds_Winter_Dst1025 ]
SAPS_vels_Winter_Dst2550 = SAPS_Vels_Final_Vals[ Jinds_Winter_Dst2550 ]
SAPS_vels_Winter_Dst5075 = SAPS_Vels_Final_Vals[ Jinds_Winter_Dst5075 ]
SAPS_vels_Winter_Dst75 = SAPS_Vels_Final_Vals[ Jinds_Winter_Dst75 ]






SAPS_lats_Summer_Dst1010 = SAPS_orig_lats_Final[ Jinds_Summer_Dst1010 ]
SAPS_lats_Summer_Dst1025 = SAPS_orig_lats_Final[ Jinds_Summer_Dst1025 ]
SAPS_lats_Summer_Dst2550 = SAPS_orig_lats_Final[ Jinds_Summer_Dst2550 ]
SAPS_lats_Summer_Dst5075 = SAPS_orig_lats_Final[ Jinds_Summer_Dst5075 ]
SAPS_lats_Summer_Dst75 = SAPS_orig_lats_Final[ Jinds_Summer_Dst75 ]



SAPS_lats_Winter_Dst1010 = SAPS_orig_lats_Final[ Jinds_Winter_Dst1010 ]
SAPS_lats_Winter_Dst1025 = SAPS_orig_lats_Final[ Jinds_Winter_Dst1025 ]
SAPS_lats_Winter_Dst2550 = SAPS_orig_lats_Final[ Jinds_Winter_Dst2550 ]
SAPS_lats_Winter_Dst5075 = SAPS_orig_lats_Final[ Jinds_Winter_Dst5075 ]
SAPS_lats_Winter_Dst75 = SAPS_orig_lats_Final[ Jinds_Winter_Dst75 ]





SAPS_mlts_Summer_Dst1010 = SAPS_orig_Mlts_Final[ Jinds_Summer_Dst1010 ]
SAPS_mlts_Summer_Dst1025 = SAPS_orig_Mlts_Final[ Jinds_Summer_Dst1025 ]
SAPS_mlts_Summer_Dst2550 = SAPS_orig_Mlts_Final[ Jinds_Summer_Dst2550 ]
SAPS_mlts_Summer_Dst5075 = SAPS_orig_Mlts_Final[ Jinds_Summer_Dst5075 ]
SAPS_mlts_Summer_Dst75 = SAPS_orig_Mlts_Final[ Jinds_Summer_Dst75 ]



SAPS_mlts_Winter_Dst1010 = SAPS_orig_Mlts_Final[ Jinds_Winter_Dst1010 ]
SAPS_mlts_Winter_Dst1025 = SAPS_orig_Mlts_Final[ Jinds_Winter_Dst1025 ]
SAPS_mlts_Winter_Dst2550 = SAPS_orig_Mlts_Final[ Jinds_Winter_Dst2550 ]
SAPS_mlts_Winter_Dst5075 = SAPS_orig_Mlts_Final[ Jinds_Winter_Dst5075 ]
SAPS_mlts_Winter_Dst75 = SAPS_orig_Mlts_Final[ Jinds_Winter_Dst75 ]



Uniq_lats_SAPS = SAPS_orig_lats_Final(UNIQ(SAPS_orig_lats_Final, SORT(SAPS_orig_lats_Final)))

Uniq_Mlts_SAPS = SAPS_orig_Mlts_Final(UNIQ(SAPS_orig_Mlts_Final, SORT(SAPS_orig_Mlts_Final)))



MeanValVel_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValLat_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValMlt_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanValVel_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValLat_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValMlt_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanValVel_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValLat_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValMlt_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanValVel_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValLat_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValMlt_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanValVel_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValLat_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValMlt_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )




MeanValVel_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValLat_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValMlt_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanValVel_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValLat_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValMlt_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanValVel_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValLat_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValMlt_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanValVel_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValLat_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValMlt_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanValVel_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValLat_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanValMlt_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )




MaxValVel_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxValVel_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxValVel_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxValVel_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxValVel_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )


MaxValVel_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxValVel_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxValVel_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxValVel_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxValVel_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )



NumPnts_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
NumPnts_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
NumPnts_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
NumPnts_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
NumPnts_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )


NumPnts_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
NumPnts_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
NumPnts_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
NumPnts_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
NumPnts_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )


Count_elems_chk = 0

Npnts_chk_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

Npnts_chk_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

CountCheck_Bh11 = 0

for tt1 = 0,n_elements(Uniq_lats_SAPS)-1 do begin
	for b22 = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin
		
		
		Jinds_Check_bh11_Summer_Dst1010 = where( (SAPS_lats_Summer_Dst1010 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Summer_Dst1010 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Summer_Dst1010[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Summer_Dst1010)
		
		Jinds_Check_bh11_Summer_Dst1025 = where( (SAPS_lats_Summer_Dst1025 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Summer_Dst1025 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Summer_Dst1025[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Summer_Dst1025)
		
		Jinds_Check_bh11_Summer_Dst2550 = where( (SAPS_lats_Summer_Dst2550 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Summer_Dst2550 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Summer_Dst2550[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Summer_Dst2550)
		
		Jinds_Check_bh11_Summer_Dst5075 = where( (SAPS_lats_Summer_Dst5075 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Summer_Dst5075 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Summer_Dst5075[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Summer_Dst5075)
		
		Jinds_Check_bh11_Summer_Dst75 = where( (SAPS_lats_Summer_Dst75 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Summer_Dst75 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Summer_Dst75[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Summer_Dst75)
		
		
		Jinds_Check_bh11_Winter_Dst1010 = where( (SAPS_lats_Winter_Dst1010 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Winter_Dst1010 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Winter_Dst1010[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Winter_Dst1010)
		
		Jinds_Check_bh11_Winter_Dst1025 = where( (SAPS_lats_Winter_Dst1025 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Winter_Dst1025 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Winter_Dst1025[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Winter_Dst1025)
		
		Jinds_Check_bh11_Winter_Dst2550 = where( (SAPS_lats_Winter_Dst2550 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Winter_Dst2550 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Winter_Dst2550[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Winter_Dst2550)
		
		Jinds_Check_bh11_Winter_Dst5075 = where( (SAPS_lats_Winter_Dst5075 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Winter_Dst5075 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Winter_Dst5075[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Winter_Dst5075)
		
		Jinds_Check_bh11_Winter_Dst75 = where( (SAPS_lats_Winter_Dst75 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Winter_Dst75 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Winter_Dst75[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Winter_Dst75)
				
; 		print, n_elements(Jinds_Check_bh11_Winter_Dst75), n_elements(Jinds_Check_bh11_Winter_Dst5075), n_elements(Jinds_Check_bh11_Winter_Dst2550), $
; 			n_elements(Jinds_Check_bh11_Winter_Dst1025),  n_elements(Jinds_Check_bh11_Winter_Dst1010), $
; 			Uniq_lats_SAPS[tt1], Uniq_Mlts_SAPS[b22]
	
		CountCheck_Bh11 = CountCheck_Bh11 + 1
	
	endfor
endfor


Npnts_chk_Summer_Dst1010 = max( Npnts_chk_Summer_Dst1010 )
Npnts_chk_Summer_Dst1025 = max( Npnts_chk_Summer_Dst1025 )
Npnts_chk_Summer_Dst2550 = max( Npnts_chk_Summer_Dst2550 )
Npnts_chk_Summer_Dst5075 = max( Npnts_chk_Summer_Dst5075 )
Npnts_chk_Summer_Dst75 = max( Npnts_chk_Summer_Dst75 )

Npnts_chk_Winter_Dst1010 = max( Npnts_chk_Winter_Dst1010 )
Npnts_chk_Winter_Dst1025 = max( Npnts_chk_Winter_Dst1025 )
Npnts_chk_Winter_Dst2550 = max( Npnts_chk_Winter_Dst2550 )
Npnts_chk_Winter_Dst5075 = max( Npnts_chk_Winter_Dst5075 )
Npnts_chk_Winter_Dst75 = max( Npnts_chk_Winter_Dst75 )

; 		print, max( Npnts_chk_Summer_Dst1010 ),'S1010'
; 		print, max( Npnts_chk_Summer_Dst1025 ),'S1025'
; 		print, max( Npnts_chk_Summer_Dst2550 ),'S2550'
; 		print, max( Npnts_chk_Summer_Dst5075 ),'S5075'
; 		print, max( Npnts_chk_Summer_Dst75 ),'S75'
; 			
; 		print, max( Npnts_chk_Winter_Dst1010 ),'W1010'
; 		print, max( Npnts_chk_Winter_Dst1025 ),'W1025'
; 		print, max( Npnts_chk_Winter_Dst2550 ),'W2550'
; 		print, max( Npnts_chk_Winter_Dst5075 ),'W5075'
; 		print, max( Npnts_chk_Winter_Dst75 ),'W75'
		

Perc_cutOff_Choose_vals = 0.2
minElCheck_Summer = [ Perc_cutOff_Choose_vals*Npnts_chk_Summer_Dst1010, Perc_cutOff_Choose_vals*Npnts_chk_Summer_Dst1025, $
			Perc_cutOff_Choose_vals*Npnts_chk_Summer_Dst2550, Perc_cutOff_Choose_vals*Npnts_chk_Summer_Dst5075, $
			Perc_cutOff_Choose_vals*Npnts_chk_Summer_Dst75 ]
minElCheck_Winter = [ Perc_cutOff_Choose_vals*Npnts_chk_Winter_Dst1010, Perc_cutOff_Choose_vals*Npnts_chk_Winter_Dst1025, $
			Perc_cutOff_Choose_vals*Npnts_chk_Winter_Dst2550, Perc_cutOff_Choose_vals*Npnts_chk_Winter_Dst5075, $
			Perc_cutOff_Choose_vals*Npnts_chk_Winter_Dst75 ]

for ll1 = 0, n_elements(Uniq_lats_SAPS)-1 do begin
	for l22 = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin
	
		JindsChkMean_Summer_Dst1010 = where( (SAPS_lats_Summer_Dst1010 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Summer_Dst1010 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Summer_Dst1010[0] ne -1 ) then begin
		
			NumPnts_Summer_Dst1010[Count_elems_chk] = n_elements(JindsChkMean_Summer_Dst1010)
			
			if ( n_elements(JindsChkMean_Summer_Dst1010) ge minElCheck_Summer[0] ) then begin		
				MeanValVel_Summer_Dst1010[Count_elems_chk] = mean(SAPS_vels_Summer_Dst1010[JindsChkMean_Summer_Dst1010]) 
				MaxValVel_Summer_Dst1010[Count_elems_chk] = max(SAPS_vels_Summer_Dst1010[JindsChkMean_Summer_Dst1010]) 
				
			endif else begin
				MeanValVel_Summer_Dst1010[Count_elems_chk] = !values.f_nan
				MaxValVel_Summer_Dst1010[Count_elems_chk] = !values.f_nan
			endelse
			
		endif else begin
			MaxValVel_Summer_Dst1010[Count_elems_chk] = !values.f_nan
			MeanValVel_Summer_Dst1010[Count_elems_chk] = !values.f_nan
		endelse
; 		print, n_elements(JindsChkMean_Summer_Dst1010),'Dst1010', Uniq_Mlts_SAPS[l22], Uniq_lats_SAPS[ll1]		
		MeanValLat_Summer_Dst1010[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Summer_Dst1010[Count_elems_chk] = Uniq_Mlts_SAPS[l22]
			
			
		JindsChkMean_Summer_Dst1025 = where( (SAPS_lats_Summer_Dst1025 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Summer_Dst1025 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Summer_Dst1025[0] ne -1 ) then begin
			
			NumPnts_Summer_Dst1025[Count_elems_chk] = n_elements(JindsChkMean_Summer_Dst1025)
			
			if ( n_elements(JindsChkMean_Summer_Dst1025) ge minElCheck_Summer[1] ) then begin		
				MeanValVel_Summer_Dst1025[Count_elems_chk] = mean(SAPS_vels_Summer_Dst1025[JindsChkMean_Summer_Dst1025]) 
				MaxValVel_Summer_Dst1025[Count_elems_chk] = max(SAPS_vels_Summer_Dst1025[JindsChkMean_Summer_Dst1025]) 
			endif else begin
				MeanValVel_Summer_Dst1025[Count_elems_chk] = !values.f_nan
				MaxValVel_Summer_Dst1025[Count_elems_chk] = !values.f_nan
			endelse

			
			
		endif else begin
			MeanValVel_Summer_Dst1025[Count_elems_chk] = !values.f_nan
			MaxValVel_Summer_Dst1025[Count_elems_chk] = !values.f_nan
		endelse

		MeanValLat_Summer_Dst1025[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Summer_Dst1025[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			
			
			
		JindsChkMean_Summer_Dst2550 = where( (SAPS_lats_Summer_Dst2550 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Summer_Dst2550 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Summer_Dst2550[0] ne -1 ) then begin
			
			NumPnts_Summer_Dst2550[Count_elems_chk] = n_elements(JindsChkMean_Summer_Dst2550)
			
			if ( n_elements(JindsChkMean_Summer_Dst2550) ge minElCheck_Summer[2] ) then begin		
				MeanValVel_Summer_Dst2550[Count_elems_chk] = mean(SAPS_vels_Summer_Dst2550[JindsChkMean_Summer_Dst2550]) 
				MaxValVel_Summer_Dst2550[Count_elems_chk] = max(SAPS_vels_Summer_Dst2550[JindsChkMean_Summer_Dst2550]) 
			endif else begin
				MeanValVel_Summer_Dst2550[Count_elems_chk] = !values.f_nan
				MaxValVel_Summer_Dst2550[Count_elems_chk] = !values.f_nan
			endelse

			
		endif else begin
			MeanValVel_Summer_Dst2550[Count_elems_chk] = !values.f_nan
			MaxValVel_Summer_Dst2550[Count_elems_chk] = !values.f_nan
		endelse

		MeanValLat_Summer_Dst2550[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Summer_Dst2550[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			

			
		JindsChkMean_Summer_Dst5075 = where( (SAPS_lats_Summer_Dst5075 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Summer_Dst5075 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Summer_Dst5075[0] ne -1 ) then begin
			
			NumPnts_Summer_Dst5075[Count_elems_chk] = n_elements(JindsChkMean_Summer_Dst5075)
			
			if ( n_elements(JindsChkMean_Summer_Dst5075) ge minElCheck_Summer[3] ) then begin		
				MeanValVel_Summer_Dst5075[Count_elems_chk] = mean(SAPS_vels_Summer_Dst5075[JindsChkMean_Summer_Dst5075]) 
				MaxValVel_Summer_Dst5075[Count_elems_chk] = max(SAPS_vels_Summer_Dst5075[JindsChkMean_Summer_Dst5075]) 
			endif else begin
				MeanValVel_Summer_Dst5075[Count_elems_chk] = !values.f_nan
				MaxValVel_Summer_Dst5075[Count_elems_chk] = !values.f_nan
			endelse

			
		endif else begin
			MeanValVel_Summer_Dst5075[Count_elems_chk] = !values.f_nan
			MaxValVel_Summer_Dst5075[Count_elems_chk] = !values.f_nan
		endelse	

		MeanValLat_Summer_Dst5075[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Summer_Dst5075[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			
			
	

		JindsChkMean_Summer_Dst75 = where( (SAPS_lats_Summer_Dst75 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Summer_Dst75 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Summer_Dst75[0] ne -1 ) then begin
		
			NumPnts_Summer_Dst75[Count_elems_chk] = n_elements(JindsChkMean_Summer_Dst75)
			
			if ( n_elements(JindsChkMean_Summer_Dst75) ge minElCheck_Summer[4] ) then begin		
				MeanValVel_Summer_Dst75[Count_elems_chk] = mean(SAPS_vels_Summer_Dst75[JindsChkMean_Summer_Dst75]) 
				MaxValVel_Summer_Dst75[Count_elems_chk] = max(SAPS_vels_Summer_Dst75[JindsChkMean_Summer_Dst75]) 
			endif else begin
				MeanValVel_Summer_Dst75[Count_elems_chk] = !values.f_nan
				MaxValVel_Summer_Dst75[Count_elems_chk] = !values.f_nan
			endelse

			
		endif else begin
			MeanValVel_Summer_Dst75[Count_elems_chk] = !values.f_nan
			MaxValVel_Summer_Dst75[Count_elems_chk] = !values.f_nan
		endelse
		
		MeanValLat_Summer_Dst75[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Summer_Dst75[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			
		

	
	
	
	
	
	
	
	

	
	
	
	

	
		JindsChkMean_Winter_Dst1010 = where( (SAPS_lats_Winter_Dst1010 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Winter_Dst1010 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Winter_Dst1010[0] ne -1 ) then begin
		
			NumPnts_Winter_Dst1010[Count_elems_chk] = n_elements(JindsChkMean_Winter_Dst1010)
			
			if ( n_elements(JindsChkMean_Winter_Dst1010) ge minElCheck_Winter[0] ) then begin		
				MeanValVel_Winter_Dst1010[Count_elems_chk] = mean(SAPS_vels_Winter_Dst1010[JindsChkMean_Winter_Dst1010]) 
				MaxValVel_Winter_Dst1010[Count_elems_chk] = max(SAPS_vels_Winter_Dst1010[JindsChkMean_Winter_Dst1010]) 
				
			endif else begin
				MeanValVel_Winter_Dst1010[Count_elems_chk] = !values.f_nan
				MaxValVel_Winter_Dst1010[Count_elems_chk] = !values.f_nan
			endelse
			
		endif else begin
			MaxValVel_Winter_Dst1010[Count_elems_chk] = !values.f_nan
			MeanValVel_Winter_Dst1010[Count_elems_chk] = !values.f_nan
		endelse
; 		print, n_elements(JindsChkMean_Winter_Dst1010),'Dst1010', Uniq_Mlts_SAPS[l22], Uniq_lats_SAPS[ll1]		
		MeanValLat_Winter_Dst1010[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Winter_Dst1010[Count_elems_chk] = Uniq_Mlts_SAPS[l22]
			
			
		JindsChkMean_Winter_Dst1025 = where( (SAPS_lats_Winter_Dst1025 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Winter_Dst1025 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Winter_Dst1025[0] ne -1 ) then begin
			
			NumPnts_Winter_Dst1025[Count_elems_chk] = n_elements(JindsChkMean_Winter_Dst1025)
			
			if ( n_elements(JindsChkMean_Winter_Dst1025) ge minElCheck_Winter[1] ) then begin		
				MeanValVel_Winter_Dst1025[Count_elems_chk] = mean(SAPS_vels_Winter_Dst1025[JindsChkMean_Winter_Dst1025]) 
				MaxValVel_Winter_Dst1025[Count_elems_chk] = max(SAPS_vels_Winter_Dst1025[JindsChkMean_Winter_Dst1025]) 
			endif else begin
				MeanValVel_Winter_Dst1025[Count_elems_chk] = !values.f_nan
				MaxValVel_Winter_Dst1025[Count_elems_chk] = !values.f_nan
			endelse

			
			
		endif else begin
			MeanValVel_Winter_Dst1025[Count_elems_chk] = !values.f_nan
			MaxValVel_Winter_Dst1025[Count_elems_chk] = !values.f_nan
		endelse

		MeanValLat_Winter_Dst1025[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Winter_Dst1025[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			
			
			
		JindsChkMean_Winter_Dst2550 = where( (SAPS_lats_Winter_Dst2550 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Winter_Dst2550 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Winter_Dst2550[0] ne -1 ) then begin
			
			NumPnts_Winter_Dst2550[Count_elems_chk] = n_elements(JindsChkMean_Winter_Dst2550)
			
			if ( n_elements(JindsChkMean_Winter_Dst2550) ge minElCheck_Winter[2] ) then begin		
				MeanValVel_Winter_Dst2550[Count_elems_chk] = mean(SAPS_vels_Winter_Dst2550[JindsChkMean_Winter_Dst2550]) 
				MaxValVel_Winter_Dst2550[Count_elems_chk] = max(SAPS_vels_Winter_Dst2550[JindsChkMean_Winter_Dst2550]) 
			endif else begin
				MeanValVel_Winter_Dst2550[Count_elems_chk] = !values.f_nan
				MaxValVel_Winter_Dst2550[Count_elems_chk] = !values.f_nan
			endelse

			
		endif else begin
			MeanValVel_Winter_Dst2550[Count_elems_chk] = !values.f_nan
			MaxValVel_Winter_Dst2550[Count_elems_chk] = !values.f_nan
		endelse

		MeanValLat_Winter_Dst2550[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Winter_Dst2550[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			

			
		JindsChkMean_Winter_Dst5075 = where( (SAPS_lats_Winter_Dst5075 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Winter_Dst5075 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Winter_Dst5075[0] ne -1 ) then begin
			
			NumPnts_Winter_Dst5075[Count_elems_chk] = n_elements(JindsChkMean_Winter_Dst5075)
			
			if ( n_elements(JindsChkMean_Winter_Dst5075) ge minElCheck_Winter[3] ) then begin		
				MeanValVel_Winter_Dst5075[Count_elems_chk] = mean(SAPS_vels_Winter_Dst5075[JindsChkMean_Winter_Dst5075]) 
				MaxValVel_Winter_Dst5075[Count_elems_chk] = max(SAPS_vels_Winter_Dst5075[JindsChkMean_Winter_Dst5075]) 
			endif else begin
				MeanValVel_Winter_Dst5075[Count_elems_chk] = !values.f_nan
				MaxValVel_Winter_Dst5075[Count_elems_chk] = !values.f_nan
			endelse

			
		endif else begin
			MeanValVel_Winter_Dst5075[Count_elems_chk] = !values.f_nan
			MaxValVel_Winter_Dst5075[Count_elems_chk] = !values.f_nan
		endelse	

		MeanValLat_Winter_Dst5075[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Winter_Dst5075[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			
			
	

		JindsChkMean_Winter_Dst75 = where( (SAPS_lats_Winter_Dst75 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Winter_Dst75 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Winter_Dst75[0] ne -1 ) then begin
		
			NumPnts_Winter_Dst75[Count_elems_chk] = n_elements(JindsChkMean_Winter_Dst75)
			
			if ( n_elements(JindsChkMean_Winter_Dst75) ge minElCheck_Winter[4] ) then begin		
				MeanValVel_Winter_Dst75[Count_elems_chk] = mean(SAPS_vels_Winter_Dst75[JindsChkMean_Winter_Dst75]) 
				MaxValVel_Winter_Dst75[Count_elems_chk] = max(SAPS_vels_Winter_Dst75[JindsChkMean_Winter_Dst75]) 
; 				print, SAPS_events_dates[JindsChkMean_Winter_Dst75[0]], SAPS_events_times[JindsChkMean_Winter_Dst75[0]], SAPS_orig_DST_Final[JindsChkMean_Winter_Dst75[0]], Uniq_lats_SAPS[ll1], Uniq_Mlts_SAPS[l22]
			endif else begin
				MeanValVel_Winter_Dst75[Count_elems_chk] = !values.f_nan
				MaxValVel_Winter_Dst75[Count_elems_chk] = !values.f_nan
			endelse

			
		endif else begin
			MeanValVel_Winter_Dst75[Count_elems_chk] = !values.f_nan
			MaxValVel_Winter_Dst75[Count_elems_chk] = !values.f_nan
		endelse
		
		MeanValLat_Winter_Dst75[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Winter_Dst75[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			
			
	
			
		
	
		Count_elems_chk = Count_elems_chk + 1
	endfor
endfor




scaleVelsSAPS = [0., 750.]

colValVel_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colValVel_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colValVel_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colValVel_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colValVel_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )


colValVel_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colValVel_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colValVel_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colValVel_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colValVel_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )










for k = 0,n_elements(MeanValVel_Summer_Dst1010) -1 do begin


	if ( finite( MeanValVel_Summer_Dst1010[k] ) ) then begin
		colValVel_Summer_Dst1010[k] = get_color_index(MeanValVel_Summer_Dst1010[k],scale=scaleVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colValVel_Summer_Dst1010[k] = get_background()
	endelse
	
	if ( finite( MeanValVel_Summer_Dst1025[k] ) ) then begin
		colValVel_Summer_Dst1025[k] = get_color_index(MeanValVel_Summer_Dst1025[k],scale=scaleVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colValVel_Summer_Dst1025[k] = get_background()
	endelse

	if ( finite( MeanValVel_Summer_Dst2550[k] ) ) then begin
		colValVel_Summer_Dst2550[k] = get_color_index(MeanValVel_Summer_Dst2550[k],scale=scaleVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colValVel_Summer_Dst2550[k] = get_background()
	endelse

	
	if ( finite( MeanValVel_Summer_Dst5075[k] ) ) then begin
		colValVel_Summer_Dst5075[k] = get_color_index(MeanValVel_Summer_Dst5075[k],scale=scaleVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colValVel_Summer_Dst5075[k] = get_background()
	endelse

	
	if ( finite( MeanValVel_Summer_Dst75[k] ) ) then begin
		colValVel_Summer_Dst75[k] = get_color_index(MeanValVel_Summer_Dst75[k],scale=scaleVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colValVel_Summer_Dst75[k] = get_background()
	endelse

	
	
	
	
	
	
	if ( finite( MeanValVel_Winter_Dst1010[k] ) ) then begin
		colValVel_Winter_Dst1010[k] = get_color_index(MeanValVel_Winter_Dst1010[k],scale=scaleVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colValVel_Winter_Dst1010[k] = get_background()
	endelse
	
	if ( finite( MeanValVel_Winter_Dst1025[k] ) ) then begin
		colValVel_Winter_Dst1025[k] = get_color_index(MeanValVel_Winter_Dst1025[k],scale=scaleVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colValVel_Winter_Dst1025[k] = get_background()
	endelse

	if ( finite( MeanValVel_Winter_Dst2550[k] ) ) then begin
		colValVel_Winter_Dst2550[k] = get_color_index(MeanValVel_Winter_Dst2550[k],scale=scaleVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colValVel_Winter_Dst2550[k] = get_background()
	endelse

	
	if ( finite( MeanValVel_Winter_Dst5075[k] ) ) then begin
		colValVel_Winter_Dst5075[k] = get_color_index(MeanValVel_Winter_Dst5075[k],scale=scaleVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colValVel_Winter_Dst5075[k] = get_background()
	endelse

	
	if ( finite( MeanValVel_Winter_Dst75[k] ) ) then begin
		colValVel_Winter_Dst75[k] = get_color_index(MeanValVel_Winter_Dst75[k],scale=scaleVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colValVel_Winter_Dst75[k] = get_background()
	endelse
	
	

endfor







scaleMaxVelsSAPS = [0., 1200.]

colvalMaxVel_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalMaxVel_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalMaxVel_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalMaxVel_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalMaxVel_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )


colvalMaxVel_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalMaxVel_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalMaxVel_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalMaxVel_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalMaxVel_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )








for k = 0,n_elements(MaxValVel_Summer_Dst1010) -1 do begin


	if ( finite( MaxValVel_Summer_Dst1010[k] ) ) then begin
		colvalMaxVel_Summer_Dst1010[k] = get_color_index(MaxValVel_Summer_Dst1010[k],scale=scaleMaxVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colvalMaxVel_Summer_Dst1010[k] = get_background()
	endelse
	
	if ( finite( MaxValVel_Summer_Dst1025[k] ) ) then begin
		colvalMaxVel_Summer_Dst1025[k] = get_color_index(MaxValVel_Summer_Dst1025[k],scale=scaleMaxVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colvalMaxVel_Summer_Dst1025[k] = get_background()
	endelse

	if ( finite( MaxValVel_Summer_Dst2550[k] ) ) then begin
		colvalMaxVel_Summer_Dst2550[k] = get_color_index(MaxValVel_Summer_Dst2550[k],scale=scaleMaxVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colvalMaxVel_Summer_Dst2550[k] = get_background()
	endelse

	
	if ( finite( MaxValVel_Summer_Dst5075[k] ) ) then begin
		colvalMaxVel_Summer_Dst5075[k] = get_color_index(MaxValVel_Summer_Dst5075[k],scale=scaleMaxVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colvalMaxVel_Summer_Dst5075[k] = get_background()
	endelse

	
	if ( finite( MaxValVel_Summer_Dst75[k] ) ) then begin
		colvalMaxVel_Summer_Dst75[k] = get_color_index(MaxValVel_Summer_Dst75[k],scale=scaleMaxVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colvalMaxVel_Summer_Dst75[k] = get_background()
	endelse

	
	
	
	
	
	
	if ( finite( MaxValVel_Winter_Dst1010[k] ) ) then begin
		colvalMaxVel_Winter_Dst1010[k] = get_color_index(MaxValVel_Winter_Dst1010[k],scale=scaleMaxVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colvalMaxVel_Winter_Dst1010[k] = get_background()
	endelse
	
	if ( finite( MaxValVel_Winter_Dst1025[k] ) ) then begin
		colvalMaxVel_Winter_Dst1025[k] = get_color_index(MaxValVel_Winter_Dst1025[k],scale=scaleMaxVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colvalMaxVel_Winter_Dst1025[k] = get_background()
	endelse

	if ( finite( MaxValVel_Winter_Dst2550[k] ) ) then begin
		colvalMaxVel_Winter_Dst2550[k] = get_color_index(MaxValVel_Winter_Dst2550[k],scale=scaleMaxVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colvalMaxVel_Winter_Dst2550[k] = get_background()
	endelse

	
	if ( finite( MaxValVel_Winter_Dst5075[k] ) ) then begin
		colvalMaxVel_Winter_Dst5075[k] = get_color_index(MaxValVel_Winter_Dst5075[k],scale=scaleMaxVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colvalMaxVel_Winter_Dst5075[k] = get_background()
	endelse

	
	if ( finite( MaxValVel_Winter_Dst75[k] ) ) then begin
		colvalMaxVel_Winter_Dst75[k] = get_color_index(MaxValVel_Winter_Dst75[k],scale=scaleMaxVelsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	endif else begin
		colvalMaxVel_Winter_Dst75[k] = get_background()
	endelse
	
	

endfor




; MaxNumPnts_Summer = max( [ NumPnts_Summer_Dst75, NumPnts_Summer_Dst5075, NumPnts_Summer_Dst2550, NumPnts_Summer_Dst1025, NumPnts_Summer_Dst1010 ] )
; MaxNumPnts_Winter = max( [ NumPnts_Winter_Dst75, NumPnts_Winter_Dst5075, NumPnts_Winter_Dst2550, NumPnts_Winter_Dst1025, NumPnts_Winter_Dst1010 ] )

MaxNumPnts_Summer_Dst1010 = max(NumPnts_Summer_Dst1010)
MaxNumPnts_Summer_Dst1025 = max(NumPnts_Summer_Dst1025)
MaxNumPnts_Summer_Dst2550 = max(NumPnts_Summer_Dst2550)
MaxNumPnts_Summer_Dst5075 = max(NumPnts_Summer_Dst5075)
MaxNumPnts_Summer_Dst75 = max(NumPnts_Summer_Dst75)

MaxNumPnts_Winter_Dst1010 = max(NumPnts_Winter_Dst1010)
MaxNumPnts_Winter_Dst1025 = max(NumPnts_Winter_Dst1025)
MaxNumPnts_Winter_Dst2550 = max(NumPnts_Winter_Dst2550)
MaxNumPnts_Winter_Dst5075 = max(NumPnts_Winter_Dst5075)
MaxNumPnts_Winter_Dst75 = max(NumPnts_Winter_Dst75)


scaleNumPntsSAPS = [0., 1.]


colvalNumPnt_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalNumPnt_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalNumPnt_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalNumPnt_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalNumPnt_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )


colvalNumPnt_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalNumPnt_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalNumPnt_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalNumPnt_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
colvalNumPnt_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

minValPlotNumPnt = 0.25


for k = 0,n_elements(NumPnts_Summer_Dst1010) -1 do begin


	if ( finite( NumPnts_Summer_Dst1010[k] ) ) then begin
		colvalNumPnt_Summer_Dst1010[k] = get_color_index(NumPnts_Summer_Dst1010[k]/MaxNumPnts_Summer_Dst1010,scale=scaleNumPntsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		
		if ( NumPnts_Summer_Dst1010[k]/MaxNumPnts_Summer_Dst1010 lt minValPlotNumPnt) then begin
			colvalNumPnt_Summer_Dst1010[k] = get_background()
		endif
		
	endif else begin
		colvalNumPnt_Summer_Dst1010[k] = get_background()
	endelse
	
	if ( finite( NumPnts_Summer_Dst1025[k] ) ) then begin
		colvalNumPnt_Summer_Dst1025[k] = get_color_index(NumPnts_Summer_Dst1025[k]/MaxNumPnts_Summer_Dst1025,scale=scaleNumPntsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		
		if ( NumPnts_Summer_Dst1025[k]/MaxNumPnts_Summer_Dst1025 lt minValPlotNumPnt) then begin
			colvalNumPnt_Summer_Dst1025[k] = get_background()
		endif	
		
	endif else begin
		colvalNumPnt_Summer_Dst1025[k] = get_background()
	endelse

	if ( finite( NumPnts_Summer_Dst2550[k] ) ) then begin
		colvalNumPnt_Summer_Dst2550[k] = get_color_index(NumPnts_Summer_Dst2550[k]/MaxNumPnts_Summer_Dst2550,scale=scaleNumPntsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	
		if ( NumPnts_Summer_Dst2550[k]/MaxNumPnts_Summer_Dst2550 lt minValPlotNumPnt) then begin
			colvalNumPnt_Summer_Dst2550[k] = get_background()
		endif	

	
	endif else begin
		colvalNumPnt_Summer_Dst2550[k] = get_background()
	endelse

	
	if ( finite( NumPnts_Summer_Dst5075[k] ) ) then begin
		colvalNumPnt_Summer_Dst5075[k] = get_color_index(NumPnts_Summer_Dst5075[k]/MaxNumPnts_Summer_Dst5075,scale=scaleNumPntsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	
		if ( NumPnts_Summer_Dst5075[k]/MaxNumPnts_Summer_Dst5075 lt minValPlotNumPnt) then begin
			colvalNumPnt_Summer_Dst5075[k] = get_background()
		endif	

	
	endif else begin
		colvalNumPnt_Summer_Dst5075[k] = get_background()
	endelse

	
	if ( finite( NumPnts_Summer_Dst75[k] ) ) then begin
		colvalNumPnt_Summer_Dst75[k] = get_color_index(NumPnts_Summer_Dst75[k]/MaxNumPnts_Summer_Dst75,scale=scaleNumPntsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		
		if ( NumPnts_Summer_Dst75[k]/MaxNumPnts_Summer_Dst75 lt minValPlotNumPnt) then begin
			colvalNumPnt_Summer_Dst75[k] = get_background()
		endif
	
	endif else begin
		colvalNumPnt_Summer_Dst75[k] = get_background()
	endelse

	
	
	
	
	
	
	if ( finite( NumPnts_Winter_Dst1010[k] ) ) then begin
		colvalNumPnt_Winter_Dst1010[k] = get_color_index(NumPnts_Winter_Dst1010[k]/MaxNumPnts_Winter_Dst1010,scale=scaleNumPntsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')

		if ( NumPnts_Winter_Dst1010[k]/MaxNumPnts_Winter_Dst1010 lt minValPlotNumPnt) then begin
			colvalNumPnt_Winter_Dst1010[k] = get_background()
		endif
	
	endif else begin
		colvalNumPnt_Winter_Dst1010[k] = get_background()
	endelse
	
	if ( finite( NumPnts_Winter_Dst1025[k] ) ) then begin
		colvalNumPnt_Winter_Dst1025[k] = get_color_index(NumPnts_Winter_Dst1025[k]/MaxNumPnts_Winter_Dst1025,scale=scaleNumPntsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	
		if ( NumPnts_Winter_Dst1025[k]/MaxNumPnts_Winter_Dst1025 lt minValPlotNumPnt) then begin
			colvalNumPnt_Winter_Dst1025[k] = get_background()
		endif	
	
	endif else begin
		colvalNumPnt_Winter_Dst1025[k] = get_background()
	endelse

	if ( finite( NumPnts_Winter_Dst2550[k] ) ) then begin	
	
		colvalNumPnt_Winter_Dst2550[k] = get_color_index(NumPnts_Winter_Dst2550[k]/MaxNumPnts_Winter_Dst2550,scale=scaleNumPntsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')

		if ( NumPnts_Winter_Dst2550[k]/MaxNumPnts_Winter_Dst2550 lt minValPlotNumPnt) then begin
			colvalNumPnt_Winter_Dst2550[k] = get_background()
		endif	

		
	endif else begin
		colvalNumPnt_Winter_Dst2550[k] = get_background()
	endelse

	
	if ( finite( NumPnts_Winter_Dst5075[k] ) ) then begin
		colvalNumPnt_Winter_Dst5075[k] = get_color_index(NumPnts_Winter_Dst5075[k]/MaxNumPnts_Winter_Dst5075,scale=scaleNumPntsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	
		if ( NumPnts_Winter_Dst5075[k]/MaxNumPnts_Winter_Dst5075 lt minValPlotNumPnt) then begin
			colvalNumPnt_Winter_Dst5075[k] = get_background()
		endif	
	

	
	endif else begin
		colvalNumPnt_Winter_Dst5075[k] = get_background()
	endelse

	
	if ( finite( NumPnts_Winter_Dst75[k] ) ) then begin
		colvalNumPnt_Winter_Dst75[k] = get_color_index(NumPnts_Winter_Dst75[k]/MaxNumPnts_Winter_Dst75,scale=scaleNumPntsSAPS,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	
		if ( NumPnts_Winter_Dst75[k]/MaxNumPnts_Winter_Dst75 lt minValPlotNumPnt) then begin
			colvalNumPnt_Winter_Dst75[k] = get_background()
		endif	
	
	
	
	endif else begin
		colvalNumPnt_Winter_Dst75[k] = get_background()
	endelse
	
	

endfor






date = 20110403
time = 0400
coords = 'mlt'
xrangePlot = [-44, 44]
yrangePlot = [-44, 20]


ps_open,'/home/bharat/ESAPS/Finstats/MeanValVel_dstmods_Summer.ps'

map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[0], charsize = 0.5


for k = 0,n_elements(MeanValVel_Summer_Dst1010) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst1010[k], MeanValMlt_Summer_Dst1010[k], /mlt )
	if ( ( NumPnts_Summer_Dst1010[k]/MaxNumPnts_Summer_Dst1010 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colValVel_Summer_Dst1010[k]
	
endfor

plot_colorbar, 1., 1., 0., 0.,scale=scaleVelsSAPS,legend='Vel. [m/s]',param='power'




map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[1], charsize = 0.5


for k = 0,n_elements(MeanValVel_Summer_Dst1025) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst1025[k], MeanValMlt_Summer_Dst1025[k], /mlt )
	if ( ( NumPnts_Summer_Dst1025[k]/MaxNumPnts_Summer_Dst1025 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colValVel_Summer_Dst1025[k]
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleVelsSAPS,legend='Vel.',param='power'



map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[2], charsize = 0.5


for k = 0,n_elements(MeanValVel_Summer_Dst2550) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst2550[k], MeanValMlt_Summer_Dst2550[k], /mlt )
	if ( ( NumPnts_Summer_Dst2550[k]/MaxNumPnts_Summer_Dst2550 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colValVel_Summer_Dst2550[k]
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleVelsSAPS,legend='Vel.',param='power'




map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[3], charsize = 0.5


for k = 0,n_elements(MeanValVel_Summer_Dst5075) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst5075[k], MeanValMlt_Summer_Dst5075[k], /mlt )
	if ( ( NumPnts_Summer_Dst5075[k]/MaxNumPnts_Summer_Dst5075 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colValVel_Summer_Dst5075[k]
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleVelsSAPS,legend='Vel.',param='power'



map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0.5,2,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[4], charsize = 0.5


for k = 0,n_elements(MeanValVel_Summer_Dst75) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst75[k], MeanValMlt_Summer_Dst75[k], /mlt )
	if ( ( NumPnts_Summer_Dst75[k]/MaxNumPnts_Summer_Dst75 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colValVel_Summer_Dst75[k]
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleVelsSAPS,legend='Vel.',param='power'





ps_close,/no_filename










ps_open,'/home/bharat/ESAPS/Finstats/MeanValVel_dstmods_Winter.ps'

clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < 10 and > -10 nT'


for k = 0,n_elements(MeanValVel_Winter_Dst1010) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst1010[k], MeanValMlt_Winter_Dst1010[k], /mlt )
	if ( ( NumPnts_Winter_Dst1010[k]/MaxNumPnts_Winter_Dst1010 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colValVel_Winter_Dst1010[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleVelsSAPS,legend='Vel.',param='power'




clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -10 and > -25 nT'


for k = 0,n_elements(MeanValVel_Winter_Dst1025) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst1025[k], MeanValMlt_Winter_Dst1025[k], /mlt )
	if ( ( NumPnts_Winter_Dst1025[k]/MaxNumPnts_Winter_Dst1025 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colValVel_Winter_Dst1025[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleVelsSAPS,legend='Vel.',param='power'



clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -25 and > -50 nT'


for k = 0,n_elements(MeanValVel_Winter_Dst2550) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst2550[k], MeanValMlt_Winter_Dst2550[k], /mlt )
	
	if ( ( NumPnts_Winter_Dst2550[k]/MaxNumPnts_Winter_Dst2550 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colValVel_Winter_Dst2550[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleVelsSAPS,legend='Vel.',param='power'




clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -50 and > -75 nT'


for k = 0,n_elements(MeanValVel_Winter_Dst5075) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst5075[k], MeanValMlt_Winter_Dst5075[k], /mlt )
	if ( ( NumPnts_Winter_Dst5075[k]/MaxNumPnts_Winter_Dst5075 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colValVel_Winter_Dst5075[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleVelsSAPS,legend='Vel.',param='power'



clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -75 nT'


for k = 0,n_elements(MeanValVel_Winter_Dst75) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst75[k], MeanValMlt_Winter_Dst75[k], /mlt )
	if ( ( NumPnts_Winter_Dst75[k]/MaxNumPnts_Winter_Dst75 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colValVel_Winter_Dst75[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleVelsSAPS,legend='Vel.',param='power'





ps_close,/no_filename




ps_open,'/home/bharat/ESAPS/Finstats/MaxValVel_dstmods_Summer.ps'

map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[0], charsize = 0.5


for k = 0,n_elements(MaxValVel_Summer_Dst1010) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst1010[k], MeanValMlt_Summer_Dst1010[k], /mlt )
	if ( ( NumPnts_Summer_Dst1010[k]/MaxNumPnts_Summer_Dst1010 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalMaxVel_Summer_Dst1010[k]
	
endfor

plot_colorbar, 1., 1., 0., 0.,scale=scaleVelsSAPS,legend='Vel. [m/s]',param='power'



map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[1], charsize = 0.5


for k = 0,n_elements(MaxValVel_Summer_Dst1025) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst1025[k], MeanValMlt_Summer_Dst1025[k], /mlt )
	if ( ( NumPnts_Summer_Dst1025[k]/MaxNumPnts_Summer_Dst1025 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalMaxVel_Summer_Dst1025[k]
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleMaxVelsSAPS,legend='Vel.',param='power'



map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[2], charsize = 0.5


for k = 0,n_elements(MaxValVel_Summer_Dst2550) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst2550[k], MeanValMlt_Summer_Dst2550[k], /mlt )
	if ( ( NumPnts_Summer_Dst2550[k]/MaxNumPnts_Summer_Dst2550 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalMaxVel_Summer_Dst2550[k]
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleMaxVelsSAPS,legend='Vel.',param='power'




map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[3], charsize = 0.5


for k = 0,n_elements(MaxValVel_Summer_Dst5075) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst5075[k], MeanValMlt_Summer_Dst5075[k], /mlt )
	if ( ( NumPnts_Summer_Dst5075[k]/MaxNumPnts_Summer_Dst5075 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalMaxVel_Summer_Dst5075[k]
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleMaxVelsSAPS,legend='Vel.',param='power'



map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0.5,2,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[4], charsize = 0.5


for k = 0,n_elements(MaxValVel_Summer_Dst75) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst75[k], MeanValMlt_Summer_Dst75[k], /mlt )
	if ( ( NumPnts_Summer_Dst75[k]/MaxNumPnts_Summer_Dst75 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalMaxVel_Summer_Dst75[k]
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleMaxVelsSAPS,legend='Vel.',param='power'





ps_close,/no_filename










ps_open,'/home/bharat/ESAPS/Finstats/MaxValVel_dstmods_Winter.ps'

clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < 10 and > -10 nT'


for k = 0,n_elements(MaxValVel_Winter_Dst1010) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst1010[k], MeanValMlt_Winter_Dst1010[k], /mlt )
	if ( ( NumPnts_Winter_Dst1010[k]/MaxNumPnts_Winter_Dst1010 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalMaxVel_Winter_Dst1010[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleMaxVelsSAPS,legend='Vel.',param='power'




clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -10 and > -25 nT'


for k = 0,n_elements(MaxValVel_Winter_Dst1025) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst1025[k], MeanValMlt_Winter_Dst1025[k], /mlt )
	if ( ( NumPnts_Winter_Dst1025[k]/MaxNumPnts_Winter_Dst1025 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalMaxVel_Winter_Dst1025[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleMaxVelsSAPS,legend='Vel.',param='power'



clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -25 and > -50 nT'


for k = 0,n_elements(MaxValVel_Winter_Dst2550) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst2550[k], MeanValMlt_Winter_Dst2550[k], /mlt )
	if ( ( NumPnts_Winter_Dst2550[k]/MaxNumPnts_Winter_Dst2550 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalMaxVel_Winter_Dst2550[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleMaxVelsSAPS,legend='Vel.',param='power'




clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -50 and > -75 nT'


for k = 0,n_elements(MaxValVel_Winter_Dst5075) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst5075[k], MeanValMlt_Winter_Dst5075[k], /mlt )
	if ( ( NumPnts_Winter_Dst5075[k]/MaxNumPnts_Winter_Dst5075 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalMaxVel_Winter_Dst5075[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleMaxVelsSAPS,legend='Vel.',param='power'



clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -75 nT'


for k = 0,n_elements(MaxValVel_Winter_Dst75) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst75[k], MeanValMlt_Winter_Dst75[k], /mlt )
	if ( ( NumPnts_Winter_Dst75[k]/MaxNumPnts_Winter_Dst75 ) gt minValPlotNumPnt ) then $
		oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalMaxVel_Winter_Dst75[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleMaxVelsSAPS,legend='Vel.',param='power'





ps_close,/no_filename








ps_open,'/home/bharat/ESAPS/Finstats/NumPnts_dstmods_Summer.ps'


map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[0], charsize = 0.5


for k = 0,n_elements(NumPnts_Summer_Dst1010) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst1010[k], MeanValMlt_Summer_Dst1010[k], /mlt )
	oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalNumPnt_Summer_Dst1010[k]
	
endfor

plot_colorbar, 1., 1., 0., 0.,scale=scaleNumPntsSAPS,legend='Prob. of Occurrence',param='power', level_format = '(f6.2)'



map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[1], charsize = 0.5


for k = 0,n_elements(NumPnts_Summer_Dst1025) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst1025[k], MeanValMlt_Summer_Dst1025[k], /mlt )
	oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalNumPnt_Summer_Dst1025[k]
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleNumPntsSAPS,legend='Prob. of Occurrence',param='power', level_format = '(f6.2)'



map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[2], charsize = 0.5


for k = 0,n_elements(NumPnts_Summer_Dst2550) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst2550[k], MeanValMlt_Summer_Dst2550[k], /mlt )
	oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalNumPnt_Summer_Dst2550[k]
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleNumPntsSAPS,legend='Prob. of Occurrence',param='power', level_format = '(f6.2)'




map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[3], charsize = 0.5


for k = 0,n_elements(NumPnts_Summer_Dst5075) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst5075[k], MeanValMlt_Summer_Dst5075[k], /mlt )
	oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalNumPnt_Summer_Dst5075[k]
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleNumPntsSAPS,legend='Prob. of Occurrence',param='power', level_format = '(f6.2)'



map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0.5,2,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[4], charsize = 0.5


for k = 0,n_elements(NumPnts_Summer_Dst75) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Summer_Dst75[k], MeanValMlt_Summer_Dst75[k], /mlt )
	oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalNumPnt_Summer_Dst75[k]
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleNumPntsSAPS,legend='Prob. of Occurrence',param='power', level_format = '(f6.2)'





ps_close,/no_filename










ps_open,'/home/bharat/ESAPS/Finstats/NumPnts_dstmods_Winter.ps'

clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < 10 and > -10 nT'


for k = 0,n_elements(NumPnts_Winter_Dst1010) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst1010[k], MeanValMlt_Winter_Dst1010[k], /mlt )
	oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalNumPnt_Winter_Dst1010[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleNumPntsSAPS,legend='Prob. of Occurrence',param='power', level_format = '(f6.2)'




clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -10 and > -25 nT'


for k = 0,n_elements(NumPnts_Winter_Dst1025) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst1025[k], MeanValMlt_Winter_Dst1025[k], /mlt )
	oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalNumPnt_Winter_Dst1025[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleNumPntsSAPS,legend='Prob. of Occurrence',param='power', level_format = '(f6.2)'



clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -25 and > -50 nT'


for k = 0,n_elements(NumPnts_Winter_Dst2550) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst2550[k], MeanValMlt_Winter_Dst2550[k], /mlt )
	oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalNumPnt_Winter_Dst2550[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleNumPntsSAPS,legend='Prob. of Occurrence',param='power', level_format = '(f6.2)'




clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -50 and > -75 nT'


for k = 0,n_elements(NumPnts_Winter_Dst5075) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst5075[k], MeanValMlt_Winter_Dst5075[k], /mlt )
	oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalNumPnt_Winter_Dst5075[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleNumPntsSAPS,legend='Prob. of Occurrence',param='power', level_format = '(f6.2)'



clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -75 nT'


for k = 0,n_elements(NumPnts_Winter_Dst75) -1 do begin

	stereCr = calc_stereo_coords( MeanValLat_Winter_Dst75[k], MeanValMlt_Winter_Dst75[k], /mlt )
	oplot, [stereCr[0]], [stereCr[1]], psym = 8, symsize = 0.25, color = colvalNumPnt_Winter_Dst75[k]
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleNumPntsSAPS,legend='Prob. of Occurrence',param='power', level_format = '(f6.2)'





ps_close,/no_filename







minValgthighperc = 0.25;0.35
; minValgthighperc_lower1 = 0.2

; print, 'Uniq_lats_SAPS',Uniq_lats_SAPS


jindsPltLocsFilter_Summer_Dst1010 = where( ( NumPnts_Summer_Dst1010/MaxNumPnts_Summer_Dst1010 ) gt minValgthighperc )
jindsPltLocsFilter_Summer_Dst1025 = where( ( NumPnts_Summer_Dst1025/MaxNumPnts_Summer_Dst1025 ) gt minValgthighperc )
jindsPltLocsFilter_Summer_Dst2550 = where( ( NumPnts_Summer_Dst2550/MaxNumPnts_Summer_Dst2550 ) gt minValgthighperc )
jindsPltLocsFilter_Summer_Dst5075 = where( ( NumPnts_Summer_Dst5075/MaxNumPnts_Summer_Dst5075 ) gt minValgthighperc )
jindsPltLocsFilter_Summer_Dst75 = where( ( NumPnts_Summer_Dst75/MaxNumPnts_Summer_Dst75 ) gt minValgthighperc )


jindsPltLocsFilter_Winter_Dst1010 = where( ( NumPnts_Winter_Dst1010/MaxNumPnts_Winter_Dst1010 ) gt minValgthighperc )
jindsPltLocsFilter_Winter_Dst1025 = where( ( NumPnts_Winter_Dst1025/MaxNumPnts_Winter_Dst1025 ) gt minValgthighperc )
jindsPltLocsFilter_Winter_Dst2550 = where( ( NumPnts_Winter_Dst2550/MaxNumPnts_Winter_Dst2550 ) gt minValgthighperc )
jindsPltLocsFilter_Winter_Dst5075 = where( ( NumPnts_Winter_Dst5075/MaxNumPnts_Winter_Dst5075 ) gt minValgthighperc )
jindsPltLocsFilter_Winter_Dst75 = where( ( NumPnts_Winter_Dst75/MaxNumPnts_Winter_Dst75 ) gt minValgthighperc )

MinValLat_Summer_Dst1010 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MaxValLat_Summer_Dst1010 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MinValLatMlt_Summer_Dst1010_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )
MaxValLatMlt_Summer_Dst1010_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )

MinValLat_Summer_Dst1025 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MaxValLat_Summer_Dst1025 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MinValLatMlt_Summer_Dst1025_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )
MaxValLatMlt_Summer_Dst1025_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )

MinValLat_Summer_Dst2550 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MaxValLat_Summer_Dst2550 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MinValLatMlt_Summer_Dst2550_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )
MaxValLatMlt_Summer_Dst2550_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )

MinValLat_Summer_Dst5075 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MaxValLat_Summer_Dst5075 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MinValLatMlt_Summer_Dst5075_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )
MaxValLatMlt_Summer_Dst5075_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )


MinValLat_Summer_Dst75 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MaxValLat_Summer_Dst75 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MinValLatMlt_Summer_Dst75_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )
MaxValLatMlt_Summer_Dst75_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )




MinValLat_Winter_Dst1010 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MaxValLat_Winter_Dst1010 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MinValLatMlt_Winter_Dst1010_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )
MaxValLatMlt_Winter_Dst1010_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )

MinValLat_Winter_Dst1025 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MaxValLat_Winter_Dst1025 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MinValLatMlt_Winter_Dst1025_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )
MaxValLatMlt_Winter_Dst1025_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )

MinValLat_Winter_Dst2550 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MaxValLat_Winter_Dst2550 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MinValLatMlt_Winter_Dst2550_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )
MaxValLatMlt_Winter_Dst2550_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )

MinValLat_Winter_Dst5075 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MaxValLat_Winter_Dst5075 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MinValLatMlt_Winter_Dst5075_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )
MaxValLatMlt_Winter_Dst5075_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )


MinValLat_Winter_Dst75 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MaxValLat_Winter_Dst75 = fltarr(n_elements(Uniq_Mlts_SAPS) )
MinValLatMlt_Winter_Dst75_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )
MaxValLatMlt_Winter_Dst75_stereo = fltarr(n_elements(Uniq_Mlts_SAPS),2 )





for jjj = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin
	
	
	if ( jindsPltLocsFilter_Summer_Dst1010[0] ne -1 ) then begin
		MltsAllMlts_Summer_Dst1010 = MeanValMlt_Summer_Dst1010[jindsPltLocsFilter_Summer_Dst1010]
		latsAllMlts_Summer_Dst1010 = MeanValLat_Summer_Dst1010[jindsPltLocsFilter_Summer_Dst1010]
		JindsThisMltLats_Summer_Dst1010 = where( MltsAllMlts_Summer_Dst1010 eq Uniq_Mlts_SAPS[jjj] )
		
		if (JindsThisMltLats_Summer_Dst1010[0] ne -1) then begin
			MinValLat_Summer_Dst1010[jjj] = min( latsAllMlts_Summer_Dst1010[JindsThisMltLats_Summer_Dst1010] ) 
			MaxValLat_Summer_Dst1010[jjj] = max( latsAllMlts_Summer_Dst1010[JindsThisMltLats_Summer_Dst1010] ) 
			
			
			
			minstereCr = calc_stereo_coords( MinValLat_Summer_Dst1010[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			maxstereCr = calc_stereo_coords( MaxValLat_Summer_Dst1010[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			
			MinValLatMlt_Summer_Dst1010_stereo[jjj,0] = minstereCr[0]
			MinValLatMlt_Summer_Dst1010_stereo[jjj,1] = minstereCr[1]
			
			MaxValLatMlt_Summer_Dst1010_stereo[jjj,0] = maxstereCr[0]
			MaxValLatMlt_Summer_Dst1010_stereo[jjj,1] = maxstereCr[1]
			
			
		endif else begin
			MinValLat_Summer_Dst1010[jjj] = !values.f_nan
			MaxValLat_Summer_Dst1010[jjj] = !values.f_nan

			MinValLatMlt_Summer_Dst1010_stereo[jjj,0] = !values.f_nan
			MinValLatMlt_Summer_Dst1010_stereo[jjj,1] = !values.f_nan
			
			MaxValLatMlt_Summer_Dst1010_stereo[jjj,0] = !values.f_nan
			MaxValLatMlt_Summer_Dst1010_stereo[jjj,1] = !values.f_nan
			
		endelse
	endif else begin
		MinValLat_Summer_Dst1010[jjj] = !values.f_nan
		MaxValLat_Summer_Dst1010[jjj] = !values.f_nan		

		MinValLatMlt_Summer_Dst1010_stereo[jjj,0] = !values.f_nan
		MinValLatMlt_Summer_Dst1010_stereo[jjj,1] = !values.f_nan
		
		MaxValLatMlt_Summer_Dst1010_stereo[jjj,0] = !values.f_nan
		MaxValLatMlt_Summer_Dst1010_stereo[jjj,1] = !values.f_nan
	endelse

	
	
	if ( jindsPltLocsFilter_Summer_Dst1025[0] ne -1 ) then begin
		MltsAllMlts_Summer_Dst1025 = MeanValMlt_Summer_Dst1025[jindsPltLocsFilter_Summer_Dst1025]
		latsAllMlts_Summer_Dst1025 = MeanValLat_Summer_Dst1025[jindsPltLocsFilter_Summer_Dst1025]
		JindsThisMltLats_Summer_Dst1025 = where( MltsAllMlts_Summer_Dst1025 eq Uniq_Mlts_SAPS[jjj] )
		
		if (JindsThisMltLats_Summer_Dst1025[0] ne -1) then begin
			MinValLat_Summer_Dst1025[jjj] = min( latsAllMlts_Summer_Dst1025[JindsThisMltLats_Summer_Dst1025] ) 
			MaxValLat_Summer_Dst1025[jjj] = max( latsAllMlts_Summer_Dst1025[JindsThisMltLats_Summer_Dst1025] ) 
			
			minstereCr = calc_stereo_coords( MinValLat_Summer_Dst1025[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			maxstereCr = calc_stereo_coords( MaxValLat_Summer_Dst1025[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			
			MinValLatMlt_Summer_Dst1025_stereo[jjj,0] = minstereCr[0]
			MinValLatMlt_Summer_Dst1025_stereo[jjj,1] = minstereCr[1]
			
			MaxValLatMlt_Summer_Dst1025_stereo[jjj,0] = maxstereCr[0]
			MaxValLatMlt_Summer_Dst1025_stereo[jjj,1] = maxstereCr[1]
			
			
		endif else begin
			MinValLat_Summer_Dst1025[jjj] = !values.f_nan
			MaxValLat_Summer_Dst1025[jjj] = !values.f_nan

			MinValLatMlt_Summer_Dst1025_stereo[jjj,0] = !values.f_nan
			MinValLatMlt_Summer_Dst1025_stereo[jjj,1] = !values.f_nan
			
			MaxValLatMlt_Summer_Dst1025_stereo[jjj,0] = !values.f_nan
			MaxValLatMlt_Summer_Dst1025_stereo[jjj,1] = !values.f_nan
			
		endelse
	endif else begin
		MinValLat_Summer_Dst1025[jjj] = !values.f_nan
		MaxValLat_Summer_Dst1025[jjj] = !values.f_nan		

		MinValLatMlt_Summer_Dst1025_stereo[jjj,0] = !values.f_nan
		MinValLatMlt_Summer_Dst1025_stereo[jjj,1] = !values.f_nan
		
		MaxValLatMlt_Summer_Dst1025_stereo[jjj,0] = !values.f_nan
		MaxValLatMlt_Summer_Dst1025_stereo[jjj,1] = !values.f_nan
	endelse
	
	
	
	
	if ( jindsPltLocsFilter_Summer_Dst2550[0] ne -1 ) then begin
		MltsAllMlts_Summer_Dst2550 = MeanValMlt_Summer_Dst2550[jindsPltLocsFilter_Summer_Dst2550]
		latsAllMlts_Summer_Dst2550 = MeanValLat_Summer_Dst2550[jindsPltLocsFilter_Summer_Dst2550]
		JindsThisMltLats_Summer_Dst2550 = where( MltsAllMlts_Summer_Dst2550 eq Uniq_Mlts_SAPS[jjj] )
		
; 		if ( (Uniq_Mlts_SAPS[jjj] eq 23.0) or (Uniq_Mlts_SAPS[jjj] eq 0.0) ) then begin
; 			print, latsAllMlts_Summer_Dst2550[JindsThisMltLats_Summer_Dst2550]
; 		endif
		
		if (JindsThisMltLats_Summer_Dst2550[0] ne -1) then begin
			MinValLat_Summer_Dst2550[jjj] = min( latsAllMlts_Summer_Dst2550[JindsThisMltLats_Summer_Dst2550] ) 
			MaxValLat_Summer_Dst2550[jjj] = max( latsAllMlts_Summer_Dst2550[JindsThisMltLats_Summer_Dst2550] ) 
			
			

			minstereCr = calc_stereo_coords( MinValLat_Summer_Dst2550[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			maxstereCr = calc_stereo_coords( MaxValLat_Summer_Dst2550[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			
			MinValLatMlt_Summer_Dst2550_stereo[jjj,0] = minstereCr[0]
			MinValLatMlt_Summer_Dst2550_stereo[jjj,1] = minstereCr[1]
			
			MaxValLatMlt_Summer_Dst2550_stereo[jjj,0] = maxstereCr[0]
			MaxValLatMlt_Summer_Dst2550_stereo[jjj,1] = maxstereCr[1]
			
			
		endif else begin
			MinValLat_Summer_Dst2550[jjj] = !values.f_nan
			MaxValLat_Summer_Dst2550[jjj] = !values.f_nan

			MinValLatMlt_Summer_Dst2550_stereo[jjj,0] = !values.f_nan
			MinValLatMlt_Summer_Dst2550_stereo[jjj,1] = !values.f_nan
			
			MaxValLatMlt_Summer_Dst2550_stereo[jjj,0] = !values.f_nan
			MaxValLatMlt_Summer_Dst2550_stereo[jjj,1] = !values.f_nan
			
		endelse
	endif else begin
		MinValLat_Summer_Dst2550[jjj] = !values.f_nan
		MaxValLat_Summer_Dst2550[jjj] = !values.f_nan		

		MinValLatMlt_Summer_Dst2550_stereo[jjj,0] = !values.f_nan
		MinValLatMlt_Summer_Dst2550_stereo[jjj,1] = !values.f_nan
		
		MaxValLatMlt_Summer_Dst2550_stereo[jjj,0] = !values.f_nan
		MaxValLatMlt_Summer_Dst2550_stereo[jjj,1] = !values.f_nan
	endelse

	
; 	print, MinValLatMlt_Summer_Dst2550_stereo[jjj,0],MinValLatMlt_Summer_Dst2550_stereo[jjj,1], Uniq_Mlts_SAPS[jjj]
	
	if ( jindsPltLocsFilter_Summer_Dst5075[0] ne -1 ) then begin
		MltsAllMlts_Summer_Dst5075 = MeanValMlt_Summer_Dst5075[jindsPltLocsFilter_Summer_Dst5075]
		latsAllMlts_Summer_Dst5075 = MeanValLat_Summer_Dst5075[jindsPltLocsFilter_Summer_Dst5075]
		JindsThisMltLats_Summer_Dst5075 = where( MltsAllMlts_Summer_Dst5075 eq Uniq_Mlts_SAPS[jjj] )
		
		if (JindsThisMltLats_Summer_Dst5075[0] ne -1) then begin
			MinValLat_Summer_Dst5075[jjj] = min( latsAllMlts_Summer_Dst5075[JindsThisMltLats_Summer_Dst5075] ) 
			MaxValLat_Summer_Dst5075[jjj] = max( latsAllMlts_Summer_Dst5075[JindsThisMltLats_Summer_Dst5075] ) 
			
			minstereCr = calc_stereo_coords( MinValLat_Summer_Dst5075[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			maxstereCr = calc_stereo_coords( MaxValLat_Summer_Dst5075[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			
			MinValLatMlt_Summer_Dst5075_stereo[jjj,0] = minstereCr[0]
			MinValLatMlt_Summer_Dst5075_stereo[jjj,1] = minstereCr[1]
			
			MaxValLatMlt_Summer_Dst5075_stereo[jjj,0] = maxstereCr[0]
			MaxValLatMlt_Summer_Dst5075_stereo[jjj,1] = maxstereCr[1]
			
			
		endif else begin
			MinValLat_Summer_Dst5075[jjj] = !values.f_nan
			MaxValLat_Summer_Dst5075[jjj] = !values.f_nan

			MinValLatMlt_Summer_Dst5075_stereo[jjj,0] = !values.f_nan
			MinValLatMlt_Summer_Dst5075_stereo[jjj,1] = !values.f_nan
			
			MaxValLatMlt_Summer_Dst5075_stereo[jjj,0] = !values.f_nan
			MaxValLatMlt_Summer_Dst5075_stereo[jjj,1] = !values.f_nan
			
		endelse
	endif else begin
		MinValLat_Summer_Dst5075[jjj] = !values.f_nan
		MaxValLat_Summer_Dst5075[jjj] = !values.f_nan		

		MinValLatMlt_Summer_Dst5075_stereo[jjj,0] = !values.f_nan
		MinValLatMlt_Summer_Dst5075_stereo[jjj,1] = !values.f_nan
		
		MaxValLatMlt_Summer_Dst5075_stereo[jjj,0] = !values.f_nan
		MaxValLatMlt_Summer_Dst5075_stereo[jjj,1] = !values.f_nan
	endelse


	
	
	
	
	
	if ( jindsPltLocsFilter_Summer_Dst75[0] ne -1 ) then begin
		MltsAllMlts_Summer_Dst75 = MeanValMlt_Summer_Dst75[jindsPltLocsFilter_Summer_Dst75]
		latsAllMlts_Summer_Dst75 = MeanValLat_Summer_Dst75[jindsPltLocsFilter_Summer_Dst75]
		JindsThisMltLats_Summer_Dst75 = where( MltsAllMlts_Summer_Dst75 eq Uniq_Mlts_SAPS[jjj] )
		
		if (JindsThisMltLats_Summer_Dst75[0] ne -1) then begin
			MinValLat_Summer_Dst75[jjj] = min( latsAllMlts_Summer_Dst75[JindsThisMltLats_Summer_Dst75] ) 
			MaxValLat_Summer_Dst75[jjj] = max( latsAllMlts_Summer_Dst75[JindsThisMltLats_Summer_Dst75] ) 
			
			minstereCr = calc_stereo_coords( MinValLat_Summer_Dst75[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			maxstereCr = calc_stereo_coords( MaxValLat_Summer_Dst75[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			
			MinValLatMlt_Summer_Dst75_stereo[jjj,0] = minstereCr[0]
			MinValLatMlt_Summer_Dst75_stereo[jjj,1] = minstereCr[1]
			
			MaxValLatMlt_Summer_Dst75_stereo[jjj,0] = maxstereCr[0]
			MaxValLatMlt_Summer_Dst75_stereo[jjj,1] = maxstereCr[1]
			
			
		endif else begin
			MinValLat_Summer_Dst75[jjj] = !values.f_nan
			MaxValLat_Summer_Dst75[jjj] = !values.f_nan

			MinValLatMlt_Summer_Dst75_stereo[jjj,0] = !values.f_nan
			MinValLatMlt_Summer_Dst75_stereo[jjj,1] = !values.f_nan
			
			MaxValLatMlt_Summer_Dst75_stereo[jjj,0] = !values.f_nan
			MaxValLatMlt_Summer_Dst75_stereo[jjj,1] = !values.f_nan
			
		endelse
	endif else begin
		MinValLat_Summer_Dst75[jjj] = !values.f_nan
		MaxValLat_Summer_Dst75[jjj] = !values.f_nan		

		MinValLatMlt_Summer_Dst75_stereo[jjj,0] = !values.f_nan
		MinValLatMlt_Summer_Dst75_stereo[jjj,1] = !values.f_nan
		
		MaxValLatMlt_Summer_Dst75_stereo[jjj,0] = !values.f_nan
		MaxValLatMlt_Summer_Dst75_stereo[jjj,1] = !values.f_nan
	endelse
	
	
	
	
	
	

	
	
	
	
	
	if ( jindsPltLocsFilter_Winter_Dst1010[0] ne -1 ) then begin
		MltsAllMlts_Winter_Dst1010 = MeanValMlt_Winter_Dst1010[jindsPltLocsFilter_Winter_Dst1010]
		latsAllMlts_Winter_Dst1010 = MeanValLat_Winter_Dst1010[jindsPltLocsFilter_Winter_Dst1010]
		JindsThisMltLats_Winter_Dst1010 = where( MltsAllMlts_Winter_Dst1010 eq Uniq_Mlts_SAPS[jjj] )
		
		if (JindsThisMltLats_Winter_Dst1010[0] ne -1) then begin
			MinValLat_Winter_Dst1010[jjj] = min( latsAllMlts_Winter_Dst1010[JindsThisMltLats_Winter_Dst1010] ) 
			MaxValLat_Winter_Dst1010[jjj] = max( latsAllMlts_Winter_Dst1010[JindsThisMltLats_Winter_Dst1010] ) 
			
			minstereCr = calc_stereo_coords( MinValLat_Winter_Dst1010[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			maxstereCr = calc_stereo_coords( MaxValLat_Winter_Dst1010[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			
			MinValLatMlt_Winter_Dst1010_stereo[jjj,0] = minstereCr[0]
			MinValLatMlt_Winter_Dst1010_stereo[jjj,1] = minstereCr[1]
			
			MaxValLatMlt_Winter_Dst1010_stereo[jjj,0] = maxstereCr[0]
			MaxValLatMlt_Winter_Dst1010_stereo[jjj,1] = maxstereCr[1]
			
			
		endif else begin
			MinValLat_Winter_Dst1010[jjj] = !values.f_nan
			MaxValLat_Winter_Dst1010[jjj] = !values.f_nan

			MinValLatMlt_Winter_Dst1010_stereo[jjj,0] = !values.f_nan
			MinValLatMlt_Winter_Dst1010_stereo[jjj,1] = !values.f_nan
			
			MaxValLatMlt_Winter_Dst1010_stereo[jjj,0] = !values.f_nan
			MaxValLatMlt_Winter_Dst1010_stereo[jjj,1] = !values.f_nan
			
		endelse
	endif else begin
		MinValLat_Winter_Dst1010[jjj] = !values.f_nan
		MaxValLat_Winter_Dst1010[jjj] = !values.f_nan		

		MinValLatMlt_Winter_Dst1010_stereo[jjj,0] = !values.f_nan
		MinValLatMlt_Winter_Dst1010_stereo[jjj,1] = !values.f_nan
		
		MaxValLatMlt_Winter_Dst1010_stereo[jjj,0] = !values.f_nan
		MaxValLatMlt_Winter_Dst1010_stereo[jjj,1] = !values.f_nan
	endelse

	
	
	if ( jindsPltLocsFilter_Winter_Dst1025[0] ne -1 ) then begin
		MltsAllMlts_Winter_Dst1025 = MeanValMlt_Winter_Dst1025[jindsPltLocsFilter_Winter_Dst1025]
		latsAllMlts_Winter_Dst1025 = MeanValLat_Winter_Dst1025[jindsPltLocsFilter_Winter_Dst1025]
		JindsThisMltLats_Winter_Dst1025 = where( MltsAllMlts_Winter_Dst1025 eq Uniq_Mlts_SAPS[jjj] )
		
		if (JindsThisMltLats_Winter_Dst1025[0] ne -1) then begin
			MinValLat_Winter_Dst1025[jjj] = min( latsAllMlts_Winter_Dst1025[JindsThisMltLats_Winter_Dst1025] ) 
			MaxValLat_Winter_Dst1025[jjj] = max( latsAllMlts_Winter_Dst1025[JindsThisMltLats_Winter_Dst1025] ) 
			
			minstereCr = calc_stereo_coords( MinValLat_Winter_Dst1025[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			maxstereCr = calc_stereo_coords( MaxValLat_Winter_Dst1025[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			
			MinValLatMlt_Winter_Dst1025_stereo[jjj,0] = minstereCr[0]
			MinValLatMlt_Winter_Dst1025_stereo[jjj,1] = minstereCr[1]
			
			MaxValLatMlt_Winter_Dst1025_stereo[jjj,0] = maxstereCr[0]
			MaxValLatMlt_Winter_Dst1025_stereo[jjj,1] = maxstereCr[1]
			
			
		endif else begin
			MinValLat_Winter_Dst1025[jjj] = !values.f_nan
			MaxValLat_Winter_Dst1025[jjj] = !values.f_nan

			MinValLatMlt_Winter_Dst1025_stereo[jjj,0] = !values.f_nan
			MinValLatMlt_Winter_Dst1025_stereo[jjj,1] = !values.f_nan
			
			MaxValLatMlt_Winter_Dst1025_stereo[jjj,0] = !values.f_nan
			MaxValLatMlt_Winter_Dst1025_stereo[jjj,1] = !values.f_nan
			
		endelse
	endif else begin
		MinValLat_Winter_Dst1025[jjj] = !values.f_nan
		MaxValLat_Winter_Dst1025[jjj] = !values.f_nan		

		MinValLatMlt_Winter_Dst1025_stereo[jjj,0] = !values.f_nan
		MinValLatMlt_Winter_Dst1025_stereo[jjj,1] = !values.f_nan
		
		MaxValLatMlt_Winter_Dst1025_stereo[jjj,0] = !values.f_nan
		MaxValLatMlt_Winter_Dst1025_stereo[jjj,1] = !values.f_nan
	endelse
	
	
	
	
	if ( jindsPltLocsFilter_Winter_Dst2550[0] ne -1 ) then begin
		MltsAllMlts_Winter_Dst2550 = MeanValMlt_Winter_Dst2550[jindsPltLocsFilter_Winter_Dst2550]
		latsAllMlts_Winter_Dst2550 = MeanValLat_Winter_Dst2550[jindsPltLocsFilter_Winter_Dst2550]
		JindsThisMltLats_Winter_Dst2550 = where( MltsAllMlts_Winter_Dst2550 eq Uniq_Mlts_SAPS[jjj] )
		
		if (JindsThisMltLats_Winter_Dst2550[0] ne -1) then begin
			MinValLat_Winter_Dst2550[jjj] = min( latsAllMlts_Winter_Dst2550[JindsThisMltLats_Winter_Dst2550] ) 
			MaxValLat_Winter_Dst2550[jjj] = max( latsAllMlts_Winter_Dst2550[JindsThisMltLats_Winter_Dst2550] ) 
			
			minstereCr = calc_stereo_coords( MinValLat_Winter_Dst2550[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			maxstereCr = calc_stereo_coords( MaxValLat_Winter_Dst2550[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			
			MinValLatMlt_Winter_Dst2550_stereo[jjj,0] = minstereCr[0]
			MinValLatMlt_Winter_Dst2550_stereo[jjj,1] = minstereCr[1]
			
			MaxValLatMlt_Winter_Dst2550_stereo[jjj,0] = maxstereCr[0]
			MaxValLatMlt_Winter_Dst2550_stereo[jjj,1] = maxstereCr[1]
			
			
		endif else begin
			MinValLat_Winter_Dst2550[jjj] = !values.f_nan
			MaxValLat_Winter_Dst2550[jjj] = !values.f_nan

			MinValLatMlt_Winter_Dst2550_stereo[jjj,0] = !values.f_nan
			MinValLatMlt_Winter_Dst2550_stereo[jjj,1] = !values.f_nan
			
			MaxValLatMlt_Winter_Dst2550_stereo[jjj,0] = !values.f_nan
			MaxValLatMlt_Winter_Dst2550_stereo[jjj,1] = !values.f_nan
			
		endelse
	endif else begin
		MinValLat_Winter_Dst2550[jjj] = !values.f_nan
		MaxValLat_Winter_Dst2550[jjj] = !values.f_nan		

		MinValLatMlt_Winter_Dst2550_stereo[jjj,0] = !values.f_nan
		MinValLatMlt_Winter_Dst2550_stereo[jjj,1] = !values.f_nan
		
		MaxValLatMlt_Winter_Dst2550_stereo[jjj,0] = !values.f_nan
		MaxValLatMlt_Winter_Dst2550_stereo[jjj,1] = !values.f_nan
	endelse


	
	
	if ( jindsPltLocsFilter_Winter_Dst5075[0] ne -1 ) then begin
		MltsAllMlts_Winter_Dst5075 = MeanValMlt_Winter_Dst5075[jindsPltLocsFilter_Winter_Dst5075]
		latsAllMlts_Winter_Dst5075 = MeanValLat_Winter_Dst5075[jindsPltLocsFilter_Winter_Dst5075]
		JindsThisMltLats_Winter_Dst5075 = where( MltsAllMlts_Winter_Dst5075 eq Uniq_Mlts_SAPS[jjj] )
		
		if (JindsThisMltLats_Winter_Dst5075[0] ne -1) then begin
			MinValLat_Winter_Dst5075[jjj] = min( latsAllMlts_Winter_Dst5075[JindsThisMltLats_Winter_Dst5075] ) 
			MaxValLat_Winter_Dst5075[jjj] = max( latsAllMlts_Winter_Dst5075[JindsThisMltLats_Winter_Dst5075] ) 
			
			minstereCr = calc_stereo_coords( MinValLat_Winter_Dst5075[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			maxstereCr = calc_stereo_coords( MaxValLat_Winter_Dst5075[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			
			MinValLatMlt_Winter_Dst5075_stereo[jjj,0] = minstereCr[0]
			MinValLatMlt_Winter_Dst5075_stereo[jjj,1] = minstereCr[1]
			
			MaxValLatMlt_Winter_Dst5075_stereo[jjj,0] = maxstereCr[0]
			MaxValLatMlt_Winter_Dst5075_stereo[jjj,1] = maxstereCr[1]
			
			
		endif else begin
			MinValLat_Winter_Dst5075[jjj] = !values.f_nan
			MaxValLat_Winter_Dst5075[jjj] = !values.f_nan

			MinValLatMlt_Winter_Dst5075_stereo[jjj,0] = !values.f_nan
			MinValLatMlt_Winter_Dst5075_stereo[jjj,1] = !values.f_nan
			
			MaxValLatMlt_Winter_Dst5075_stereo[jjj,0] = !values.f_nan
			MaxValLatMlt_Winter_Dst5075_stereo[jjj,1] = !values.f_nan
			
		endelse
	endif else begin
		MinValLat_Winter_Dst5075[jjj] = !values.f_nan
		MaxValLat_Winter_Dst5075[jjj] = !values.f_nan		

		MinValLatMlt_Winter_Dst5075_stereo[jjj,0] = !values.f_nan
		MinValLatMlt_Winter_Dst5075_stereo[jjj,1] = !values.f_nan
		
		MaxValLatMlt_Winter_Dst5075_stereo[jjj,0] = !values.f_nan
		MaxValLatMlt_Winter_Dst5075_stereo[jjj,1] = !values.f_nan
	endelse


	
	
	
	
	
	if ( jindsPltLocsFilter_Winter_Dst75[0] ne -1 ) then begin
		MltsAllMlts_Winter_Dst75 = MeanValMlt_Winter_Dst75[jindsPltLocsFilter_Winter_Dst75]
		latsAllMlts_Winter_Dst75 = MeanValLat_Winter_Dst75[jindsPltLocsFilter_Winter_Dst75]
		JindsThisMltLats_Winter_Dst75 = where( MltsAllMlts_Winter_Dst75 eq Uniq_Mlts_SAPS[jjj] )
		
		if (JindsThisMltLats_Winter_Dst75[0] ne -1) then begin
			MinValLat_Winter_Dst75[jjj] = min( latsAllMlts_Winter_Dst75[JindsThisMltLats_Winter_Dst75] ) 
			MaxValLat_Winter_Dst75[jjj] = max( latsAllMlts_Winter_Dst75[JindsThisMltLats_Winter_Dst75] ) 
			
			minstereCr = calc_stereo_coords( MinValLat_Winter_Dst75[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			maxstereCr = calc_stereo_coords( MaxValLat_Winter_Dst75[jjj], Uniq_Mlts_SAPS[jjj], /mlt )
			
			MinValLatMlt_Winter_Dst75_stereo[jjj,0] = minstereCr[0]
			MinValLatMlt_Winter_Dst75_stereo[jjj,1] = minstereCr[1]
			
			MaxValLatMlt_Winter_Dst75_stereo[jjj,0] = maxstereCr[0]
			MaxValLatMlt_Winter_Dst75_stereo[jjj,1] = maxstereCr[1]
			
			
		endif else begin
			MinValLat_Winter_Dst75[jjj] = !values.f_nan
			MaxValLat_Winter_Dst75[jjj] = !values.f_nan

			MinValLatMlt_Winter_Dst75_stereo[jjj,0] = !values.f_nan
			MinValLatMlt_Winter_Dst75_stereo[jjj,1] = !values.f_nan
			
			MaxValLatMlt_Winter_Dst75_stereo[jjj,0] = !values.f_nan
			MaxValLatMlt_Winter_Dst75_stereo[jjj,1] = !values.f_nan
			
		endelse
	endif else begin
		MinValLat_Winter_Dst75[jjj] = !values.f_nan
		MaxValLat_Winter_Dst75[jjj] = !values.f_nan		

		MinValLatMlt_Winter_Dst75_stereo[jjj,0] = !values.f_nan
		MinValLatMlt_Winter_Dst75_stereo[jjj,1] = !values.f_nan
		
		MaxValLatMlt_Winter_Dst75_stereo[jjj,0] = !values.f_nan
		MaxValLatMlt_Winter_Dst75_stereo[jjj,1] = !values.f_nan
	endelse


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

endfor




ps_open,'/home/bharat/ESAPS/Finstats/NumPnts_Dst_Cmpr.ps'

clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[0], charsize = 0.5

oplot, [MinValLatMlt_Summer_Dst1010_stereo[*,0]], [MinValLatMlt_Summer_Dst1010_stereo[*,1]], color = get_black(), thick = 7.5
oplot, [MinValLatMlt_Summer_Dst1010_stereo[0,0],MinValLatMlt_Summer_Dst1010_stereo[23,0]], [MinValLatMlt_Summer_Dst1010_stereo[0,1],MinValLatMlt_Summer_Dst1010_stereo[23,1]], color = get_black(), thick = 7.5

oplot, [MaxValLatMlt_Summer_Dst1010_stereo[*,0]], [MaxValLatMlt_Summer_Dst1010_stereo[*,1]], color = get_black(), thick = 7.5
oplot, [MaxValLatMlt_Summer_Dst1010_stereo[0,0],MaxValLatMlt_Summer_Dst1010_stereo[23,0]], [MaxValLatMlt_Summer_Dst1010_stereo[0,1],MaxValLatMlt_Summer_Dst1010_stereo[23,1]], color = get_black(), thick = 7.5



map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[1], charsize = 0.5

oplot, [MinValLatMlt_Summer_Dst1025_stereo[*,0]], [MinValLatMlt_Summer_Dst1025_stereo[*,1]], color = get_blue(), thick = 7.5
oplot, [MinValLatMlt_Summer_Dst1025_stereo[0,0],MinValLatMlt_Summer_Dst1025_stereo[23,0]], [MinValLatMlt_Summer_Dst1025_stereo[0,1],MinValLatMlt_Summer_Dst1025_stereo[23,1]], color = get_blue(), thick = 7.5

oplot, [MaxValLatMlt_Summer_Dst1025_stereo[*,0]], [MaxValLatMlt_Summer_Dst1025_stereo[*,1]], color = get_blue(), thick = 7.5
oplot, [MaxValLatMlt_Summer_Dst1025_stereo[0,0],MaxValLatMlt_Summer_Dst1025_stereo[23,0]], [MaxValLatMlt_Summer_Dst1025_stereo[0,1],MaxValLatMlt_Summer_Dst1025_stereo[23,1]], color = get_blue(), thick = 7.5



map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[2], charsize = 0.5

oplot, [MinValLatMlt_Summer_Dst2550_stereo[*,0]], [MinValLatMlt_Summer_Dst2550_stereo[*,1]], color = get_green(), thick = 7.5
oplot, [MinValLatMlt_Summer_Dst2550_stereo[0,0],MinValLatMlt_Summer_Dst2550_stereo[23,0]], [MinValLatMlt_Summer_Dst2550_stereo[0,1],MinValLatMlt_Summer_Dst2550_stereo[23,1]], color = get_green(), thick = 7.5

oplot, [MaxValLatMlt_Summer_Dst2550_stereo[*,0]], [MaxValLatMlt_Summer_Dst2550_stereo[*,1]], color = get_green(), thick = 7.5
oplot, [MaxValLatMlt_Summer_Dst2550_stereo[0,0],MaxValLatMlt_Summer_Dst2550_stereo[23,0]], [MaxValLatMlt_Summer_Dst2550_stereo[0,1],MaxValLatMlt_Summer_Dst2550_stereo[23,1]], color = get_green(), thick = 7.5




map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[3], charsize = 0.5

oplot, [MinValLatMlt_Summer_Dst5075_stereo[*,0]], [MinValLatMlt_Summer_Dst5075_stereo[*,1]], color = get_yellow(), thick = 7.5
oplot, [MinValLatMlt_Summer_Dst5075_stereo[0,0],MinValLatMlt_Summer_Dst5075_stereo[23,0]], [MinValLatMlt_Summer_Dst5075_stereo[0,1],MinValLatMlt_Summer_Dst5075_stereo[23,1]], color = get_yellow(), thick = 7.5

oplot, [MaxValLatMlt_Summer_Dst5075_stereo[*,0]], [MaxValLatMlt_Summer_Dst5075_stereo[*,1]], color = get_yellow(), thick = 7.5
oplot, [MaxValLatMlt_Summer_Dst5075_stereo[0,0],MaxValLatMlt_Summer_Dst5075_stereo[23,0]], [MaxValLatMlt_Summer_Dst5075_stereo[0,1],MaxValLatMlt_Summer_Dst5075_stereo[23,1]], color = get_yellow(), thick = 7.5



map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0.5,2,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[4], charsize = 0.5

oplot, [MinValLatMlt_Summer_Dst75_stereo[*,0]], [MinValLatMlt_Summer_Dst75_stereo[*,1]], color = get_red(), thick = 7.5
oplot, [MinValLatMlt_Summer_Dst75_stereo[0,0],MinValLatMlt_Summer_Dst75_stereo[23,0]], [MinValLatMlt_Summer_Dst75_stereo[0,1],MinValLatMlt_Summer_Dst75_stereo[23,1]], color = get_red(), thick = 7.5

oplot, [MaxValLatMlt_Summer_Dst75_stereo[*,0]], [MaxValLatMlt_Summer_Dst75_stereo[*,1]], color = get_red(), thick = 7.5
oplot, [MaxValLatMlt_Summer_Dst75_stereo[0,0],MaxValLatMlt_Summer_Dst75_stereo[23,0]], [MaxValLatMlt_Summer_Dst75_stereo[0,1],MaxValLatMlt_Summer_Dst75_stereo[23,1]], color = get_red(), thick = 7.5



; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleNumPntsSAPS,legend='Prob. of Occurrence',param='power', level_format = '(f6.2)'



; clear_page
; map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Winter'
; 
; oplot, [MinValLatMlt_Winter_Dst1010_stereo[*,0]], [MinValLatMlt_Winter_Dst1010_stereo[*,1]], color = get_black(), thick = 7.5
; oplot, [MinValLatMlt_Winter_Dst1010_stereo[0,0],MinValLatMlt_Winter_Dst1010_stereo[23,0]], [MinValLatMlt_Winter_Dst1010_stereo[0,1],MinValLatMlt_Winter_Dst1010_stereo[23,1]], color = get_black(), thick = 7.5
; 
; oplot, [MinValLatMlt_Winter_Dst1025_stereo[*,0]], [MinValLatMlt_Winter_Dst1025_stereo[*,1]], color = get_blue(), thick = 7.5
; oplot, [MinValLatMlt_Winter_Dst1025_stereo[0,0],MinValLatMlt_Winter_Dst1025_stereo[23,0]], [MinValLatMlt_Winter_Dst1025_stereo[0,1],MinValLatMlt_Winter_Dst1025_stereo[23,1]], color = get_blue(), thick = 7.5
; 
; oplot, [MinValLatMlt_Winter_Dst2550_stereo[*,0]], [MinValLatMlt_Winter_Dst2550_stereo[*,1]], color = get_green(), thick = 7.5
; oplot, [MinValLatMlt_Winter_Dst2550_stereo[0,0],MinValLatMlt_Winter_Dst2550_stereo[23,0]], [MinValLatMlt_Winter_Dst2550_stereo[0,1],MinValLatMlt_Winter_Dst2550_stereo[23,1]], color = get_green(), thick = 7.5
; 
; oplot, [MinValLatMlt_Winter_Dst5075_stereo[*,0]], [MinValLatMlt_Winter_Dst5075_stereo[*,1]], color = get_yellow(), thick = 7.5
; oplot, [MinValLatMlt_Winter_Dst5075_stereo[0,0],MinValLatMlt_Winter_Dst5075_stereo[23,0]], [MinValLatMlt_Winter_Dst5075_stereo[0,1],MinValLatMlt_Winter_Dst5075_stereo[23,1]], color = get_yellow(), thick = 7.5
; 
; oplot, [MinValLatMlt_Winter_Dst75_stereo[*,0]], [MinValLatMlt_Winter_Dst75_stereo[*,1]], color = get_red(), thick = 7.5
; oplot, [MinValLatMlt_Winter_Dst75_stereo[0,0],MinValLatMlt_Winter_Dst75_stereo[23,0]], [MinValLatMlt_Winter_Dst75_stereo[0,1],MinValLatMlt_Winter_Dst75_stereo[23,1]], color = get_red(), thick = 7.5
; 
; 
; ; print, 'hi'
; ; print,MaxValLatMlt_Summer_Dst5075_stereo
; 
; oplot, [MaxValLatMlt_Winter_Dst1010_stereo[*,0]], [MaxValLatMlt_Winter_Dst1010_stereo[*,1]], color = get_black(), thick = 7.5
; oplot, [MaxValLatMlt_Winter_Dst1010_stereo[0,0],MaxValLatMlt_Winter_Dst1010_stereo[23,0]], [MaxValLatMlt_Winter_Dst1010_stereo[0,1],MaxValLatMlt_Winter_Dst1010_stereo[23,1]], color = get_black(), thick = 7.5
; 
; oplot, [MaxValLatMlt_Winter_Dst1025_stereo[*,0]], [MaxValLatMlt_Winter_Dst1025_stereo[*,1]], color = get_blue(), thick = 7.5
; oplot, [MaxValLatMlt_Winter_Dst1025_stereo[0,0],MaxValLatMlt_Winter_Dst1025_stereo[23,0]], [MaxValLatMlt_Winter_Dst1025_stereo[0,1],MaxValLatMlt_Winter_Dst1025_stereo[23,1]], color = get_blue(), thick = 7.5
; 
; oplot, [MaxValLatMlt_Winter_Dst2550_stereo[*,0]], [MaxValLatMlt_Winter_Dst2550_stereo[*,1]], color = get_green(), thick = 7.5
; oplot, [MaxValLatMlt_Winter_Dst2550_stereo[0,0],MaxValLatMlt_Winter_Dst2550_stereo[23,0]], [MaxValLatMlt_Winter_Dst2550_stereo[0,1],MaxValLatMlt_Winter_Dst2550_stereo[23,1]], color = get_green(), thick = 7.5
; 
; oplot, [MaxValLatMlt_Winter_Dst5075_stereo[*,0]], [MaxValLatMlt_Winter_Dst5075_stereo[*,1]], color = get_yellow(), thick = 7.5
; oplot, [MaxValLatMlt_Winter_Dst5075_stereo[0,0],MaxValLatMlt_Winter_Dst5075_stereo[23,0]], [MaxValLatMlt_Winter_Dst5075_stereo[0,1],MaxValLatMlt_Winter_Dst5075_stereo[23,1]], color = get_yellow(), thick = 7.5
; 
; oplot, [MaxValLatMlt_Winter_Dst75_stereo[*,0]], [MaxValLatMlt_Winter_Dst75_stereo[*,1]], color = get_red(), thick = 7.5
; oplot, [MaxValLatMlt_Winter_Dst75_stereo[0,0],MaxValLatMlt_Winter_Dst75_stereo[23,0]], [MaxValLatMlt_Winter_Dst75_stereo[0,1],MaxValLatMlt_Winter_Dst75_stereo[23,1]], color = get_red(), thick = 7.5


; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=scaleNumPntsSAPS,legend='Prob. of Occurrence',param='power', level_format = '(f6.2)'

ps_close,/no_filename







end
