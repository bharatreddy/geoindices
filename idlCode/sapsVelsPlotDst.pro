pro sapsVelsPlotDst


fNameSP = "/home/bharatr/Docs/data/sapsVels.txt"

rad_load_colortable,/leicester

nel_arr_all = 10000
dstMedianArr = lonarr(nel_arr_all)
countNppntsArr = intarr(nel_arr_all)
maxCountsArr = intarr(nel_arr_all)
meanVelArr = fltarr(nel_arr_all)
mltArr = fltarr(nel_arr_all)

latArr = fltarr(nel_arr_all)
dstBinArr = fltarr(nel_arr_all)



nv=0
OPENR, 1, fNameSP
WHILE not eof(1) do begin

	;0.0 59.5 301.334863116 0.0 0.306648575305 -5.0
	READF,1, currMLT, currLat, meanVel, normMLT, predProb, dst_median

    print,currMLT, currLat, meanVel, normMLT, predProb, dst_median


    dstMedianArr[nv] = dst_median
    
    meanVelArr[nv] = meanVel
    mltArr[nv] = currMLT
        
    latArr[nv] = currLat
    if ( dst_median eq -95) then $
    	dstBinArr[nv] = "-150 < dst < -75"
    if ( dst_median eq -57) then $
    	dstBinArr[nv] = "-75 < dst < -50"
    if ( dst_median eq -36) then $
    	dstBinArr[nv] = "-50 < dst < -25"
    if ( dst_median eq -18) then $
    	dstBinArr[nv] = "-25 < dst < -10"
    if ( dst_median eq -5) then $
    	dstBinArr[nv] = "-10 < dst < 10"
    

    nv=nv+1   
ENDWHILE         
close,1


dstMedianArr = dstMedianArr[0:nv-1] 
countNppntsArr = countNppntsArr[0:nv-1] 
maxCountsArr = maxCountsArr[0:nv-1]

meanVelArr = meanVelArr[0:nv-1] 
mltArr = mltArr[0:nv-1]

latArr = latArr[0:nv-1]
dstBinArr = dstBinArr[0:nv-1]

;; get the indices of data in different groups
jindsDst15075 = where( ( ( dstMedianArr eq -95. ) )  )
jindsDst7550 = where( ( ( dstMedianArr eq -57. ) )  )
jindsDst5025 = where( ( ( dstMedianArr eq -36. ) )  )
jindsDst2510 = where( ( ( dstMedianArr eq -18. ) )  )
jindsDst1010 = where( ( ( dstMedianArr eq -5. ) )  )


;; plot the data

;; set a few parameters for the plot
date = 20110403
time = 0400
coords = 'mlt'
xrangePlot = [-44, 44]
yrangePlot = [-44,20]
velScale = [0,1000.]
selSymThick = 0.5
selSymSize = 0.5
load_usersym, /circle

ps_open,'/home/bharatr/Docs/plots/saps-vels-map.ps'

map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0.5,2,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = "-150 < Dst < -75", charsize = 0.5

currLatSel = latArr[jindsDst15075]
currMLTSel = mltArr[jindsDst15075]
currVelSel = meanVelArr[jindsDst15075]

for k = 0,n_elements(currLatSel) -1 do begin
	
	if ( currVelSel[k] lt .2 ) then continue

	stereCr_low = calc_stereo_coords( currLatSel[k], currMLTSel[k], /mlt )

	colValCurr = get_color_index(currVelSel[k],scale=velScale,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	
	oplot, [stereCr_low[0]], [stereCr_low[1]], color = colValCurr,thick = selSymThick, psym=8, SYMSIZE=selSymSize
	
endfor

map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = "-75 < Dst < -50", charsize = 0.5

currLatSel = latArr[jindsDst7550]
currMLTSel = mltArr[jindsDst7550]
currVelSel = meanVelArr[jindsDst7550]

for k = 0,n_elements(currLatSel) -1 do begin
	
	if ( currVelSel[k] lt .2 ) then continue

	stereCr_low = calc_stereo_coords( currLatSel[k], currMLTSel[k], /mlt )

	colValCurr = get_color_index(currVelSel[k],scale=velScale,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	
	oplot, [stereCr_low[0]], [stereCr_low[1]], color = colValCurr,thick = selSymThick, psym=8, SYMSIZE=selSymSize
	
endfor


map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,1,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = "-50 < Dst < -25", charsize = 0.5

currLatSel = latArr[jindsDst5025]
currMLTSel = mltArr[jindsDst5025]
currVelSel = meanVelArr[jindsDst5025]

for k = 0,n_elements(currLatSel) -1 do begin
	
	if ( currVelSel[k] lt .2 ) then continue

	stereCr_low = calc_stereo_coords( currLatSel[k], currMLTSel[k], /mlt )

	colValCurr = get_color_index(currVelSel[k],scale=velScale,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	
	oplot, [stereCr_low[0]], [stereCr_low[1]], color = colValCurr,thick = selSymThick, psym=8, SYMSIZE=selSymSize
	
endfor


map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,1,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = "-25 < Dst < -10", charsize = 0.5

currLatSel = latArr[jindsDst2510]
currMLTSel = mltArr[jindsDst2510]
currVelSel = meanVelArr[jindsDst2510]

for k = 0,n_elements(currLatSel) -1 do begin
	
	if ( currVelSel[k] lt .2 ) then continue

	stereCr_low = calc_stereo_coords( currLatSel[k], currMLTSel[k], /mlt )

	colValCurr = get_color_index(currVelSel[k],scale=velScale,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	
	oplot, [stereCr_low[0]], [stereCr_low[1]], color = colValCurr,thick = selSymThick, psym=8, SYMSIZE=selSymSize
	
endfor


map_plot_panel,date=date,time=time,coords=coords,/no_fill,xrange=xrangePlot,yrange=yrangePlot,/no_coast,pos=define_panel(2,3,0,0,/bar),/isotropic,grid_charsize='0.5',/north, $
	title = "-10 < Dst < 10", charsize = 0.5

currLatSel = latArr[jindsDst1010]
currMLTSel = mltArr[jindsDst1010]
currVelSel = meanVelArr[jindsDst1010]

for k = 0,n_elements(currLatSel) -1 do begin
	
	if ( currVelSel[k] lt .2 ) then continue

	stereCr_low = calc_stereo_coords( currLatSel[k], currMLTSel[k], /mlt )

	colValCurr = get_color_index(currVelSel[k],scale=velScale,colorsteps=get_colorsteps(),ncolors=get_ncolors(), param='power')
	
	oplot, [stereCr_low[0]], [stereCr_low[1]], color = colValCurr,thick = selSymThick, psym=8, SYMSIZE=selSymSize
	
endfor



plot_colorbar, 1., 1., 0., 0.,scale=velScale,legend='SAPS Velocity [m/s]', param='power'

ps_close, /no_filename


end