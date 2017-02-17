pro paul_plots


dateSel = 20160315;20010716
timeSel = 1943;1053
coords = "mlt"
velScale = [ 0, 1000 ]

load_usersym, /circle

rad_map_read, dateSel

ps_open, '/home/bharatr/Docs/plots/paul-plots-' + strtrim( string(dateSel[0]), 2) + '.ps'

rad_map_plot, date=dateSel, time=timeSel, coords=coords, /no_fov_names,/contour_fill, scale=velScale,/no_plot_imf_ind,/coast,/no_fill,/vectors,/potential


sfjul, dateSel, timeSel, jul_curr
caldat,jul_curr, year_var, mon_var, dd_var, hh_var, mm_var, sec_var

Mg_crd_CBB=cnvcoord( 69.123, 254.96, 350. )
mlt_crd_CBB = mlt( year_var, timeymdhmstoyrsec(year_var, mon_var, dd_var, hh_var, mm_var, sec_var), Mg_crd_CBB[1] )
stereo_crd_CBB = calc_stereo_coords( Mg_crd_CBB[0] , mlt_crd_CBB , mlt = !true )
oplot, [ stereo_crd_CBB[0] ], [ stereo_crd_CBB[1] ], psym = 8, symsize = 0.5, thick = 2.5, color = get_black()
oplot, [ stereo_crd_CBB[0] ], [ stereo_crd_CBB[1] ], psym = 1, symsize = 1., thick = 4.5, color = get_black()
xyouts, stereo_crd_CBB[0]+2., stereo_crd_CBB[1], 'CBB', charsize='0.5', charthick=2

Mg_crd_LYR=cnvcoord( 78.20, 15.82, 350. )
mlt_crd_LYR = mlt( year_var, timeymdhmstoyrsec(year_var, mon_var, dd_var, hh_var, mm_var, sec_var), Mg_crd_LYR[1] )
stereo_crd_LYR = calc_stereo_coords( Mg_crd_LYR[0] , mlt_crd_LYR , mlt = !true )
oplot, [ stereo_crd_LYR[0] ], [ stereo_crd_LYR[1] ], psym = 8, symsize = 0.5, thick = 2.5, color = get_black()
oplot, [ stereo_crd_LYR[0] ], [ stereo_crd_LYR[1] ], psym = 1, symsize = 1., thick = 4.5, color = get_black()
xyouts, stereo_crd_LYR[0]+2., stereo_crd_LYR[1], 'LYR', charsize='0.5', charthick=2

ps_close,/no_filename


end