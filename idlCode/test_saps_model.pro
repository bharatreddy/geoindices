pro test_saps_model

common rad_data_blk

rad_load_colortable,/leicester

;; events selected
dateSel = [ 20130317 ];[20150409];
timeSel = [ 2000 ];[0630];
dstIndex = [ -116. ];[-3];
;; set plot/map parameters
xrangePlot = [-44, 44]
yrangePlot = [-44,30]
velScale = [0,800]
probScale = [0.,1.]
cntrMinVal = 0.2
n_levels = 5
coords = "mlt"
;; some model parameters
a_sx = 3.11
b_sx = 0.00371
a_sy = 1.72
b_sy = 0.000819
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


ps_open, '/home/bharatr/Docs/plots/saps-model-test-mar17.ps'

map_plot_panel,date=dateSel[0],time=timeSel[0],coords=coords,/no_fill,xrange=xrangePlot, $
        yrange=yrangePlot,/no_coast,pos=define_panel(1,1,0,0,/bar),/isotropic,grid_charsize='0.5',/north, $
        title = string(dateSel[0]) + "-" + strtrim( string(timeSel[0]), 2), charsize = 0.5

;; overlay dmsp
rad_map_overlay_dmsp, dateSel[0], timeSel[0], coords = coords, $
                    hemisphere = hemisphere, /ssies
dmsp_ssj_fit_eqbnd, dateSel[0], timeSel[0], coords = coords              

;; plot map potential vectors
rad_map_read, dateSel[0]
rad_map_overlay_vectors, date = dateSel[0], time=timeSel[0], coords = coords, $
                 /no_fov_names, /no_show_Nvc, scale=velScale

;;radar_ids = [ 209, 208, 33, 207, 206, 205, 204, 32 ],              
;; plot the prob contour
contour, probArr, strLatArr, strMltArr, $
        /overplot, xstyle=4, ystyle=4, noclip=0, thick = 2., $
        levels=cntrMinVal+(probScale[1]-cntrMinVal)*findgen(n_levels+1.)/float(n_levels), /follow

plot_colorbar, 1., 1., 0., 0.,scale=velScale,legend='Velocity [m/s]', param='power'

ps_close, /no_filename

end