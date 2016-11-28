pro saps_poes

common rad_data_blk

rad_load_colortable,/leicester

;; events selected
dateSel = [ 20130317 ]
timeSel = [ 2000 ]
dstIndex = [ -116. ]
;; set plot/map parameters
xrangePlot = [-44, 44]
yrangePlot = [-44,30]
velScale = [0,1000]
probScale = [0.,1.]

cntrMinVal = 0.2
n_levels = 5
coords = "mlt"
;; some model parameters
a_sx = 3.11
b_sx = 0.00371
a_sy = 1.72
b_sy = -0.000819
a_xo = 4.59
b_xo = 0.0633
a_yo = -1.19
b_yo = 0.0321
a_o = 0.893
b_o = -0.00147
theta = 0.692

;; for each dst setup the model/data and create corresponding contours
;; we'll use latitudes --> [50,70] & MLT --> [0, 24]
;; setup arrays to store lats, mlts and saps probs
;; from the lat and mlt info we know there are 21 Lats and 240 Mlts
strLatArr = fltarr(22, 362)
strMltArr = fltarr(22, 362)
mlonArr = fltarr(22, 362)
mltArr = fltarr(22, 362)
latArr = fltarr(22, 362)
probArr = fltarr(22, 362)
countLat = 0.
for lat = 50., 70. do begin
    countLat += 1.
    countLon = 0.
    for currMlon = 0., 360. do begin
        countLon += 1
        latArr[countLat,countLon] = lat
        mlonArr[countLat,countLon] = currMlon

        
        

        ;; calculate juls from date and time
        sfjul, dateSel[0], timeSel[0], jul_curr
        caldat,jul_curr, evnt_month, evnt_day, evnt_year, strt_hour, strt_min, strt_sec
        currMlt = mlt( dateSel[0], timeymdhmstoyrsec( evnt_year, evnt_month, evnt_day, strt_hour, strt_min, strt_sec ), currMlon )
        mltArr[countLat,countLon] = currMlt

        stereoCoords = calc_stereo_coords( lat, currMlt,/ mlt )
        strLatArr[countLat,countLon] = stereoCoords[0]
        strMltArr[countLat,countLon] = stereoCoords[1]


        ;; setup stuff for model
        dst = dstIndex[0]
        sigma_x = a_sx + b_sx * dst
        sigma_y = a_sy + b_sy * dst
        xo = a_xo + b_xo * dst
        yo = a_yo + b_yo * dst
        amplitude = a_o + b_o * dst
        ;; we use normalized latitudes and logitudes for the model
        normLat = lat - 57.5
        if ( currMlt ge 12. ) then begin
            normMlt = currMlt - 24.
        endif else begin
            normMlt = currMlt
        endelse



        a = (cos(theta)^2)/(2*sigma_x^2) + (sin(theta)^2)/(2*sigma_y^2)
        b = -(sin(2*theta))/(4*sigma_x^2) + (sin(2*theta))/(4*sigma_y^2)
        c = (sin(theta)^2)/(2*sigma_x^2) + (cos(theta)^2)/(2*sigma_y^2)
        currProb = amplitude*exp( - (a*((normLat-xo)^2) + 2*b*(normLat-xo)*(normMlt-yo) + $
                        c*((normMlt-yo)^2)))
        
        probArr[countLat,countLon] = currProb
    endfor
endfor



;; read data from the poes files
fNamePoesEle = "/home/bharatr/Docs/data/eleflux.txt"
fNamePoesPro = "/home/bharatr/Docs/data/proflux.txt"

;; cols - timestamp date aacgm_lat_foot aacgm_lon_foot MLT log_ele_flux sat dateStr time


nel_arr_all = 100000

mlatArrEle = fltarr(nel_arr_all)
mlonArrEle = fltarr(nel_arr_all)
mltArrEle = fltarr(nel_arr_all)
logEleFluxArrEle = fltarr(nel_arr_all)
satArrEle = strarr(nel_arr_all)
dateArrEle = lonarr(nel_arr_all)
timeArrEle = lonarr(nel_arr_all)
julsArrEle = dblarr(nel_arr_all)


