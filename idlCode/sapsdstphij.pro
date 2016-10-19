pro sapsdstphij

load_usersym, /circle

rad_load_colortable,/leicester

fname_saps='/home/bharat/ESAPS/files/goodCond_saps_2011_2012-new.txt' 

date = 20110403
time = 0400
coords = 'mlt'
xrangePlot = [-44, 44]
yrangePlot = [-44,20]

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
title_str_noseas = [ 'Dst < 10 and > -10 nT', 'Dst < -10 and > -25 nT', 'Dst < -25 and > -50 nT', 'Dst < -50 and > -75 nT', 'Dst < -75 nT' ]

Jinds_Winter_Dst1010 = where( ( ( SAPS_orig_DST_Final ge -10. ) and ( SAPS_orig_DST_Final lt 10. ) ) and ( SAPS_events_months ge 10. or SAPS_events_months le 3. ) )
Jinds_Winter_Dst1025 = where( ( ( SAPS_orig_DST_Final ge -25. ) and ( SAPS_orig_DST_Final lt -10. ) ) and ( SAPS_events_months ge 10. or SAPS_events_months le 3. ) )
Jinds_Winter_Dst2550 = where( ( ( SAPS_orig_DST_Final ge -50. ) and ( SAPS_orig_DST_Final lt -25. ) ) and ( SAPS_events_months ge 10. or SAPS_events_months le 3. ) )
Jinds_Winter_Dst5075 = where( ( ( SAPS_orig_DST_Final ge -75. ) and ( SAPS_orig_DST_Final lt -50. ) ) and ( SAPS_events_months ge 10. or SAPS_events_months le 3. ) )
Jinds_Winter_Dst75 = where( ( ( SAPS_orig_DST_Final lt -75. ) ) and ( SAPS_events_months ge 10. or SAPS_events_months le 3. ) )



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

SAPS_PCond_Summer_Dst1010 = SAPS_orig_PCOND_Final[ Jinds_Summer_Dst1010 ]
SAPS_PCond_Summer_Dst1025 = SAPS_orig_PCOND_Final[ Jinds_Summer_Dst1025 ]
SAPS_PCond_Summer_Dst2550 = SAPS_orig_PCOND_Final[ Jinds_Summer_Dst2550 ]
SAPS_PCond_Summer_Dst5075 = SAPS_orig_PCOND_Final[ Jinds_Summer_Dst5075 ]
SAPS_PCond_Summer_Dst75 = SAPS_orig_PCOND_Final[ Jinds_Summer_Dst75 ]



SAPS_PCond_Winter_Dst1010 = SAPS_orig_PCOND_Final[ Jinds_Winter_Dst1010 ]
SAPS_PCond_Winter_Dst1025 = SAPS_orig_PCOND_Final[ Jinds_Winter_Dst1025 ]
SAPS_PCond_Winter_Dst2550 = SAPS_orig_PCOND_Final[ Jinds_Winter_Dst2550 ]
SAPS_PCond_Winter_Dst5075 = SAPS_orig_PCOND_Final[ Jinds_Winter_Dst5075 ]
SAPS_PCond_Winter_Dst75 = SAPS_orig_PCOND_Final[ Jinds_Winter_Dst75 ]

SAPS_HCond_Summer_Dst1010 = SAPS_orig_HCond_Final[ Jinds_Summer_Dst1010 ]
SAPS_HCond_Summer_Dst1025 = SAPS_orig_HCond_Final[ Jinds_Summer_Dst1025 ]
SAPS_HCond_Summer_Dst2550 = SAPS_orig_HCond_Final[ Jinds_Summer_Dst2550 ]
SAPS_HCond_Summer_Dst5075 = SAPS_orig_HCond_Final[ Jinds_Summer_Dst5075 ]
SAPS_HCond_Summer_Dst75 = SAPS_orig_HCond_Final[ Jinds_Summer_Dst75 ]



SAPS_HCond_Winter_Dst1010 = SAPS_orig_HCond_Final[ Jinds_Winter_Dst1010 ]
SAPS_HCond_Winter_Dst1025 = SAPS_orig_HCond_Final[ Jinds_Winter_Dst1025 ]
SAPS_HCond_Winter_Dst2550 = SAPS_orig_HCond_Final[ Jinds_Winter_Dst2550 ]
SAPS_HCond_Winter_Dst5075 = SAPS_orig_HCond_Final[ Jinds_Winter_Dst5075 ]
SAPS_HCond_Winter_Dst75 = SAPS_orig_HCond_Final[ Jinds_Winter_Dst75 ]


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

Npnts_chk_Summer_Dst1010_arr =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Summer_Dst1025_arr =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Summer_Dst2550_arr =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Summer_Dst5075_arr =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Summer_Dst75_arr =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

Npnts_chk_Winter_Dst1010_arr =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Winter_Dst1025_arr =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Winter_Dst2550_arr =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Winter_Dst5075_arr =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
Npnts_chk_Winter_Dst75_arr =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

CountCheck_Bh11 = 0

MeanPCond_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanPCond_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanPCond_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanPCond_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanPCond_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )



MeanPCond_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanPCond_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanPCond_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanPCond_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanPCond_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanHCond_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanHCond_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanHCond_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanHCond_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanHCond_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )



MeanHCond_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanHCond_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanHCond_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanHCond_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanHCond_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