nv=0
OPENR, 1, fNamePoesEle
WHILE not eof(1) do begin
    READF,1,timestamp, date, aacgm_lat_foot, aacgm_lon_foot, MLT, log_ele_flux, sat, dateStr, timeCurr

    print,timestamp, date, aacgm_lat_foot, aacgm_lon_foot, MLT, log_ele_flux, sat, dateStr, timeCurr


    mlatArrEle[nv] = aacgm_lat_foot

    mlonArrEle[nv] = aacgm_lon_foot
    
    mltArrEle[nv] = MLT
    
    logEleFluxArrEle[nv] = log_ele_flux
    satArrEle[nv] = sat
    dateArrEle[nv] = dateStr
        
    timeArrEle[nv] = timeCurr

    sfjul, dateStr, timeCurr, juls_curr
    julsArrEle[nv] = juls_curr

    nv=nv+1   
ENDWHILE         
close,1


mlatArrEle = mlatArrEle[0:nv-1] 
mlonArrEle = mlonArrEle[0:nv-1] 
mltArrEle = mltArrEle[0:nv-1]

logEleFluxArrEle = logEleFluxArrEle[0:nv-1] 
satArrEle = satArrEle[0:nv-1] 
dateArrEle = dateArrEle[0:nv-1]

timeArrEle = timeArrEle[0:nv-1]
julsArrEle = julsArrEle[0:nv-1]


;; get the time range chosen
sfjul, dateSel[0], timeSel[0], jul_time_sel
jul_range_poes = [jul_poes - 45./1440.d, jul_poes + 45./1440.d] 
sfjul, date_range_poes, time_range_poes, jul_range_poes, /jul_to_date
print, "POES times selected-->", date_range_poes, time_range_poes



jindsTimeSel = where( (julsArrEle ge jul_range_poes[0]) and (julsArrEle le jul_range_poes[1]) and ( mlatArrEle ge 50. ) )

julsSelTimes = julsArrEle[ jindsTimeSel ]
mlatSelTimes = mlatArrEle[ jindsTimeSel ]
mlonSelTimes = mlonArrEle[ jindsTimeSel ]
mltSelTimes = mltArrEle[ jindsTimeSel ]
logEleFluxSelTimes = logEleFluxArrEle[ jindsTimeSel ]
satSelTimes = satArrEle[ jindsTimeSel ]

poesScale = [ min(logEleFluxSelTimes), max(logEleFluxSelTimes) ]










ps_open, '/home/bharatr/Docs/plots/saps-model-test.ps'

map_plot_panel,date=dateSel[0],time=timeSel[0],coords=coords,/no_fill,xrange=xrangePlot, $
        yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, $
        title = string(dateSel[0]) + "-" + strtrim( string(timeSel[0]), 2), charsize = 0.5

;; overlay dmsp
rad_map_overlay_dmsp, dateSel[0], timeSel[0], coords = coords, $
                    hemisphere = hemisphere,/ssj, /ssies
dmsp_ssj_fit_eqbnd, dateSel[0], timeSel[0], coords = coords              

;; plot map potential vectors
rad_map_read, dateSel[0]
rad_map_overlay_vectors, date = dateSel[0], time=timeSel[0], coords = coords, $
                 /no_fov_names, /no_show_Nvc

;;radar_ids = [ 209, 208, 33, 207, 206, 205, 204, 32 ],              
;; plot the prob contour
;;contour, probArr, strLatArr, strMltArr, $
;;        /overplot, xstyle=4, ystyle=4, noclip=0, thick = 2., $
;;        levels=cntrMinVal+(probScale[1]-cntrMinVal)*findgen(n_levels+1.)/float(n_levels), /follow


for k = 0,n_elements(mlatSelTimes) -1 do begin
    
    ;;if ( currProbSel[k] lt .2 ) then continue

    stereCr_low = calc_stereo_coords( mlatSelTimes[k], mltSelTimes[k], /mlt )

    colValCurr = get_color_index(logEleFluxSelTimes[k],scale=poesScale,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
    
    oplot, [stereCr_low[0]], [stereCr_low[1]], color = colValCurr,thick = selSymThick, psym=8, SYMSIZE=selSymSize
    
endfor



ps_close, /no_filename

end