for tt1 = 0,n_elements(Uniq_lats_SAPS)-1 do begin
	for b22 = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin
		
		
		Jinds_Check_bh11_Summer_Dst1010 = where( (SAPS_lats_Summer_Dst1010 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Summer_Dst1010 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Summer_Dst1010_arr[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Summer_Dst1010)
		
		Jinds_Check_bh11_Summer_Dst1025 = where( (SAPS_lats_Summer_Dst1025 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Summer_Dst1025 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Summer_Dst1025_arr[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Summer_Dst1025)
		
		Jinds_Check_bh11_Summer_Dst2550 = where( (SAPS_lats_Summer_Dst2550 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Summer_Dst2550 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Summer_Dst2550_arr[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Summer_Dst2550)
		
		Jinds_Check_bh11_Summer_Dst5075 = where( (SAPS_lats_Summer_Dst5075 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Summer_Dst5075 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Summer_Dst5075_arr[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Summer_Dst5075)
		
		Jinds_Check_bh11_Summer_Dst75 = where( (SAPS_lats_Summer_Dst75 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Summer_Dst75 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Summer_Dst75_arr[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Summer_Dst75)
		
		
		Jinds_Check_bh11_Winter_Dst1010 = where( (SAPS_lats_Winter_Dst1010 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Winter_Dst1010 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Winter_Dst1010_arr[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Winter_Dst1010)
		
		Jinds_Check_bh11_Winter_Dst1025 = where( (SAPS_lats_Winter_Dst1025 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Winter_Dst1025 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Winter_Dst1025_arr[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Winter_Dst1025)
		
		Jinds_Check_bh11_Winter_Dst2550 = where( (SAPS_lats_Winter_Dst2550 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Winter_Dst2550 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Winter_Dst2550_arr[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Winter_Dst2550)
		
		Jinds_Check_bh11_Winter_Dst5075 = where( (SAPS_lats_Winter_Dst5075 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Winter_Dst5075 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Winter_Dst5075_arr[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Winter_Dst5075)
		
		Jinds_Check_bh11_Winter_Dst75 = where( (SAPS_lats_Winter_Dst75 eq Uniq_lats_SAPS[tt1] ) and (SAPS_mlts_Winter_Dst75 eq Uniq_Mlts_SAPS[b22] ) )
		Npnts_chk_Winter_Dst75_arr[CountCheck_Bh11] = n_elements(Jinds_Check_bh11_Winter_Dst75)
				
; 		print, n_elements(Jinds_Check_bh11_Winter_Dst75), n_elements(Jinds_Check_bh11_Winter_Dst5075), n_elements(Jinds_Check_bh11_Winter_Dst2550), $
; 			n_elements(Jinds_Check_bh11_Winter_Dst1025),  n_elements(Jinds_Check_bh11_Winter_Dst1010), $
; 			Uniq_lats_SAPS[tt1], Uniq_Mlts_SAPS[b22]
		
		CountCheck_Bh11 = CountCheck_Bh11 + 1
		
	endfor
endfor



Npnts_chk_Summer_Dst1010 = max( Npnts_chk_Summer_Dst1010_arr )

Npnts_chk_Summer_Dst1025 = max( Npnts_chk_Summer_Dst1025_arr )
Npnts_chk_Summer_Dst2550 = max( Npnts_chk_Summer_Dst2550_arr )
Npnts_chk_Summer_Dst5075 = max( Npnts_chk_Summer_Dst5075_arr )
Npnts_chk_Summer_Dst75 = max( Npnts_chk_Summer_Dst75_arr )

Npnts_chk_Winter_Dst1010 = max( Npnts_chk_Winter_Dst1010_arr )
Npnts_chk_Winter_Dst1025 = max( Npnts_chk_Winter_Dst1025_arr )
Npnts_chk_Winter_Dst2550 = max( Npnts_chk_Winter_Dst2550_arr )
Npnts_chk_Winter_Dst5075 = max( Npnts_chk_Winter_Dst5075_arr )
Npnts_chk_Winter_Dst75 = max( Npnts_chk_Winter_Dst75_arr )

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
		

Perc_cutOff_Choose_vals = 0.25
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
				
				MeanPCond_Summer_Dst1010[Count_elems_chk] = mean(SAPS_PCond_Summer_Dst1010[JindsChkMean_Summer_Dst1010])
				MeanHCond_Summer_Dst1010[Count_elems_chk] = mean(SAPS_HCond_Summer_Dst1010[JindsChkMean_Summer_Dst1010]) 
				
			endif else begin
				MeanValVel_Summer_Dst1010[Count_elems_chk] = !values.f_nan
				MaxValVel_Summer_Dst1010[Count_elems_chk] = !values.f_nan
				MeanPCond_Summer_Dst1010[Count_elems_chk] = !values.f_nan
				MeanHCond_Summer_Dst1010[Count_elems_chk] = !values.f_nan
			endelse
			
		endif else begin
			MaxValVel_Summer_Dst1010[Count_elems_chk] = !values.f_nan
			MeanValVel_Summer_Dst1010[Count_elems_chk] = !values.f_nan
			MeanPCond_Summer_Dst1010[Count_elems_chk] = !values.f_nan
			MeanHCond_Summer_Dst1010[Count_elems_chk] = !values.f_nan
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
				
				MeanPCond_Summer_Dst1025[Count_elems_chk] = mean(SAPS_PCond_Summer_Dst1025[JindsChkMean_Summer_Dst1025])
				MeanHCond_Summer_Dst1025[Count_elems_chk] = mean(SAPS_HCond_Summer_Dst1025[JindsChkMean_Summer_Dst1025]) 
				
			endif else begin
				MeanValVel_Summer_Dst1025[Count_elems_chk] = !values.f_nan
				MaxValVel_Summer_Dst1025[Count_elems_chk] = !values.f_nan
				MeanPCond_Summer_Dst1025[Count_elems_chk] = !values.f_nan
				MeanHCond_Summer_Dst1025[Count_elems_chk] = !values.f_nan
			endelse

			
			
		endif else begin
			MeanValVel_Summer_Dst1025[Count_elems_chk] = !values.f_nan
			MaxValVel_Summer_Dst1025[Count_elems_chk] = !values.f_nan
			MeanPCond_Summer_Dst1025[Count_elems_chk] = !values.f_nan
			MeanHCond_Summer_Dst1025[Count_elems_chk] = !values.f_nan
		endelse

		MeanValLat_Summer_Dst1025[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Summer_Dst1025[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			
			
			
		JindsChkMean_Summer_Dst2550 = where( (SAPS_lats_Summer_Dst2550 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Summer_Dst2550 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Summer_Dst2550[0] ne -1 ) then begin
			
			NumPnts_Summer_Dst2550[Count_elems_chk] = n_elements(JindsChkMean_Summer_Dst2550)
			
			if ( n_elements(JindsChkMean_Summer_Dst2550) ge minElCheck_Summer[2] ) then begin		
				MeanValVel_Summer_Dst2550[Count_elems_chk] = mean(SAPS_vels_Summer_Dst2550[JindsChkMean_Summer_Dst2550]) 
				MaxValVel_Summer_Dst2550[Count_elems_chk] = max(SAPS_vels_Summer_Dst2550[JindsChkMean_Summer_Dst2550]) 
				
				MeanPCond_Summer_Dst2550[Count_elems_chk] = mean(SAPS_PCond_Summer_Dst2550[JindsChkMean_Summer_Dst2550]) 
				MeanHCond_Summer_Dst2550[Count_elems_chk] = mean(SAPS_HCond_Summer_Dst2550[JindsChkMean_Summer_Dst2550])

			endif else begin
				MeanValVel_Summer_Dst2550[Count_elems_chk] = !values.f_nan
				MaxValVel_Summer_Dst2550[Count_elems_chk] = !values.f_nan
				MeanPCond_Summer_Dst2550[Count_elems_chk] = !values.f_nan
				MeanHCond_Summer_Dst2550[Count_elems_chk] = !values.f_nan

			endelse

			
		endif else begin
			MeanValVel_Summer_Dst2550[Count_elems_chk] = !values.f_nan
			MaxValVel_Summer_Dst2550[Count_elems_chk] = !values.f_nan
			MeanPCond_Summer_Dst2550[Count_elems_chk] = !values.f_nan
			MeanHCond_Summer_Dst2550[Count_elems_chk] = !values.f_nan
		endelse

		MeanValLat_Summer_Dst2550[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Summer_Dst2550[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			

			
		JindsChkMean_Summer_Dst5075 = where( (SAPS_lats_Summer_Dst5075 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Summer_Dst5075 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Summer_Dst5075[0] ne -1 ) then begin
			
			NumPnts_Summer_Dst5075[Count_elems_chk] = n_elements(JindsChkMean_Summer_Dst5075)
			
			if ( n_elements(JindsChkMean_Summer_Dst5075) ge minElCheck_Summer[3] ) then begin		
				MeanValVel_Summer_Dst5075[Count_elems_chk] = mean(SAPS_vels_Summer_Dst5075[JindsChkMean_Summer_Dst5075]) 
				MaxValVel_Summer_Dst5075[Count_elems_chk] = max(SAPS_vels_Summer_Dst5075[JindsChkMean_Summer_Dst5075]) 
				MeanPCond_Summer_Dst5075[Count_elems_chk] = mean(SAPS_PCond_Summer_Dst5075[JindsChkMean_Summer_Dst5075]) 
				MeanHCond_Summer_Dst5075[Count_elems_chk] = mean(SAPS_HCond_Summer_Dst5075[JindsChkMean_Summer_Dst5075])

			endif else begin
				MeanValVel_Summer_Dst5075[Count_elems_chk] = !values.f_nan
				MaxValVel_Summer_Dst5075[Count_elems_chk] = !values.f_nan

				MeanPCond_Summer_Dst5075[Count_elems_chk] = !values.f_nan
				MeanHCond_Summer_Dst5075[Count_elems_chk] = !values.f_nan

			endelse

			
		endif else begin
			MeanValVel_Summer_Dst5075[Count_elems_chk] = !values.f_nan
			MaxValVel_Summer_Dst5075[Count_elems_chk] = !values.f_nan
			
			MeanPCond_Summer_Dst5075[Count_elems_chk] = !values.f_nan
			MeanHCond_Summer_Dst5075[Count_elems_chk] = !values.f_nan

		endelse	

		MeanValLat_Summer_Dst5075[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Summer_Dst5075[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			
			
	

		JindsChkMean_Summer_Dst75 = where( (SAPS_lats_Summer_Dst75 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Summer_Dst75 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Summer_Dst75[0] ne -1 ) then begin
		
			NumPnts_Summer_Dst75[Count_elems_chk] = n_elements(JindsChkMean_Summer_Dst75)
			
			if ( n_elements(JindsChkMean_Summer_Dst75) ge minElCheck_Summer[4] ) then begin		
				MeanValVel_Summer_Dst75[Count_elems_chk] = mean(SAPS_vels_Summer_Dst75[JindsChkMean_Summer_Dst75]) 
				MaxValVel_Summer_Dst75[Count_elems_chk] = max(SAPS_vels_Summer_Dst75[JindsChkMean_Summer_Dst75]) 
				MeanPCond_Summer_Dst75[Count_elems_chk] = mean(SAPS_PCond_Summer_Dst75[JindsChkMean_Summer_Dst75]) 
				MeanHCond_Summer_Dst75[Count_elems_chk] = mean(SAPS_HCond_Summer_Dst75[JindsChkMean_Summer_Dst75])

			endif else begin
				MeanValVel_Summer_Dst75[Count_elems_chk] = !values.f_nan
				MaxValVel_Summer_Dst75[Count_elems_chk] = !values.f_nan

				MeanPCond_Summer_Dst75[Count_elems_chk] = !values.f_nan
				MeanHCond_Summer_Dst75[Count_elems_chk] = !values.f_nan

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
				MeanPCond_Winter_Dst1010[Count_elems_chk] = mean(SAPS_PCond_Winter_Dst1010[JindsChkMean_Winter_Dst1010]) 
				MeanHCond_Winter_Dst1010[Count_elems_chk] = mean(SAPS_HCond_Winter_Dst1010[JindsChkMean_Winter_Dst1010])

				
			endif else begin
				MeanValVel_Winter_Dst1010[Count_elems_chk] = !values.f_nan
				MaxValVel_Winter_Dst1010[Count_elems_chk] = !values.f_nan
				MeanPCond_Winter_Dst1010[Count_elems_chk] = !values.f_nan
				MeanHCond_Winter_Dst1010[Count_elems_chk] = !values.f_nan

			endelse
			
		endif else begin
			MaxValVel_Winter_Dst1010[Count_elems_chk] = !values.f_nan
			MeanValVel_Winter_Dst1010[Count_elems_chk] = !values.f_nan
			MeanPCond_Winter_Dst1010[Count_elems_chk] = !values.f_nan
			MeanHCond_Winter_Dst1010[Count_elems_chk] = !values.f_nan

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
				MeanPCond_Winter_Dst1025[Count_elems_chk] = mean(SAPS_PCond_Winter_Dst1025[JindsChkMean_Winter_Dst1025]) 
				MeanHCond_Winter_Dst1025[Count_elems_chk] = mean(SAPS_HCond_Winter_Dst1025[JindsChkMean_Winter_Dst1025])

			endif else begin
				MeanValVel_Winter_Dst1025[Count_elems_chk] = !values.f_nan
				MaxValVel_Winter_Dst1025[Count_elems_chk] = !values.f_nan
				MeanPCond_Winter_Dst1025[Count_elems_chk] = !values.f_nan
				MeanHCond_Winter_Dst1025[Count_elems_chk] = !values.f_nan

			endelse

			
			
		endif else begin
			MeanValVel_Winter_Dst1025[Count_elems_chk] = !values.f_nan
			MaxValVel_Winter_Dst1025[Count_elems_chk] = !values.f_nan
			MeanPCond_Winter_Dst1025[Count_elems_chk] = !values.f_nan
			MeanHCond_Winter_Dst1025[Count_elems_chk] = !values.f_nan

		endelse

		MeanValLat_Winter_Dst1025[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Winter_Dst1025[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			
			
			
		JindsChkMean_Winter_Dst2550 = where( (SAPS_lats_Winter_Dst2550 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Winter_Dst2550 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Winter_Dst2550[0] ne -1 ) then begin
			
			NumPnts_Winter_Dst2550[Count_elems_chk] = n_elements(JindsChkMean_Winter_Dst2550)
			
			if ( n_elements(JindsChkMean_Winter_Dst2550) ge minElCheck_Winter[2] ) then begin		
				MeanValVel_Winter_Dst2550[Count_elems_chk] = mean(SAPS_vels_Winter_Dst2550[JindsChkMean_Winter_Dst2550]) 
				MaxValVel_Winter_Dst2550[Count_elems_chk] = max(SAPS_vels_Winter_Dst2550[JindsChkMean_Winter_Dst2550]) 
				MeanPCond_Winter_Dst2550[Count_elems_chk] = mean(SAPS_PCond_Winter_Dst2550[JindsChkMean_Winter_Dst2550]) 
				MeanHCond_Winter_Dst2550[Count_elems_chk] = mean(SAPS_HCond_Winter_Dst2550[JindsChkMean_Winter_Dst2550])

			endif else begin
				MeanValVel_Winter_Dst2550[Count_elems_chk] = !values.f_nan
				MaxValVel_Winter_Dst2550[Count_elems_chk] = !values.f_nan
				MeanPCond_Winter_Dst2550[Count_elems_chk] = !values.f_nan
				MeanHCond_Winter_Dst2550[Count_elems_chk] = !values.f_nan

			endelse

			
		endif else begin
			MeanValVel_Winter_Dst2550[Count_elems_chk] = !values.f_nan
			MaxValVel_Winter_Dst2550[Count_elems_chk] = !values.f_nan
			MeanPCond_Winter_Dst2550[Count_elems_chk] = !values.f_nan
			MeanHCond_Winter_Dst2550[Count_elems_chk] = !values.f_nan

		endelse

		MeanValLat_Winter_Dst2550[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Winter_Dst2550[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			

			
		JindsChkMean_Winter_Dst5075 = where( (SAPS_lats_Winter_Dst5075 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Winter_Dst5075 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Winter_Dst5075[0] ne -1 ) then begin
			
			NumPnts_Winter_Dst5075[Count_elems_chk] = n_elements(JindsChkMean_Winter_Dst5075)
			
			if ( n_elements(JindsChkMean_Winter_Dst5075) ge minElCheck_Winter[3] ) then begin		
				MeanValVel_Winter_Dst5075[Count_elems_chk] = mean(SAPS_vels_Winter_Dst5075[JindsChkMean_Winter_Dst5075]) 
				MaxValVel_Winter_Dst5075[Count_elems_chk] = max(SAPS_vels_Winter_Dst5075[JindsChkMean_Winter_Dst5075]) 
				MeanPCond_Winter_Dst5075[Count_elems_chk] = mean(SAPS_PCond_Winter_Dst5075[JindsChkMean_Winter_Dst5075]) 
				MeanHCond_Winter_Dst5075[Count_elems_chk] = mean(SAPS_HCond_Winter_Dst5075[JindsChkMean_Winter_Dst5075])

			endif else begin
				MeanValVel_Winter_Dst5075[Count_elems_chk] = !values.f_nan
				MaxValVel_Winter_Dst5075[Count_elems_chk] = !values.f_nan
				MeanPCond_Winter_Dst5075[Count_elems_chk] = !values.f_nan
				MeanHCond_Winter_Dst5075[Count_elems_chk] = !values.f_nan

			endelse

			
		endif else begin
			MeanValVel_Winter_Dst5075[Count_elems_chk] = !values.f_nan
			MaxValVel_Winter_Dst5075[Count_elems_chk] = !values.f_nan
			MeanPCond_Winter_Dst5075[Count_elems_chk] = !values.f_nan
			MeanHCond_Winter_Dst5075[Count_elems_chk] = !values.f_nan

		endelse	

		MeanValLat_Winter_Dst5075[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Winter_Dst5075[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			
			
	

		JindsChkMean_Winter_Dst75 = where( (SAPS_lats_Winter_Dst75 eq Uniq_lats_SAPS[ll1] ) and (SAPS_mlts_Winter_Dst75 eq Uniq_Mlts_SAPS[l22] ) )
		if ( JindsChkMean_Winter_Dst75[0] ne -1 ) then begin
		
			NumPnts_Winter_Dst75[Count_elems_chk] = n_elements(JindsChkMean_Winter_Dst75)
			
			if ( n_elements(JindsChkMean_Winter_Dst75) ge minElCheck_Winter[4] ) then begin		
				MeanValVel_Winter_Dst75[Count_elems_chk] = mean(SAPS_vels_Winter_Dst75[JindsChkMean_Winter_Dst75]) 
				MaxValVel_Winter_Dst75[Count_elems_chk] = max(SAPS_vels_Winter_Dst75[JindsChkMean_Winter_Dst75]) 
				MeanPCond_Winter_Dst75[Count_elems_chk] = mean(SAPS_PCond_Winter_Dst75[JindsChkMean_Winter_Dst75]) 
				MeanHCond_Winter_Dst75[Count_elems_chk] = mean(SAPS_HCond_Winter_Dst75[JindsChkMean_Winter_Dst75])

; 				print, SAPS_events_dates[JindsChkMean_Winter_Dst75[0]], SAPS_events_times[JindsChkMean_Winter_Dst75[0]], SAPS_orig_DST_Final[JindsChkMean_Winter_Dst75[0]], Uniq_lats_SAPS[ll1], Uniq_Mlts_SAPS[l22]
			endif else begin
				MeanValVel_Winter_Dst75[Count_elems_chk] = !values.f_nan
				MaxValVel_Winter_Dst75[Count_elems_chk] = !values.f_nan
				MeanPCond_Winter_Dst75[Count_elems_chk] = !values.f_nan
				MeanHCond_Winter_Dst75[Count_elems_chk] = !values.f_nan

			endelse

			
		endif else begin
			MeanValVel_Winter_Dst75[Count_elems_chk] = !values.f_nan
			MaxValVel_Winter_Dst75[Count_elems_chk] = !values.f_nan
			MeanPCond_Winter_Dst75[Count_elems_chk] = !values.f_nan
			MeanHCond_Winter_Dst75[Count_elems_chk] = !values.f_nan

		endelse
		
		MeanValLat_Winter_Dst75[Count_elems_chk] = Uniq_lats_SAPS[ll1]
		MeanValMlt_Winter_Dst75[Count_elems_chk] = Uniq_Mlts_SAPS[l22]			
			
	
			
		
	
		Count_elems_chk = Count_elems_chk + 1
	endfor
endfor
























;;;; Potential drop across the channel -- Ped Currents across the channel



MeanEfld_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxEfld_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanJped_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxJped_Summer_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanEfld_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxEfld_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanJped_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxJped_Summer_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanEfld_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxEfld_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanJped_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxJped_Summer_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanEfld_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxEfld_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanJped_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxJped_Summer_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanEfld_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxEfld_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanJped_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxJped_Summer_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )




MeanEfld_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxEfld_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanJped_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxJped_Winter_Dst1010 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanEfld_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxEfld_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanJped_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxJped_Winter_Dst1025 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanEfld_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxEfld_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanJped_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxJped_Winter_Dst2550 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanEfld_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxEfld_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanJped_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxJped_Winter_Dst5075 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )

MeanEfld_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxEfld_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MeanJped_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )
MaxJped_Winter_Dst75 =fltarr( n_elements(Uniq_lats_SAPS) * n_elements(Uniq_Mlts_SAPS) )


sfjul, date, time, selJul
gmagpar = [ 5.0, -10., -5., -5., 0.5, 1.1 ]

for b11h = 0,n_elements(MeanValLat_Summer_Dst1010) -1 do begin


	
	
	for mm = 1., 360. do begin
	
		caldat, selJul, mon, day, year
		yrsec = (selJul-julday(1,1,year,0,0,0))*86400.d
		Condmlt_chk = mlt(year, yrsec, mm)
		
		if ( abs(Condmlt_chk - MeanValMlt_Summer_Dst1010[b11h]) le 0.1 ) then $
			Mlon_chk = mm
	
	endfor

	
	bfldBgnMapthis_Locs = t01_get_bfld( date, time,MeanValLat_Summer_Dst1010[b11h], Mlon_chk, alt_inp = 200., 'magn', hemisphere = 1, gmagpar = gmagpar )
	
	MeanEfld_Summer_Dst1010[b11h] = MeanValVel_Summer_Dst1010[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	MaxEfld_Summer_Dst1010[b11h] = MaxValVel_Summer_Dst1010[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	
	MeanJped_Summer_Dst1010[b11h] = MeanEfld_Summer_Dst1010[b11h] * MeanPCond_Summer_Dst1010[b11h] ;; mA/m
	MaxJped_Summer_Dst1010[b11h] = MaxEfld_Summer_Dst1010[b11h] * MeanPCond_Summer_Dst1010[b11h] ;; mA/m

endfor



for b11h = 0,n_elements(MeanValLat_Summer_Dst1025) -1 do begin


	
	
	for mm = 1., 360. do begin
	
		caldat, selJul, mon, day, year
		yrsec = (selJul-julday(1,1,year,0,0,0))*86400.d
		Condmlt_chk = mlt(year, yrsec, mm)
		
		if ( abs(Condmlt_chk - MeanValMlt_Summer_Dst1025[b11h]) le 0.1 ) then $
			Mlon_chk = mm
	
	endfor

	
	bfldBgnMapthis_Locs = t01_get_bfld( date, time,MeanValLat_Summer_Dst1025[b11h], Mlon_chk, alt_inp = 200., 'magn', hemisphere = 1, gmagpar = gmagpar )
	
	MeanEfld_Summer_Dst1025[b11h] = MeanValVel_Summer_Dst1025[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	MaxEfld_Summer_Dst1025[b11h] = MaxValVel_Summer_Dst1025[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	
	MeanJped_Summer_Dst1025[b11h] = MeanEfld_Summer_Dst1025[b11h] * MeanPCond_Summer_Dst1025[b11h] ;; mA/m
	MaxJped_Summer_Dst1025[b11h] = MaxEfld_Summer_Dst1025[b11h] * MeanPCond_Summer_Dst1025[b11h] ;; mA/m
	
endfor





for b11h = 0,n_elements(MeanValLat_Summer_Dst2550) -1 do begin


	
	
	for mm = 1., 360. do begin
	
		caldat, selJul, mon, day, year
		yrsec = (selJul-julday(1,1,year,0,0,0))*86400.d
		Condmlt_chk = mlt(year, yrsec, mm)
		
		if ( abs(Condmlt_chk - MeanValMlt_Summer_Dst2550[b11h]) le 0.1 ) then $
			Mlon_chk = mm
	
	endfor

	
	bfldBgnMapthis_Locs = t01_get_bfld( date, time,MeanValLat_Summer_Dst2550[b11h], Mlon_chk, alt_inp = 200., 'magn', hemisphere = 1, gmagpar = gmagpar )
	
	MeanEfld_Summer_Dst2550[b11h] = MeanValVel_Summer_Dst2550[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	MaxEfld_Summer_Dst2550[b11h] = MaxValVel_Summer_Dst2550[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	
	MeanJped_Summer_Dst2550[b11h] = MeanEfld_Summer_Dst2550[b11h] * MeanPCond_Summer_Dst2550[b11h] ;; mA/m
	MaxJped_Summer_Dst2550[b11h] = MaxEfld_Summer_Dst2550[b11h] * MeanPCond_Summer_Dst2550[b11h] ;; mA/m
	
	
endfor



for b11h = 0,n_elements(MeanValLat_Summer_Dst5075) -1 do begin


	
	
	for mm = 1., 360. do begin
	
		caldat, selJul, mon, day, year
		yrsec = (selJul-julday(1,1,year,0,0,0))*86400.d
		Condmlt_chk = mlt(year, yrsec, mm)
		
		if ( abs(Condmlt_chk - MeanValMlt_Summer_Dst5075[b11h]) le 0.1 ) then $
			Mlon_chk = mm
	
	endfor

	
	bfldBgnMapthis_Locs = t01_get_bfld( date, time,MeanValLat_Summer_Dst5075[b11h], Mlon_chk, alt_inp = 200., 'magn', hemisphere = 1, gmagpar = gmagpar )
	
	MeanEfld_Summer_Dst5075[b11h] = MeanValVel_Summer_Dst5075[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	MaxEfld_Summer_Dst5075[b11h] = MaxValVel_Summer_Dst5075[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	
	
	MeanJped_Summer_Dst5075[b11h] = MeanEfld_Summer_Dst5075[b11h] * MeanPCond_Summer_Dst5075[b11h] ;; mA/m
	MaxJped_Summer_Dst5075[b11h] = MaxEfld_Summer_Dst5075[b11h] * MeanPCond_Summer_Dst5075[b11h] ;; mA/m
	
endfor





for b11h = 0,n_elements(MeanValLat_Summer_Dst75) -1 do begin


	
	
	for mm = 1., 360. do begin
	
		caldat, selJul, mon, day, year
		yrsec = (selJul-julday(1,1,year,0,0,0))*86400.d
		Condmlt_chk = mlt(year, yrsec, mm)
		
		if ( abs(Condmlt_chk - MeanValMlt_Summer_Dst75[b11h]) le 0.1 ) then $
			Mlon_chk = mm
	
	endfor

	
	bfldBgnMapthis_Locs = t01_get_bfld( date, time,MeanValLat_Summer_Dst75[b11h], Mlon_chk, alt_inp = 200., 'magn', hemisphere = 1, gmagpar = gmagpar )
	
	MeanEfld_Summer_Dst75[b11h] = MeanValVel_Summer_Dst75[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	MaxEfld_Summer_Dst75[b11h] = MaxValVel_Summer_Dst75[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	
	MeanJped_Summer_Dst75[b11h] = MeanEfld_Summer_Dst75[b11h] * MeanPCond_Summer_Dst75[b11h] ;; mA/m
	MaxJped_Summer_Dst75[b11h] = MaxEfld_Summer_Dst75[b11h] * MeanPCond_Summer_Dst75[b11h] ;; mA/m
	
	
endfor



for b11h = 0,n_elements(MeanValLat_Winter_Dst1010) -1 do begin


	
	
	for mm = 1., 360. do begin
	
		caldat, selJul, mon, day, year
		yrsec = (selJul-julday(1,1,year,0,0,0))*86400.d
		Condmlt_chk = mlt(year, yrsec, mm)
		
		if ( abs(Condmlt_chk - MeanValMlt_Winter_Dst1010[b11h]) le 0.1 ) then $
			Mlon_chk = mm
	
	endfor

	
	bfldBgnMapthis_Locs = t01_get_bfld( date, time,MeanValLat_Winter_Dst1010[b11h], Mlon_chk, alt_inp = 200., 'magn', hemisphere = 1, gmagpar = gmagpar )
	
	MeanEfld_Winter_Dst1010[b11h] = MeanValVel_Winter_Dst1010[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	MaxEfld_Winter_Dst1010[b11h] = MaxValVel_Winter_Dst1010[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	
	MeanJped_Winter_Dst1010[b11h] = MeanEfld_Winter_Dst1010[b11h] * MeanPCond_Winter_Dst1010[b11h] ;; mA/m
	MaxJped_Winter_Dst1010[b11h] = MaxEfld_Winter_Dst1010[b11h] * MeanPCond_Winter_Dst1010[b11h] ;; mA/m

	
	
endfor



for b11h = 0,n_elements(MeanValLat_Winter_Dst1025) -1 do begin


	
	
	for mm = 1., 360. do begin
	
		caldat, selJul, mon, day, year
		yrsec = (selJul-julday(1,1,year,0,0,0))*86400.d
		Condmlt_chk = mlt(year, yrsec, mm)
		
		if ( abs(Condmlt_chk - MeanValMlt_Winter_Dst1025[b11h]) le 0.1 ) then $
			Mlon_chk = mm
	
	endfor

	
	bfldBgnMapthis_Locs = t01_get_bfld( date, time,MeanValLat_Winter_Dst1025[b11h], Mlon_chk, alt_inp = 200., 'magn', hemisphere = 1, gmagpar = gmagpar )
	
	MeanEfld_Winter_Dst1025[b11h] = MeanValVel_Winter_Dst1025[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	MaxEfld_Winter_Dst1025[b11h] = MaxValVel_Winter_Dst1025[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	
	MeanJped_Winter_Dst1025[b11h] = MeanEfld_Winter_Dst1025[b11h] * MeanPCond_Winter_Dst1025[b11h] ;; mA/m
	MaxJped_Winter_Dst1025[b11h] = MaxEfld_Winter_Dst1025[b11h] * MeanPCond_Winter_Dst1025[b11h] ;; mA/m


	
	
endfor





for b11h = 0,n_elements(MeanValLat_Winter_Dst2550) -1 do begin


	
	
	for mm = 1., 360. do begin
	
		caldat, selJul, mon, day, year
		yrsec = (selJul-julday(1,1,year,0,0,0))*86400.d
		Condmlt_chk = mlt(year, yrsec, mm)
		
		if ( abs(Condmlt_chk - MeanValMlt_Winter_Dst2550[b11h]) le 0.1 ) then $
			Mlon_chk = mm
	
	endfor

	
	bfldBgnMapthis_Locs = t01_get_bfld( date, time,MeanValLat_Winter_Dst2550[b11h], Mlon_chk, alt_inp = 200., 'magn', hemisphere = 1, gmagpar = gmagpar )
	
	MeanEfld_Winter_Dst2550[b11h] = MeanValVel_Winter_Dst2550[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	MaxEfld_Winter_Dst2550[b11h] = MaxValVel_Winter_Dst2550[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	
	
	MeanJped_Winter_Dst2550[b11h] = MeanEfld_Winter_Dst2550[b11h] * MeanPCond_Winter_Dst2550[b11h] ;; mA/m
	MaxJped_Winter_Dst2550[b11h] = MaxEfld_Winter_Dst2550[b11h] * MeanPCond_Winter_Dst2550[b11h] ;; mA/m

	
endfor



for b11h = 0,n_elements(MeanValLat_Winter_Dst5075) -1 do begin


	
	
	for mm = 1., 360. do begin
	
		caldat, selJul, mon, day, year
		yrsec = (selJul-julday(1,1,year,0,0,0))*86400.d
		Condmlt_chk = mlt(year, yrsec, mm)
		
		if ( abs(Condmlt_chk - MeanValMlt_Winter_Dst5075[b11h]) le 0.1 ) then $
			Mlon_chk = mm
	
	endfor

	
	bfldBgnMapthis_Locs = t01_get_bfld( date, time,MeanValLat_Winter_Dst5075[b11h], Mlon_chk, alt_inp = 200., 'magn', hemisphere = 1, gmagpar = gmagpar )
	
	MeanEfld_Winter_Dst5075[b11h] = MeanValVel_Winter_Dst5075[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	MaxEfld_Winter_Dst5075[b11h] = MaxValVel_Winter_Dst5075[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	
	MeanJped_Winter_Dst5075[b11h] = MeanEfld_Winter_Dst5075[b11h] * MeanPCond_Winter_Dst5075[b11h] ;; mA/m
	MaxJped_Winter_Dst5075[b11h] = MaxEfld_Winter_Dst5075[b11h] * MeanPCond_Winter_Dst5075[b11h] ;; mA/m

	
	
endfor





for b11h = 0,n_elements(MeanValLat_Winter_Dst75) -1 do begin


	
	
	for mm = 1., 360. do begin
	
		caldat, selJul, mon, day, year
		yrsec = (selJul-julday(1,1,year,0,0,0))*86400.d
		Condmlt_chk = mlt(year, yrsec, mm)
		
		if ( abs(Condmlt_chk - MeanValMlt_Winter_Dst75[b11h]) le 0.1 ) then $
			Mlon_chk = mm
	
	endfor

	
	bfldBgnMapthis_Locs = t01_get_bfld( date, time,MeanValLat_Winter_Dst75[b11h], Mlon_chk, alt_inp = 200., 'magn', hemisphere = 1, gmagpar = gmagpar )
	
	MeanEfld_Winter_Dst75[b11h] = MeanValVel_Winter_Dst75[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	MaxEfld_Winter_Dst75[b11h] = MaxValVel_Winter_Dst75[b11h] * bfldBgnMapthis_Locs * 1e-9 * 1e3 ;; mv/m
	
	
	MeanJped_Winter_Dst75[b11h] = MeanEfld_Winter_Dst75[b11h] * MeanPCond_Winter_Dst75[b11h] ;; mA/m
	MaxJped_Winter_Dst75[b11h] = MaxEfld_Winter_Dst75[b11h] * MeanPCond_Winter_Dst75[b11h] ;; mA/m
	
endfor



lat_degree_inkm = 100. ;; in Km
Scale_phi_All = [0,20]
Scale_J_All = [0,1.5]

MeanPhi_Summer_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxPhi_Summer_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Minlat_Phi_Summer_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Maxlat_Phi_Summer_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
mltArr_Phi_Summer_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanPhi_Summer_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxPhi_Summer_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

MeanJped_den_Summer_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxJped_den_Summer_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanJped_den_Summer_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxJped_den_Summer_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

for jj2j = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin

	Jinds_mlt_this_phi_Summer_Dst1010 = where( (MeanValMlt_Summer_Dst1010 eq Uniq_Mlts_SAPS[jj2j]) and finite(MeanEfld_Summer_Dst1010) )
	mltArr_Phi_Summer_Dst1010[jj2j] = Uniq_Mlts_SAPS[jj2j]
	if ( Jinds_mlt_this_phi_Summer_Dst1010[0] ne -1 ) then begin
		MeanPhi_Summer_Dst1010[jj2j] = total(MeanEfld_Summer_Dst1010[Jinds_mlt_this_phi_Summer_Dst1010])*(lat_degree_inkm/1e3);; In kV
		MaxPhi_Summer_Dst1010[jj2j] = total(MaxEfld_Summer_Dst1010[Jinds_mlt_this_phi_Summer_Dst1010])*(lat_degree_inkm/1e3);; In kV 
		Minlat_Phi_Summer_Dst1010[jj2j] = min(MeanValLat_Summer_Dst1010[Jinds_mlt_this_phi_Summer_Dst1010])
		Maxlat_Phi_Summer_Dst1010[jj2j] = max(MeanValLat_Summer_Dst1010[Jinds_mlt_this_phi_Summer_Dst1010])
		
		colVal_MeanPhi_Summer_Dst1010[jj2j] = get_color_index(MeanPhi_Summer_Dst1010[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxPhi_Summer_Dst1010[jj2j] = get_color_index(MaxPhi_Summer_Dst1010[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		
		MeanJped_den_Summer_Dst1010[jj2j] = max(MeanJped_Summer_Dst1010[Jinds_mlt_this_phi_Summer_Dst1010])/(lat_degree_inkm);; In microAmp/m^2
		MaxJped_den_Summer_Dst1010[jj2j] = max(MaxJped_Summer_Dst1010[Jinds_mlt_this_phi_Summer_Dst1010])/(lat_degree_inkm);; In microAmp/m^2

		colVal_MeanJped_den_Summer_Dst1010[jj2j] = get_color_index(MeanJped_den_Summer_Dst1010[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxJped_den_Summer_Dst1010[jj2j] = get_color_index(MaxJped_den_Summer_Dst1010[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')

; 		print,'Jped',MeanJped_den_Summer_Dst1010[jj2j],MaxJped_den_Summer_Dst1010[jj2j]
		
	endif else begin
		MeanPhi_Summer_Dst1010[jj2j] = !values.f_nan
		MaxPhi_Summer_Dst1010[jj2j] = !values.f_nan
		Minlat_Phi_Summer_Dst1010[jj2j] = !values.f_nan
		Maxlat_Phi_Summer_Dst1010[jj2j] = !values.f_nan

		colVal_MeanPhi_Summer_Dst1010[jj2j] = get_background()
		colVal_MaxPhi_Summer_Dst1010[jj2j] = get_background()
		
		MeanJped_den_Summer_Dst1010[jj2j] = !values.f_nan
		MaxJped_den_Summer_Dst1010[jj2j] = !values.f_nan
		
		colVal_MeanJped_den_Summer_Dst1010[jj2j] = get_background()
		colVal_MaxJped_den_Summer_Dst1010[jj2j] = get_background()
		
	endelse

; 	print, MeanPhi_Summer_Dst1010[jj2j], MaxPhi_Summer_Dst1010[jj2j], mltArr_Phi_Summer_Dst1010[jj2j], Minlat_Phi_Summer_Dst1010[jj2j], Maxlat_Phi_Summer_Dst1010[jj2j]
endfor



MeanPhi_Summer_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxPhi_Summer_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Minlat_Phi_Summer_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Maxlat_Phi_Summer_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
mltArr_Phi_Summer_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanPhi_Summer_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxPhi_Summer_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

MeanJped_den_Summer_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxJped_den_Summer_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanJped_den_Summer_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxJped_den_Summer_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )



for jj2j = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin

	Jinds_mlt_this_phi_Summer_Dst1025 = where( (MeanValMlt_Summer_Dst1025 eq Uniq_Mlts_SAPS[jj2j]) and finite(MeanEfld_Summer_Dst1025) )
	mltArr_Phi_Summer_Dst1025[jj2j] = Uniq_Mlts_SAPS[jj2j]
	if ( Jinds_mlt_this_phi_Summer_Dst1025[0] ne -1 ) then begin
		MeanPhi_Summer_Dst1025[jj2j] = total(MeanEfld_Summer_Dst1025[Jinds_mlt_this_phi_Summer_Dst1025])*(lat_degree_inkm/1e3);; In kV
		MaxPhi_Summer_Dst1025[jj2j] = total(MaxEfld_Summer_Dst1025[Jinds_mlt_this_phi_Summer_Dst1025])*(lat_degree_inkm/1e3);; In kV 
		Minlat_Phi_Summer_Dst1025[jj2j] = min(MeanValLat_Summer_Dst1025[Jinds_mlt_this_phi_Summer_Dst1025])
		Maxlat_Phi_Summer_Dst1025[jj2j] = max(MeanValLat_Summer_Dst1025[Jinds_mlt_this_phi_Summer_Dst1025])
		
		colVal_MeanPhi_Summer_Dst1025[jj2j] = get_color_index(MeanPhi_Summer_Dst1025[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxPhi_Summer_Dst1025[jj2j] = get_color_index(MaxPhi_Summer_Dst1025[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		
		MeanJped_den_Summer_Dst1025[jj2j] = max(MeanJped_Summer_Dst1025[Jinds_mlt_this_phi_Summer_Dst1025])/(lat_degree_inkm);; In microAmp/m^2
		MaxJped_den_Summer_Dst1025[jj2j] = max(MaxJped_Summer_Dst1025[Jinds_mlt_this_phi_Summer_Dst1025])/(lat_degree_inkm);; In microAmp/m^2

		colVal_MeanJped_den_Summer_Dst1025[jj2j] = get_color_index(MeanJped_den_Summer_Dst1025[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxJped_den_Summer_Dst1025[jj2j] = get_color_index(MaxJped_den_Summer_Dst1025[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')

		
	endif else begin
		MeanPhi_Summer_Dst1025[jj2j] = !values.f_nan
		MaxPhi_Summer_Dst1025[jj2j] = !values.f_nan
		Minlat_Phi_Summer_Dst1025[jj2j] = !values.f_nan
		Maxlat_Phi_Summer_Dst1025[jj2j] = !values.f_nan

		colVal_MeanPhi_Summer_Dst1025[jj2j] = get_background()
		colVal_MaxPhi_Summer_Dst1025[jj2j] = get_background()
		
		MeanJped_den_Summer_Dst1025[jj2j] = !values.f_nan
		MaxJped_den_Summer_Dst1025[jj2j] = !values.f_nan
		
		colVal_MeanJped_den_Summer_Dst1025[jj2j] = get_background()
		colVal_MaxJped_den_Summer_Dst1025[jj2j] = get_background()


	endelse

; 	print, MeanPhi_Summer_Dst1025[jj2j], MaxPhi_Summer_Dst1025[jj2j], mltArr_Phi_Summer_Dst1025[jj2j], Minlat_Phi_Summer_Dst1025[jj2j], Maxlat_Phi_Summer_Dst1025[jj2j]
endfor


MeanPhi_Summer_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxPhi_Summer_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Minlat_Phi_Summer_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Maxlat_Phi_Summer_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
mltArr_Phi_Summer_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanPhi_Summer_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxPhi_Summer_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

MeanJped_den_Summer_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxJped_den_Summer_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanJped_den_Summer_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxJped_den_Summer_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )


for jj2j = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin

	Jinds_mlt_this_phi_Summer_Dst2550 = where( (MeanValMlt_Summer_Dst2550 eq Uniq_Mlts_SAPS[jj2j]) and finite(MeanEfld_Summer_Dst2550) )
	mltArr_Phi_Summer_Dst2550[jj2j] = Uniq_Mlts_SAPS[jj2j]
	if ( Jinds_mlt_this_phi_Summer_Dst2550[0] ne -1 ) then begin
		MeanPhi_Summer_Dst2550[jj2j] = total(MeanEfld_Summer_Dst2550[Jinds_mlt_this_phi_Summer_Dst2550])*(lat_degree_inkm/1e3);; In kV
		MaxPhi_Summer_Dst2550[jj2j] = total(MaxEfld_Summer_Dst2550[Jinds_mlt_this_phi_Summer_Dst2550])*(lat_degree_inkm/1e3);; In kV 
		Minlat_Phi_Summer_Dst2550[jj2j] = min(MeanValLat_Summer_Dst2550[Jinds_mlt_this_phi_Summer_Dst2550])
		Maxlat_Phi_Summer_Dst2550[jj2j] = max(MeanValLat_Summer_Dst2550[Jinds_mlt_this_phi_Summer_Dst2550])

		colVal_MeanPhi_Summer_Dst2550[jj2j] = get_color_index(MeanPhi_Summer_Dst2550[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxPhi_Summer_Dst2550[jj2j] = get_color_index(MaxPhi_Summer_Dst2550[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		
		
		MeanJped_den_Summer_Dst2550[jj2j] = max(MeanJped_Summer_Dst2550[Jinds_mlt_this_phi_Summer_Dst2550])/(lat_degree_inkm);; In microAmp/m^2
		MaxJped_den_Summer_Dst2550[jj2j] = max(MaxJped_Summer_Dst2550[Jinds_mlt_this_phi_Summer_Dst2550])/(lat_degree_inkm);; In microAmp/m^2

		colVal_MeanJped_den_Summer_Dst2550[jj2j] = get_color_index(MeanJped_den_Summer_Dst2550[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxJped_den_Summer_Dst2550[jj2j] = get_color_index(MaxJped_den_Summer_Dst2550[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')

		
		
	endif else begin
		MeanPhi_Summer_Dst2550[jj2j] = !values.f_nan
		MaxPhi_Summer_Dst2550[jj2j] = !values.f_nan
		Minlat_Phi_Summer_Dst2550[jj2j] = !values.f_nan
		Maxlat_Phi_Summer_Dst2550[jj2j] = !values.f_nan
		colVal_MeanPhi_Summer_Dst2550[jj2j] = get_background()
		colVal_MaxPhi_Summer_Dst2550[jj2j] = get_background()
		
		MeanJped_den_Summer_Dst2550[jj2j] = !values.f_nan
		MaxJped_den_Summer_Dst2550[jj2j] = !values.f_nan
		
		colVal_MeanJped_den_Summer_Dst2550[jj2j] = get_background()
		colVal_MaxJped_den_Summer_Dst2550[jj2j] = get_background()


	endelse

; 	print, MeanPhi_Summer_Dst2550[jj2j], MaxPhi_Summer_Dst2550[jj2j], mltArr_Phi_Summer_Dst2550[jj2j], Minlat_Phi_Summer_Dst2550[jj2j], Maxlat_Phi_Summer_Dst2550[jj2j]
endfor


MeanPhi_Summer_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxPhi_Summer_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Minlat_Phi_Summer_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Maxlat_Phi_Summer_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
mltArr_Phi_Summer_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanPhi_Summer_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxPhi_Summer_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )



MeanJped_den_Summer_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxJped_den_Summer_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanJped_den_Summer_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxJped_den_Summer_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )


for jj2j = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin

	Jinds_mlt_this_phi_Summer_Dst5075 = where( (MeanValMlt_Summer_Dst5075 eq Uniq_Mlts_SAPS[jj2j]) and finite(MeanEfld_Summer_Dst5075) )
	mltArr_Phi_Summer_Dst5075[jj2j] = Uniq_Mlts_SAPS[jj2j]
	if ( Jinds_mlt_this_phi_Summer_Dst5075[0] ne -1 ) then begin
		MeanPhi_Summer_Dst5075[jj2j] = total(MeanEfld_Summer_Dst5075[Jinds_mlt_this_phi_Summer_Dst5075])*(lat_degree_inkm/1e3);; In kV
		MaxPhi_Summer_Dst5075[jj2j] = total(MaxEfld_Summer_Dst5075[Jinds_mlt_this_phi_Summer_Dst5075])*(lat_degree_inkm/1e3);; In kV 
		Minlat_Phi_Summer_Dst5075[jj2j] = min(MeanValLat_Summer_Dst5075[Jinds_mlt_this_phi_Summer_Dst5075])
		Maxlat_Phi_Summer_Dst5075[jj2j] = max(MeanValLat_Summer_Dst5075[Jinds_mlt_this_phi_Summer_Dst5075])
		
		colVal_MeanPhi_Summer_Dst5075[jj2j] = get_color_index(MeanPhi_Summer_Dst5075[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxPhi_Summer_Dst5075[jj2j] = get_color_index(MaxPhi_Summer_Dst5075[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		
		MeanJped_den_Summer_Dst5075[jj2j] = max(MeanJped_Summer_Dst5075[Jinds_mlt_this_phi_Summer_Dst5075])/(lat_degree_inkm);; In microAmp/m^2
		MaxJped_den_Summer_Dst5075[jj2j] = max(MaxJped_Summer_Dst5075[Jinds_mlt_this_phi_Summer_Dst5075])/(lat_degree_inkm);; In microAmp/m^2

		colVal_MeanJped_den_Summer_Dst5075[jj2j] = get_color_index(MeanJped_den_Summer_Dst5075[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxJped_den_Summer_Dst5075[jj2j] = get_color_index(MaxJped_den_Summer_Dst5075[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')

		
		
	endif else begin
		MeanPhi_Summer_Dst5075[jj2j] = !values.f_nan
		MaxPhi_Summer_Dst5075[jj2j] = !values.f_nan
		Minlat_Phi_Summer_Dst5075[jj2j] = !values.f_nan
		Maxlat_Phi_Summer_Dst5075[jj2j] = !values.f_nan
		
		colVal_MeanPhi_Summer_Dst5075[jj2j] = get_background()
		colVal_MaxPhi_Summer_Dst5075[jj2j] = get_background()
		
		MeanJped_den_Summer_Dst5075[jj2j] = !values.f_nan
		MaxJped_den_Summer_Dst5075[jj2j] = !values.f_nan
		
		colVal_MeanJped_den_Summer_Dst5075[jj2j] = get_background()
		colVal_MaxJped_den_Summer_Dst5075[jj2j] = get_background()

	endelse

; 	print, MeanPhi_Summer_Dst5075[jj2j], MaxPhi_Summer_Dst5075[jj2j], mltArr_Phi_Summer_Dst5075[jj2j], Minlat_Phi_Summer_Dst5075[jj2j], Maxlat_Phi_Summer_Dst5075[jj2j]
endfor



MeanPhi_Summer_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxPhi_Summer_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Minlat_Phi_Summer_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Maxlat_Phi_Summer_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
mltArr_Phi_Summer_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanPhi_Summer_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxPhi_Summer_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )


MeanJped_den_Summer_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxJped_den_Summer_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanJped_den_Summer_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxJped_den_Summer_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )



for jj2j = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin

	Jinds_mlt_this_phi_Summer_Dst75 = where( (MeanValMlt_Summer_Dst75 eq Uniq_Mlts_SAPS[jj2j]) and finite(MeanEfld_Summer_Dst75) )
	mltArr_Phi_Summer_Dst75[jj2j] = Uniq_Mlts_SAPS[jj2j]
	if ( Jinds_mlt_this_phi_Summer_Dst75[0] ne -1 ) then begin
		MeanPhi_Summer_Dst75[jj2j] = total(MeanEfld_Summer_Dst75[Jinds_mlt_this_phi_Summer_Dst75])*(lat_degree_inkm/1e3);; In kV
		MaxPhi_Summer_Dst75[jj2j] = total(MaxEfld_Summer_Dst75[Jinds_mlt_this_phi_Summer_Dst75])*(lat_degree_inkm/1e3);; In kV 
		Minlat_Phi_Summer_Dst75[jj2j] = min(MeanValLat_Summer_Dst75[Jinds_mlt_this_phi_Summer_Dst75])
		Maxlat_Phi_Summer_Dst75[jj2j] = max(MeanValLat_Summer_Dst75[Jinds_mlt_this_phi_Summer_Dst75])

		colVal_MeanPhi_Summer_Dst75[jj2j] = get_color_index(MeanPhi_Summer_Dst75[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxPhi_Summer_Dst75[jj2j] = get_color_index(MaxPhi_Summer_Dst75[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		
		MeanJped_den_Summer_Dst75[jj2j] = max(MeanJped_Summer_Dst75[Jinds_mlt_this_phi_Summer_Dst75])/(lat_degree_inkm);; In microAmp/m^2
		MaxJped_den_Summer_Dst75[jj2j] = max(MaxJped_Summer_Dst75[Jinds_mlt_this_phi_Summer_Dst75])/(lat_degree_inkm);; In microAmp/m^2

		colVal_MeanJped_den_Summer_Dst75[jj2j] = get_color_index(MeanJped_den_Summer_Dst75[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxJped_den_Summer_Dst75[jj2j] = get_color_index(MaxJped_den_Summer_Dst75[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')



	endif else begin
		MeanPhi_Summer_Dst75[jj2j] = !values.f_nan
		MaxPhi_Summer_Dst75[jj2j] = !values.f_nan
		Minlat_Phi_Summer_Dst75[jj2j] = !values.f_nan
		Maxlat_Phi_Summer_Dst75[jj2j] = !values.f_nan
		
		colVal_MeanPhi_Summer_Dst75[jj2j] = get_background()
		colVal_MaxPhi_Summer_Dst75[jj2j] = get_background()
		
		MeanJped_den_Summer_Dst75[jj2j] = !values.f_nan
		MaxJped_den_Summer_Dst75[jj2j] = !values.f_nan
		
		colVal_MeanJped_den_Summer_Dst75[jj2j] = get_background()
		colVal_MaxJped_den_Summer_Dst75[jj2j] = get_background()

		
	endelse

; 	print, MeanPhi_Summer_Dst75[jj2j], MaxPhi_Summer_Dst75[jj2j], mltArr_Phi_Summer_Dst75[jj2j], Minlat_Phi_Summer_Dst75[jj2j], Maxlat_Phi_Summer_Dst75[jj2j]
endfor



MeanPhi_Winter_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxPhi_Winter_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Minlat_Phi_Winter_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Maxlat_Phi_Winter_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
mltArr_Phi_Winter_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanPhi_Winter_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxPhi_Winter_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )


MeanJped_den_Winter_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxJped_den_Winter_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanJped_den_Winter_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxJped_den_Winter_Dst1010 = fltarr( n_elements( Uniq_Mlts_SAPS ) )



for jj2j = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin

	Jinds_mlt_this_phi_Winter_Dst1010 = where( (MeanValMlt_Winter_Dst1010 eq Uniq_Mlts_SAPS[jj2j]) and finite(MeanEfld_Winter_Dst1010) )
	mltArr_Phi_Winter_Dst1010[jj2j] = Uniq_Mlts_SAPS[jj2j]
	if ( Jinds_mlt_this_phi_Winter_Dst1010[0] ne -1 ) then begin
		MeanPhi_Winter_Dst1010[jj2j] = total(MeanEfld_Winter_Dst1010[Jinds_mlt_this_phi_Winter_Dst1010])*(lat_degree_inkm/1e3);; In kV
		MaxPhi_Winter_Dst1010[jj2j] = total(MaxEfld_Winter_Dst1010[Jinds_mlt_this_phi_Winter_Dst1010])*(lat_degree_inkm/1e3);; In kV 
		Minlat_Phi_Winter_Dst1010[jj2j] = min(MeanValLat_Winter_Dst1010[Jinds_mlt_this_phi_Winter_Dst1010])
		Maxlat_Phi_Winter_Dst1010[jj2j] = max(MeanValLat_Winter_Dst1010[Jinds_mlt_this_phi_Winter_Dst1010])
		
		colVal_MeanPhi_Winter_Dst1010[jj2j] = get_color_index(MeanPhi_Winter_Dst1010[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxPhi_Winter_Dst1010[jj2j] = get_color_index(MaxPhi_Winter_Dst1010[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		
		MeanJped_den_Winter_Dst1010[jj2j] = max(MeanJped_Winter_Dst1010[Jinds_mlt_this_phi_Winter_Dst1010])/(lat_degree_inkm);; In microAmp/m^2
		MaxJped_den_Winter_Dst1010[jj2j] = max(MaxJped_Winter_Dst1010[Jinds_mlt_this_phi_Winter_Dst1010])/(lat_degree_inkm);; In microAmp/m^2

		colVal_MeanJped_den_Winter_Dst1010[jj2j] = get_color_index(MeanJped_den_Winter_Dst1010[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxJped_den_Winter_Dst1010[jj2j] = get_color_index(MaxJped_den_Winter_Dst1010[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')

		
	endif else begin
		MeanPhi_Winter_Dst1010[jj2j] = !values.f_nan
		MaxPhi_Winter_Dst1010[jj2j] = !values.f_nan
		Minlat_Phi_Winter_Dst1010[jj2j] = !values.f_nan
		Maxlat_Phi_Winter_Dst1010[jj2j] = !values.f_nan
		
		colVal_MeanPhi_Winter_Dst1010[jj2j] = get_background()
		colVal_MaxPhi_Winter_Dst1010[jj2j] = get_background()
		
		MeanJped_den_Winter_Dst1010[jj2j] = !values.f_nan
		MaxJped_den_Winter_Dst1010[jj2j] = !values.f_nan
		
		colVal_MeanJped_den_Winter_Dst1010[jj2j] = get_background()
		colVal_MaxJped_den_Winter_Dst1010[jj2j] = get_background()


		
	endelse

; 	print, MeanPhi_Winter_Dst1010[jj2j], MaxPhi_Winter_Dst1010[jj2j], mltArr_Phi_Winter_Dst1010[jj2j], Minlat_Phi_Winter_Dst1010[jj2j], Maxlat_Phi_Winter_Dst1010[jj2j]
endfor



MeanPhi_Winter_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxPhi_Winter_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Minlat_Phi_Winter_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Maxlat_Phi_Winter_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
mltArr_Phi_Winter_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanPhi_Winter_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxPhi_Winter_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )


MeanJped_den_Winter_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxJped_den_Winter_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanJped_den_Winter_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxJped_den_Winter_Dst1025 = fltarr( n_elements( Uniq_Mlts_SAPS ) )



for jj2j = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin

	Jinds_mlt_this_phi_Winter_Dst1025 = where( (MeanValMlt_Winter_Dst1025 eq Uniq_Mlts_SAPS[jj2j]) and finite(MeanEfld_Winter_Dst1025) )
	mltArr_Phi_Winter_Dst1025[jj2j] = Uniq_Mlts_SAPS[jj2j]
	if ( Jinds_mlt_this_phi_Winter_Dst1025[0] ne -1 ) then begin
		MeanPhi_Winter_Dst1025[jj2j] = total(MeanEfld_Winter_Dst1025[Jinds_mlt_this_phi_Winter_Dst1025])*(lat_degree_inkm/1e3);; In kV
		MaxPhi_Winter_Dst1025[jj2j] = total(MaxEfld_Winter_Dst1025[Jinds_mlt_this_phi_Winter_Dst1025])*(lat_degree_inkm/1e3);; In kV 
		Minlat_Phi_Winter_Dst1025[jj2j] = min(MeanValLat_Winter_Dst1025[Jinds_mlt_this_phi_Winter_Dst1025])
		Maxlat_Phi_Winter_Dst1025[jj2j] = max(MeanValLat_Winter_Dst1025[Jinds_mlt_this_phi_Winter_Dst1025])
		
		colVal_MeanPhi_Winter_Dst1025[jj2j] = get_color_index(MeanPhi_Winter_Dst1025[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxPhi_Winter_Dst1025[jj2j] = get_color_index(MaxPhi_Winter_Dst1025[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		
		MeanJped_den_Winter_Dst1025[jj2j] = max(MeanJped_Winter_Dst1025[Jinds_mlt_this_phi_Winter_Dst1025])/(lat_degree_inkm);; In microAmp/m^2
		MaxJped_den_Winter_Dst1025[jj2j] = max(MaxJped_Winter_Dst1025[Jinds_mlt_this_phi_Winter_Dst1025])/(lat_degree_inkm);; In microAmp/m^2

		colVal_MeanJped_den_Winter_Dst1025[jj2j] = get_color_index(MeanJped_den_Winter_Dst1025[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxJped_den_Winter_Dst1025[jj2j] = get_color_index(MaxJped_den_Winter_Dst1025[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')

		
	endif else begin
		MeanPhi_Winter_Dst1025[jj2j] = !values.f_nan
		MaxPhi_Winter_Dst1025[jj2j] = !values.f_nan
		Minlat_Phi_Winter_Dst1025[jj2j] = !values.f_nan
		Maxlat_Phi_Winter_Dst1025[jj2j] = !values.f_nan
		
		colVal_MeanPhi_Winter_Dst1025[jj2j] = get_background()
		colVal_MaxPhi_Winter_Dst1025[jj2j] = get_background()
		
		MeanJped_den_Winter_Dst1025[jj2j] = !values.f_nan
		MaxJped_den_Winter_Dst1025[jj2j] = !values.f_nan
		
		colVal_MeanJped_den_Winter_Dst1025[jj2j] = get_background()
		colVal_MaxJped_den_Winter_Dst1025[jj2j] = get_background()

		
	endelse

; 	print, MeanPhi_Winter_Dst1025[jj2j], MaxPhi_Winter_Dst1025[jj2j], mltArr_Phi_Winter_Dst1025[jj2j], Minlat_Phi_Winter_Dst1025[jj2j], Maxlat_Phi_Winter_Dst1025[jj2j]
endfor


MeanPhi_Winter_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxPhi_Winter_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Minlat_Phi_Winter_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Maxlat_Phi_Winter_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
mltArr_Phi_Winter_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanPhi_Winter_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxPhi_Winter_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

MeanJped_den_Winter_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxJped_den_Winter_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanJped_den_Winter_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxJped_den_Winter_Dst2550 = fltarr( n_elements( Uniq_Mlts_SAPS ) )


for jj2j = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin

	Jinds_mlt_this_phi_Winter_Dst2550 = where( (MeanValMlt_Winter_Dst2550 eq Uniq_Mlts_SAPS[jj2j]) and finite(MeanEfld_Winter_Dst2550) )
	mltArr_Phi_Winter_Dst2550[jj2j] = Uniq_Mlts_SAPS[jj2j]
	if ( Jinds_mlt_this_phi_Winter_Dst2550[0] ne -1 ) then begin
		MeanPhi_Winter_Dst2550[jj2j] = total(MeanEfld_Winter_Dst2550[Jinds_mlt_this_phi_Winter_Dst2550])*(lat_degree_inkm/1e3);; In kV
		MaxPhi_Winter_Dst2550[jj2j] = total(MaxEfld_Winter_Dst2550[Jinds_mlt_this_phi_Winter_Dst2550])*(lat_degree_inkm/1e3);; In kV 
		Minlat_Phi_Winter_Dst2550[jj2j] = min(MeanValLat_Winter_Dst2550[Jinds_mlt_this_phi_Winter_Dst2550])
		Maxlat_Phi_Winter_Dst2550[jj2j] = max(MeanValLat_Winter_Dst2550[Jinds_mlt_this_phi_Winter_Dst2550])
		
		colVal_MeanPhi_Winter_Dst2550[jj2j] = get_color_index(MeanPhi_Winter_Dst2550[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxPhi_Winter_Dst2550[jj2j] = get_color_index(MaxPhi_Winter_Dst2550[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		
		MeanJped_den_Winter_Dst2550[jj2j] = max(MeanJped_Winter_Dst2550[Jinds_mlt_this_phi_Winter_Dst2550])/(lat_degree_inkm);; In microAmp/m^2
		MaxJped_den_Winter_Dst2550[jj2j] = max(MaxJped_Winter_Dst2550[Jinds_mlt_this_phi_Winter_Dst2550])/(lat_degree_inkm);; In microAmp/m^2

		colVal_MeanJped_den_Winter_Dst2550[jj2j] = get_color_index(MeanJped_den_Winter_Dst2550[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxJped_den_Winter_Dst2550[jj2j] = get_color_index(MaxJped_den_Winter_Dst2550[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')

		
	endif else begin
		MeanPhi_Winter_Dst2550[jj2j] = !values.f_nan
		MaxPhi_Winter_Dst2550[jj2j] = !values.f_nan
		Minlat_Phi_Winter_Dst2550[jj2j] = !values.f_nan
		Maxlat_Phi_Winter_Dst2550[jj2j] = !values.f_nan
		
		colVal_MeanPhi_Winter_Dst2550[jj2j] = get_background()
		colVal_MaxPhi_Winter_Dst2550[jj2j] = get_background()
		
		MeanJped_den_Winter_Dst2550[jj2j] = !values.f_nan
		MaxJped_den_Winter_Dst2550[jj2j] = !values.f_nan
		
		colVal_MeanJped_den_Winter_Dst2550[jj2j] = get_background()
		colVal_MaxJped_den_Winter_Dst2550[jj2j] = get_background()


		
	endelse

; 	print, MeanPhi_Winter_Dst2550[jj2j], MaxPhi_Winter_Dst2550[jj2j], mltArr_Phi_Winter_Dst2550[jj2j], Minlat_Phi_Winter_Dst2550[jj2j], Maxlat_Phi_Winter_Dst2550[jj2j]
endfor


MeanPhi_Winter_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxPhi_Winter_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Minlat_Phi_Winter_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Maxlat_Phi_Winter_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
mltArr_Phi_Winter_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanPhi_Winter_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxPhi_Winter_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )


MeanJped_den_Winter_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxJped_den_Winter_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanJped_den_Winter_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxJped_den_Winter_Dst5075 = fltarr( n_elements( Uniq_Mlts_SAPS ) )



for jj2j = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin

	Jinds_mlt_this_phi_Winter_Dst5075 = where( (MeanValMlt_Winter_Dst5075 eq Uniq_Mlts_SAPS[jj2j]) and finite(MeanEfld_Winter_Dst5075) )
	mltArr_Phi_Winter_Dst5075[jj2j] = Uniq_Mlts_SAPS[jj2j]
	if ( Jinds_mlt_this_phi_Winter_Dst5075[0] ne -1 ) then begin
		MeanPhi_Winter_Dst5075[jj2j] = total(MeanEfld_Winter_Dst5075[Jinds_mlt_this_phi_Winter_Dst5075])*(lat_degree_inkm/1e3);; In kV
		MaxPhi_Winter_Dst5075[jj2j] = total(MaxEfld_Winter_Dst5075[Jinds_mlt_this_phi_Winter_Dst5075])*(lat_degree_inkm/1e3);; In kV 
		Minlat_Phi_Winter_Dst5075[jj2j] = min(MeanValLat_Winter_Dst5075[Jinds_mlt_this_phi_Winter_Dst5075])
		Maxlat_Phi_Winter_Dst5075[jj2j] = max(MeanValLat_Winter_Dst5075[Jinds_mlt_this_phi_Winter_Dst5075])
		
		colVal_MeanPhi_Winter_Dst5075[jj2j] = get_color_index(MeanPhi_Winter_Dst5075[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxPhi_Winter_Dst5075[jj2j] = get_color_index(MaxPhi_Winter_Dst5075[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		
		MeanJped_den_Winter_Dst5075[jj2j] = max(MeanJped_Winter_Dst5075[Jinds_mlt_this_phi_Winter_Dst5075])/(lat_degree_inkm);; In microAmp/m^2
		MaxJped_den_Winter_Dst5075[jj2j] = max(MaxJped_Winter_Dst5075[Jinds_mlt_this_phi_Winter_Dst5075])/(lat_degree_inkm);; In microAmp/m^2

		colVal_MeanJped_den_Winter_Dst5075[jj2j] = get_color_index(MeanJped_den_Winter_Dst5075[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxJped_den_Winter_Dst5075[jj2j] = get_color_index(MaxJped_den_Winter_Dst5075[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')

		
	endif else begin
		MeanPhi_Winter_Dst5075[jj2j] = !values.f_nan
		MaxPhi_Winter_Dst5075[jj2j] = !values.f_nan
		Minlat_Phi_Winter_Dst5075[jj2j] = !values.f_nan
		Maxlat_Phi_Winter_Dst5075[jj2j] = !values.f_nan
		
		colVal_MeanPhi_Winter_Dst5075[jj2j] = get_background()
		colVal_MaxPhi_Winter_Dst5075[jj2j] = get_background()
		
		MeanJped_den_Winter_Dst5075[jj2j] = !values.f_nan
		MaxJped_den_Winter_Dst5075[jj2j] = !values.f_nan
		
		colVal_MeanJped_den_Winter_Dst5075[jj2j] = get_background()
		colVal_MaxJped_den_Winter_Dst5075[jj2j] = get_background()


		
	endelse

; 	print, MeanPhi_Winter_Dst5075[jj2j], MaxPhi_Winter_Dst5075[jj2j], mltArr_Phi_Winter_Dst5075[jj2j], Minlat_Phi_Winter_Dst5075[jj2j], Maxlat_Phi_Winter_Dst5075[jj2j]
endfor



MeanPhi_Winter_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxPhi_Winter_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Minlat_Phi_Winter_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
Maxlat_Phi_Winter_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
mltArr_Phi_Winter_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanPhi_Winter_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxPhi_Winter_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

MeanJped_den_Winter_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
MaxJped_den_Winter_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )

colVal_MeanJped_den_Winter_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )
colVal_MaxJped_den_Winter_Dst75 = fltarr( n_elements( Uniq_Mlts_SAPS ) )



for jj2j = 0, n_elements(Uniq_Mlts_SAPS)-1 do begin

	Jinds_mlt_this_phi_Winter_Dst75 = where( (MeanValMlt_Winter_Dst75 eq Uniq_Mlts_SAPS[jj2j]) and finite(MeanEfld_Winter_Dst75) )
	mltArr_Phi_Winter_Dst75[jj2j] = Uniq_Mlts_SAPS[jj2j]
	if ( Jinds_mlt_this_phi_Winter_Dst75[0] ne -1 ) then begin
		MeanPhi_Winter_Dst75[jj2j] = total(MeanEfld_Winter_Dst75[Jinds_mlt_this_phi_Winter_Dst75])*(lat_degree_inkm/1e3);; In kV
		MaxPhi_Winter_Dst75[jj2j] = total(MaxEfld_Winter_Dst75[Jinds_mlt_this_phi_Winter_Dst75])*(lat_degree_inkm/1e3);; In kV 
		Minlat_Phi_Winter_Dst75[jj2j] = min(MeanValLat_Winter_Dst75[Jinds_mlt_this_phi_Winter_Dst75])
		Maxlat_Phi_Winter_Dst75[jj2j] = max(MeanValLat_Winter_Dst75[Jinds_mlt_this_phi_Winter_Dst75])

		colVal_MeanPhi_Winter_Dst75[jj2j] = get_color_index(MeanPhi_Winter_Dst75[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxPhi_Winter_Dst75[jj2j] = get_color_index(MaxPhi_Winter_Dst75[jj2j],scale=Scale_phi_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		
		MeanJped_den_Winter_Dst75[jj2j] = max(MeanJped_Winter_Dst75[Jinds_mlt_this_phi_Winter_Dst75])/(lat_degree_inkm);; In microAmp/m^2
		MaxJped_den_Winter_Dst75[jj2j] = max(MaxJped_Winter_Dst75[Jinds_mlt_this_phi_Winter_Dst75])/(lat_degree_inkm);; In microAmp/m^2

		colVal_MeanJped_den_Winter_Dst75[jj2j] = get_color_index(MeanJped_den_Winter_Dst75[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
		colVal_MaxJped_den_Winter_Dst75[jj2j] = get_color_index(MaxJped_den_Winter_Dst75[jj2j],scale=Scale_J_All,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')

		
	endif else begin
		MeanPhi_Winter_Dst75[jj2j] = !values.f_nan
		MaxPhi_Winter_Dst75[jj2j] = !values.f_nan
		Minlat_Phi_Winter_Dst75[jj2j] = !values.f_nan
		Maxlat_Phi_Winter_Dst75[jj2j] = !values.f_nan
		
		colVal_MeanPhi_Winter_Dst75[jj2j] = get_background()
		colVal_MaxPhi_Winter_Dst75[jj2j] = get_background()
		
		
		MeanJped_den_Winter_Dst75[jj2j] = !values.f_nan
		MaxJped_den_Winter_Dst75[jj2j] = !values.f_nan
		
		colVal_MeanJped_den_Winter_Dst75[jj2j] = get_background()
		colVal_MaxJped_den_Winter_Dst75[jj2j] = get_background()
		
	endelse

; 	print, MeanPhi_Winter_Dst75[jj2j], MaxPhi_Winter_Dst75[jj2j], mltArr_Phi_Winter_Dst75[jj2j], Minlat_Phi_Winter_Dst75[jj2j], Maxlat_Phi_Winter_Dst75[jj2j]
endfor





ps_open,'/home/bharat/ESAPS/Finstats/MeanPhi_dstmods_Summer.ps'

map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[0], charsize = 0.5


for k = 0,n_elements(colVal_MeanPhi_Summer_Dst1010) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst1010[k], mltArr_Phi_Summer_Dst1010[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst1010[k], mltArr_Phi_Summer_Dst1010[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanPhi_Summer_Dst1010[k],thick = 10
	
endfor

plot_colorbar, 1., 1., 0., 0.,scale=Scale_phi_All,legend='Potential Drop [kV]',param='power'

map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[1], charsize = 0.5


for k = 0,n_elements(colVal_MeanPhi_Summer_Dst1025) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst1025[k], mltArr_Phi_Summer_Dst1025[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst1025[k], mltArr_Phi_Summer_Dst1025[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanPhi_Summer_Dst1025[k],thick = 10
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'




map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[2], charsize = 0.5


for k = 0,n_elements(colVal_MeanPhi_Summer_Dst2550) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst2550[k], mltArr_Phi_Summer_Dst2550[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst2550[k], mltArr_Phi_Summer_Dst2550[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanPhi_Summer_Dst2550[k],thick = 10
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'



map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[3], charsize = 0.5


for k = 0,n_elements(colVal_MeanPhi_Summer_Dst5075) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst5075[k], mltArr_Phi_Summer_Dst5075[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst5075[k], mltArr_Phi_Summer_Dst5075[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanPhi_Summer_Dst5075[k],thick = 10
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'




map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0.5,2,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[4], charsize = 0.5


for k = 0,n_elements(colVal_MeanPhi_Summer_Dst75) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst75[k], mltArr_Phi_Summer_Dst75[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst75[k], mltArr_Phi_Summer_Dst75[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanPhi_Summer_Dst75[k],thick = 10
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'



ps_close,/no_filename








ps_open,'/home/bharat/ESAPS/Finstats/MeanPhi_dstmods_Winter.ps'

clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < 10 and > -10 nT'


for k = 0,n_elements(colVal_MeanPhi_Winter_Dst1010) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst1010[k], mltArr_Phi_Winter_Dst1010[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst1010[k], mltArr_Phi_Winter_Dst1010[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanPhi_Winter_Dst1010[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'


clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -10 and > -25 nT'


for k = 0,n_elements(colVal_MeanPhi_Winter_Dst1025) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst1025[k], mltArr_Phi_Winter_Dst1025[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst1025[k], mltArr_Phi_Winter_Dst1025[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanPhi_Winter_Dst1025[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'


clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -25 and > -50 nT'


for k = 0,n_elements(colVal_MeanPhi_Winter_Dst2550) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst2550[k], mltArr_Phi_Winter_Dst2550[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst2550[k], mltArr_Phi_Winter_Dst2550[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanPhi_Winter_Dst2550[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'



clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -50 and > -75 nT'


for k = 0,n_elements(colVal_MeanPhi_Winter_Dst5075) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst5075[k], mltArr_Phi_Winter_Dst5075[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst5075[k], mltArr_Phi_Winter_Dst5075[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanPhi_Winter_Dst5075[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'




clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -75 nT'


for k = 0,n_elements(colVal_MeanPhi_Winter_Dst75) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst75[k], mltArr_Phi_Winter_Dst75[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst75[k], mltArr_Phi_Winter_Dst75[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanPhi_Winter_Dst75[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'






ps_close,/no_filename








ps_open,'/home/bharat/ESAPS/Finstats/MaxPhi_dstmods_Summer.ps'

clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < 10 and > -10 nT'


for k = 0,n_elements(colVal_MaxPhi_Summer_Dst1010) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst1010[k], mltArr_Phi_Summer_Dst1010[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst1010[k], mltArr_Phi_Summer_Dst1010[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxPhi_Summer_Dst1010[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'


clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -10 and > -25 nT'


for k = 0,n_elements(colVal_MaxPhi_Summer_Dst1025) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst1025[k], mltArr_Phi_Summer_Dst1025[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst1025[k], mltArr_Phi_Summer_Dst1025[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxPhi_Summer_Dst1025[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'


clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -25 and > -50 nT'


for k = 0,n_elements(colVal_MaxPhi_Summer_Dst2550) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst2550[k], mltArr_Phi_Summer_Dst2550[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst2550[k], mltArr_Phi_Summer_Dst2550[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxPhi_Summer_Dst2550[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'



clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -50 and > -75 nT'


for k = 0,n_elements(colVal_MaxPhi_Summer_Dst5075) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst5075[k], mltArr_Phi_Summer_Dst5075[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst5075[k], mltArr_Phi_Summer_Dst5075[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxPhi_Summer_Dst5075[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'




clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -75 nT'


for k = 0,n_elements(colVal_MaxPhi_Summer_Dst75) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst75[k], mltArr_Phi_Summer_Dst75[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst75[k], mltArr_Phi_Summer_Dst75[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxPhi_Summer_Dst75[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'



ps_close,/no_filename








ps_open,'/home/bharat/ESAPS/Finstats/MaxPhi_dstmods_Winter.ps'

clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < 10 and > -10 nT'


for k = 0,n_elements(colVal_MaxPhi_Winter_Dst1010) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst1010[k], mltArr_Phi_Winter_Dst1010[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst1010[k], mltArr_Phi_Winter_Dst1010[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxPhi_Winter_Dst1010[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'


clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -10 and > -25 nT'


for k = 0,n_elements(colVal_MaxPhi_Winter_Dst1025) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst1025[k], mltArr_Phi_Winter_Dst1025[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst1025[k], mltArr_Phi_Winter_Dst1025[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxPhi_Winter_Dst1025[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'


clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -25 and > -50 nT'


for k = 0,n_elements(colVal_MaxPhi_Winter_Dst2550) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst2550[k], mltArr_Phi_Winter_Dst2550[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst2550[k], mltArr_Phi_Winter_Dst2550[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxPhi_Winter_Dst2550[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'



clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -50 and > -75 nT'


for k = 0,n_elements(colVal_MaxPhi_Winter_Dst5075) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst5075[k], mltArr_Phi_Winter_Dst5075[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst5075[k], mltArr_Phi_Winter_Dst5075[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxPhi_Winter_Dst5075[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'




clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -75 nT'


for k = 0,n_elements(colVal_MaxPhi_Winter_Dst75) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst75[k], mltArr_Phi_Winter_Dst75[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst75[k], mltArr_Phi_Winter_Dst75[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxPhi_Winter_Dst75[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_phi_All,legend='Potential Drop',param='power'






ps_close,/no_filename












ps_open,'/home/bharat/ESAPS/Finstats/MeanJped_den_dstmods_Summer.ps'

map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[0], charsize = 0.5


for k = 0,n_elements(colVal_MeanJped_den_Summer_Dst1010) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst1010[k], mltArr_Phi_Summer_Dst1010[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst1010[k], mltArr_Phi_Summer_Dst1010[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanJped_den_Summer_Dst1010[k],thick = 10
	
endfor

plot_colorbar, 1., 1., 0., 0.,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'

map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[1], charsize = 0.5


for k = 0,n_elements(colVal_MeanJped_den_Summer_Dst1025) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst1025[k], mltArr_Phi_Summer_Dst1025[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst1025[k], mltArr_Phi_Summer_Dst1025[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanJped_den_Summer_Dst1025[k],thick = 10
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'


map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[2], charsize = 0.5


for k = 0,n_elements(colVal_MeanJped_den_Summer_Dst2550) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst2550[k], mltArr_Phi_Summer_Dst2550[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst2550[k], mltArr_Phi_Summer_Dst2550[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanJped_den_Summer_Dst2550[k],thick = 10
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'



map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[3], charsize = 0.5


for k = 0,n_elements(colVal_MeanJped_den_Summer_Dst5075) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst5075[k], mltArr_Phi_Summer_Dst5075[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst5075[k], mltArr_Phi_Summer_Dst5075[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanJped_den_Summer_Dst5075[k],thick = 10
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'




map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0.5,2,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = title_str_noseas[4], charsize = 0.5


for k = 0,n_elements(colVal_MeanJped_den_Summer_Dst75) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst75[k], mltArr_Phi_Summer_Dst75[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst75[k], mltArr_Phi_Summer_Dst75[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanJped_den_Summer_Dst75[k],thick = 10
	
endfor

; plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'



ps_close,/no_filename








ps_open,'/home/bharat/ESAPS/Finstats/MeanJped_den_dstmods_Winter.ps'

clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < 10 and > -10 nT'


for k = 0,n_elements(colVal_MeanJped_den_Winter_Dst1010) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst1010[k], mltArr_Phi_Winter_Dst1010[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst1010[k], mltArr_Phi_Winter_Dst1010[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanJped_den_Winter_Dst1010[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'


clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -10 and > -25 nT'


for k = 0,n_elements(colVal_MeanJped_den_Winter_Dst1025) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst1025[k], mltArr_Phi_Winter_Dst1025[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst1025[k], mltArr_Phi_Winter_Dst1025[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanJped_den_Winter_Dst1025[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'


clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -25 and > -50 nT'


for k = 0,n_elements(colVal_MeanJped_den_Winter_Dst2550) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst2550[k], mltArr_Phi_Winter_Dst2550[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst2550[k], mltArr_Phi_Winter_Dst2550[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanJped_den_Winter_Dst2550[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'



clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -50 and > -75 nT'


for k = 0,n_elements(colVal_MeanJped_den_Winter_Dst5075) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst5075[k], mltArr_Phi_Winter_Dst5075[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst5075[k], mltArr_Phi_Winter_Dst5075[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanJped_den_Winter_Dst5075[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'




clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -75 nT'


for k = 0,n_elements(colVal_MeanJped_den_Winter_Dst75) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst75[k], mltArr_Phi_Winter_Dst75[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst75[k], mltArr_Phi_Winter_Dst75[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MeanJped_den_Winter_Dst75[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'






ps_close,/no_filename








ps_open,'/home/bharat/ESAPS/Finstats/MaxJped_den_dstmods_Summer.ps'

clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < 10 and > -10 nT'


for k = 0,n_elements(colVal_MaxJped_den_Summer_Dst1010) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst1010[k], mltArr_Phi_Summer_Dst1010[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst1010[k], mltArr_Phi_Summer_Dst1010[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxJped_den_Summer_Dst1010[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'


clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -10 and > -25 nT'


for k = 0,n_elements(colVal_MaxJped_den_Summer_Dst1025) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst1025[k], mltArr_Phi_Summer_Dst1025[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst1025[k], mltArr_Phi_Summer_Dst1025[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxJped_den_Summer_Dst1025[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'


clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -25 and > -50 nT'


for k = 0,n_elements(colVal_MaxJped_den_Summer_Dst2550) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst2550[k], mltArr_Phi_Summer_Dst2550[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst2550[k], mltArr_Phi_Summer_Dst2550[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxJped_den_Summer_Dst2550[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'



clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -50 and > -75 nT'


for k = 0,n_elements(colVal_MaxJped_den_Summer_Dst5075) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst5075[k], mltArr_Phi_Summer_Dst5075[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst5075[k], mltArr_Phi_Summer_Dst5075[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxJped_den_Summer_Dst5075[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'




clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -75 nT'


for k = 0,n_elements(colVal_MaxJped_den_Summer_Dst75) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Summer_Dst75[k], mltArr_Phi_Summer_Dst75[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Summer_Dst75[k], mltArr_Phi_Summer_Dst75[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxJped_den_Summer_Dst75[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'



ps_close,/no_filename








ps_open,'/home/bharat/ESAPS/Finstats/MaxJped_den_dstmods_Winter.ps'

clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < 10 and > -10 nT'


for k = 0,n_elements(colVal_MaxJped_den_Winter_Dst1010) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst1010[k], mltArr_Phi_Winter_Dst1010[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst1010[k], mltArr_Phi_Winter_Dst1010[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxJped_den_Winter_Dst1010[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'


clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -10 and > -25 nT'


for k = 0,n_elements(colVal_MaxJped_den_Winter_Dst1025) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst1025[k], mltArr_Phi_Winter_Dst1025[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst1025[k], mltArr_Phi_Winter_Dst1025[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxJped_den_Winter_Dst1025[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'


clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -25 and > -50 nT'


for k = 0,n_elements(colVal_MaxJped_den_Winter_Dst2550) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst2550[k], mltArr_Phi_Winter_Dst2550[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst2550[k], mltArr_Phi_Winter_Dst2550[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxJped_den_Winter_Dst2550[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'



clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -50 and > -75 nT'


for k = 0,n_elements(colVal_MaxJped_den_Winter_Dst5075) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst5075[k], mltArr_Phi_Winter_Dst5075[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst5075[k], mltArr_Phi_Winter_Dst5075[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxJped_den_Winter_Dst5075[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'




clear_page
map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, title = 'Dst < -75 nT'


for k = 0,n_elements(colVal_MaxJped_den_Winter_Dst75) -1 do begin

	stereCr_low = calc_stereo_coords( Minlat_Phi_Winter_Dst75[k], mltArr_Phi_Winter_Dst75[k], /mlt )
	
	stereCr_pole = calc_stereo_coords( Maxlat_Phi_Winter_Dst75[k], mltArr_Phi_Winter_Dst75[k], /mlt )

	oplot, [ stereCr_low[0],stereCr_pole[0] ], [ stereCr_low[1],stereCr_pole[1] ], color = colVal_MaxJped_den_Winter_Dst75[k],thick = 10
	
endfor

plot_colorbar, 1.5, 1.5, 0.6, 0.5,scale=Scale_J_All,legend=textoidl('Current Intensity [\mu A/m^{2}]'), level_format='(f6.2)',param='power'






ps_close,/no_filename



ps_open,'/home/bharat/ESAPS/Finstats/Latwidths_dstmods.ps'

LatWidth_Winter_Dst1010 = fltarr(n_elements(Maxlat_Phi_Winter_Dst1010))
mltVal_Winter_Dst1010 = fltarr(n_elements(Maxlat_Phi_Winter_Dst1010))

for j = 0,n_elements(Maxlat_Phi_Winter_Dst1010) -1 do begin
	LatWidth_Winter_Dst1010[j] = Maxlat_Phi_Winter_Dst1010[j] - Minlat_Phi_Winter_Dst1010[j]
	
	if (mltArr_Phi_Winter_Dst1010[j] gt 3.) then begin
		mltVal_Winter_Dst1010[j] = mltArr_Phi_Winter_Dst1010[j] - 24.
	endif else begin
		mltVal_Winter_Dst1010[j] = mltArr_Phi_Winter_Dst1010[j]
	endelse
	
	
endfor




LatWidth_Summer_Dst1010 = fltarr(n_elements(Maxlat_Phi_Summer_Dst1010))
mltVal_Summer_Dst1010 = fltarr(n_elements(Maxlat_Phi_Summer_Dst1010))

for j = 0,n_elements(Maxlat_Phi_Summer_Dst1010) -1 do begin
	LatWidth_Summer_Dst1010[j] = Maxlat_Phi_Summer_Dst1010[j] - Minlat_Phi_Summer_Dst1010[j]
	
	if (mltArr_Phi_Summer_Dst1010[j] gt 3.) then begin
		mltVal_Summer_Dst1010[j] = mltArr_Phi_Summer_Dst1010[j] - 24.
	endif else begin
		mltVal_Summer_Dst1010[j] = mltArr_Phi_Summer_Dst1010[j]
	endelse
	
	
endfor







LatWidth_Winter_Dst1025 = fltarr(n_elements(Maxlat_Phi_Winter_Dst1025))
mltVal_Winter_Dst1025 = fltarr(n_elements(Maxlat_Phi_Winter_Dst1025))

for j = 0,n_elements(Maxlat_Phi_Winter_Dst1025) -1 do begin
	LatWidth_Winter_Dst1025[j] = Maxlat_Phi_Winter_Dst1025[j] - Minlat_Phi_Winter_Dst1025[j]
	
	if (mltArr_Phi_Winter_Dst1025[j] gt 3.) then begin
		mltVal_Winter_Dst1025[j] = mltArr_Phi_Winter_Dst1025[j] - 24.
	endif else begin
		mltVal_Winter_Dst1025[j] = mltArr_Phi_Winter_Dst1025[j]
	endelse
	
	
endfor




LatWidth_Summer_Dst1025 = fltarr(n_elements(Maxlat_Phi_Summer_Dst1025))
mltVal_Summer_Dst1025 = fltarr(n_elements(Maxlat_Phi_Summer_Dst1025))

for j = 0,n_elements(Maxlat_Phi_Summer_Dst1025) -1 do begin
	LatWidth_Summer_Dst1025[j] = Maxlat_Phi_Summer_Dst1025[j] - Minlat_Phi_Summer_Dst1025[j]
	
	if (mltArr_Phi_Summer_Dst1025[j] gt 3.) then begin
		mltVal_Summer_Dst1025[j] = mltArr_Phi_Summer_Dst1025[j] - 24.
	endif else begin
		mltVal_Summer_Dst1025[j] = mltArr_Phi_Summer_Dst1025[j]
	endelse
	
	
endfor




LatWidth_Winter_Dst2550 = fltarr(n_elements(Maxlat_Phi_Winter_Dst2550))
mltVal_Winter_Dst2550 = fltarr(n_elements(Maxlat_Phi_Winter_Dst2550))

for j = 0,n_elements(Maxlat_Phi_Winter_Dst2550) -1 do begin
	LatWidth_Winter_Dst2550[j] = Maxlat_Phi_Winter_Dst2550[j] - Minlat_Phi_Winter_Dst2550[j]
	
	if (mltArr_Phi_Winter_Dst2550[j] gt 3.) then begin
		mltVal_Winter_Dst2550[j] = mltArr_Phi_Winter_Dst2550[j] - 24.
	endif else begin
		mltVal_Winter_Dst2550[j] = mltArr_Phi_Winter_Dst2550[j]
	endelse
	
	
endfor




LatWidth_Summer_Dst2550 = fltarr(n_elements(Maxlat_Phi_Summer_Dst2550))
mltVal_Summer_Dst2550 = fltarr(n_elements(Maxlat_Phi_Summer_Dst2550))

for j = 0,n_elements(Maxlat_Phi_Summer_Dst2550) -1 do begin
	LatWidth_Summer_Dst2550[j] = Maxlat_Phi_Summer_Dst2550[j] - Minlat_Phi_Summer_Dst2550[j]
	
	if (mltArr_Phi_Summer_Dst2550[j] gt 3.) then begin
		mltVal_Summer_Dst2550[j] = mltArr_Phi_Summer_Dst2550[j] - 24.
	endif else begin
		mltVal_Summer_Dst2550[j] = mltArr_Phi_Summer_Dst2550[j]
	endelse
	
	
endfor






LatWidth_Winter_Dst5075 = fltarr(n_elements(Maxlat_Phi_Winter_Dst5075))
mltVal_Winter_Dst5075 = fltarr(n_elements(Maxlat_Phi_Winter_Dst5075))

for j = 0,n_elements(Maxlat_Phi_Winter_Dst5075) -1 do begin
	LatWidth_Winter_Dst5075[j] = Maxlat_Phi_Winter_Dst5075[j] - Minlat_Phi_Winter_Dst5075[j]
	
	if (mltArr_Phi_Winter_Dst5075[j] gt 3.) then begin
		mltVal_Winter_Dst5075[j] = mltArr_Phi_Winter_Dst5075[j] - 24.
	endif else begin
		mltVal_Winter_Dst5075[j] = mltArr_Phi_Winter_Dst5075[j]
	endelse
	
	
endfor




LatWidth_Summer_Dst5075 = fltarr(n_elements(Maxlat_Phi_Summer_Dst5075))
mltVal_Summer_Dst5075 = fltarr(n_elements(Maxlat_Phi_Summer_Dst5075))

for j = 0,n_elements(Maxlat_Phi_Summer_Dst5075) -1 do begin
	LatWidth_Summer_Dst5075[j] = Maxlat_Phi_Summer_Dst5075[j] - Minlat_Phi_Summer_Dst5075[j]
	
	if (mltArr_Phi_Summer_Dst5075[j] gt 3.) then begin
		mltVal_Summer_Dst5075[j] = mltArr_Phi_Summer_Dst5075[j] - 24.
	endif else begin
		mltVal_Summer_Dst5075[j] = mltArr_Phi_Summer_Dst5075[j]
	endelse
	
	
endfor



LatWidth_Winter_Dst75 = fltarr(n_elements(Maxlat_Phi_Winter_Dst75))
mltVal_Winter_Dst75 = fltarr(n_elements(Maxlat_Phi_Winter_Dst75))

for j = 0,n_elements(Maxlat_Phi_Winter_Dst75) -1 do begin
	LatWidth_Winter_Dst75[j] = Maxlat_Phi_Winter_Dst75[j] - Minlat_Phi_Winter_Dst75[j]
	
	if (mltArr_Phi_Winter_Dst75[j] gt 3.) then begin
		mltVal_Winter_Dst75[j] = mltArr_Phi_Winter_Dst75[j] - 24.
	endif else begin
		mltVal_Winter_Dst75[j] = mltArr_Phi_Winter_Dst75[j]
	endelse
	
	
endfor




LatWidth_Summer_Dst75 = fltarr(n_elements(Maxlat_Phi_Summer_Dst75))
mltVal_Summer_Dst75 = fltarr(n_elements(Maxlat_Phi_Summer_Dst75))

for j = 0,n_elements(Maxlat_Phi_Summer_Dst75) -1 do begin
	LatWidth_Summer_Dst75[j] = Maxlat_Phi_Summer_Dst75[j] - Minlat_Phi_Summer_Dst75[j]
	
	if (mltArr_Phi_Summer_Dst75[j] gt 3.) then begin
		mltVal_Summer_Dst75[j] = mltArr_Phi_Summer_Dst75[j] - 24.
	endif else begin
		mltVal_Summer_Dst75[j] = mltArr_Phi_Summer_Dst75[j]
	endelse
	
	
endfor




plot,mltVal_Summer_Dst1010,LatWidth_Summer_Dst1010, title = ' ', xtitle = 'MLT', ytitle = 'Latitudinal Width in Degrees', yrange = [0,10], color = get_black(), thick = 5
oplot,mltVal_Summer_Dst1025,LatWidth_Summer_Dst1025, color = get_blue(), thick = 5
oplot,mltVal_Summer_Dst2550,LatWidth_Summer_Dst2550, color = get_green(), thick = 5
oplot,mltVal_Summer_Dst5075,LatWidth_Summer_Dst5075, color = get_yellow(), thick = 5
oplot,mltVal_Summer_Dst75,LatWidth_Summer_Dst75, color = get_red(), thick = 5

clear_page

plot,mltVal_Winter_Dst1010,LatWidth_Winter_Dst1010, color = get_black(), thick = 5, linestyle = 2, title = 'Winter', xtitle = 'MLT', ytitle = 'Latitudinal Width in Degrees', yrange = [0,10]
oplot,mltVal_Winter_Dst1025,LatWidth_Winter_Dst1025, color = get_blue(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst2550,LatWidth_Winter_Dst2550, color = get_green(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst5075,LatWidth_Winter_Dst5075, color = get_yellow(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst75,LatWidth_Winter_Dst75, color = get_red(), thick = 5, linestyle = 2


clear_page


plot,mltVal_Summer_Dst1010, MaxPhi_Summer_Dst1010, title = ' ', xtitle = 'MLT', ytitle = 'Max Potential drop across SAPS channel', yrange = [0,50], color = get_black(), thick = 5
oplot,mltVal_Summer_Dst1025,MaxPhi_Summer_Dst1025, color = get_blue(), thick = 5
oplot,mltVal_Summer_Dst2550,MaxPhi_Summer_Dst2550, color = get_green(), thick = 5
oplot,mltVal_Summer_Dst5075,MaxPhi_Summer_Dst5075, color = get_yellow(), thick = 5
oplot,mltVal_Summer_Dst75,MaxPhi_Summer_Dst75, color = get_red(), thick = 5

clear_page

plot,mltVal_Winter_Dst1010,MaxPhi_Winter_Dst1010, color = get_black(), thick = 5, linestyle = 2, title = 'Winter', xtitle = 'MLT', ytitle = 'Max Potential drop across SAPS channel', yrange = [0,50]
oplot,mltVal_Winter_Dst1025,MaxPhi_Winter_Dst1025, color = get_blue(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst2550,MaxPhi_Winter_Dst2550, color = get_green(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst5075,MaxPhi_Winter_Dst5075, color = get_yellow(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst75,MaxPhi_Winter_Dst75, color = get_red(), thick = 5, linestyle = 2


clear_page


plot,mltVal_Summer_Dst1010, MeanPhi_Summer_Dst1010, title = ' ', xtitle = 'MLT', ytitle = 'Mean Potential drop across SAPS channel', yrange = [0,30], color = get_black(), thick = 5
oplot,mltVal_Summer_Dst1025,MeanPhi_Summer_Dst1025, color = get_blue(), thick = 5
oplot,mltVal_Summer_Dst2550,MeanPhi_Summer_Dst2550, color = get_green(), thick = 5
oplot,mltVal_Summer_Dst5075,MeanPhi_Summer_Dst5075, color = get_yellow(), thick = 5
oplot,mltVal_Summer_Dst75,MeanPhi_Summer_Dst75, color = get_red(), thick = 5

clear_page

plot,mltVal_Winter_Dst1010,MeanPhi_Winter_Dst1010, color = get_black(), thick = 5, linestyle = 2, title = 'Winter', xtitle = 'MLT', ytitle = 'Mean Potential drop across SAPS channel', yrange = [0,30]
oplot,mltVal_Winter_Dst1025,MeanPhi_Winter_Dst1025, color = get_blue(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst2550,MeanPhi_Winter_Dst2550, color = get_green(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst5075,MeanPhi_Winter_Dst5075, color = get_yellow(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst75,MeanPhi_Winter_Dst75, color = get_red(), thick = 5, linestyle = 2


clear_page


plot,mltVal_Summer_Dst1010, MaxJped_den_Summer_Dst1010, title = ' ', xtitle = 'MLT', ytitle = 'Max Curr. Density', yrange = [0,2], color = get_black(), thick = 5
oplot,mltVal_Summer_Dst1025,MaxJped_den_Summer_Dst1025, color = get_blue(), thick = 5
oplot,mltVal_Summer_Dst2550,MaxJped_den_Summer_Dst2550, color = get_green(), thick = 5
oplot,mltVal_Summer_Dst5075,MaxJped_den_Summer_Dst5075, color = get_yellow(), thick = 5
oplot,mltVal_Summer_Dst75,MaxJped_den_Summer_Dst75, color = get_red(), thick = 5

clear_page

plot,mltVal_Winter_Dst1010,MaxJped_den_Winter_Dst1010, color = get_black(), thick = 5, linestyle = 2, title = 'Winter', xtitle = 'MLT', ytitle = 'Max Curr. Density', yrange = [0,2]
oplot,mltVal_Winter_Dst1025,MaxJped_den_Winter_Dst1025, color = get_blue(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst2550,MaxJped_den_Winter_Dst2550, color = get_green(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst5075,MaxJped_den_Winter_Dst5075, color = get_yellow(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst75,MaxJped_den_Winter_Dst75, color = get_red(), thick = 5, linestyle = 2



clear_page


plot,mltVal_Summer_Dst1010, MeanJped_den_Summer_Dst1010, title = ' ', xtitle = 'MLT', ytitle = 'Mean Curr. Density', yrange = [0,2], color = get_black(), thick = 5
oplot,mltVal_Summer_Dst1025,MeanJped_den_Summer_Dst1025, color = get_blue(), thick = 5
oplot,mltVal_Summer_Dst2550,MeanJped_den_Summer_Dst2550, color = get_green(), thick = 5
oplot,mltVal_Summer_Dst5075,MeanJped_den_Summer_Dst5075, color = get_yellow(), thick = 5
oplot,mltVal_Summer_Dst75,MeanJped_den_Summer_Dst75, color = get_red(), thick = 5

clear_page

plot,mltVal_Winter_Dst1010,MeanJped_den_Winter_Dst1010, color = get_black(), thick = 5, linestyle = 2, title = 'Winter', xtitle = 'MLT', ytitle = 'Mean Curr. Density', yrange = [0,2]
oplot,mltVal_Winter_Dst1025,MeanJped_den_Winter_Dst1025, color = get_blue(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst2550,MeanJped_den_Winter_Dst2550, color = get_green(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst5075,MeanJped_den_Winter_Dst5075, color = get_yellow(), thick = 5, linestyle = 2
oplot,mltVal_Winter_Dst75,MeanJped_den_Winter_Dst75, color = get_red(), thick = 5, linestyle = 2


ps_close,/no_filename

end

