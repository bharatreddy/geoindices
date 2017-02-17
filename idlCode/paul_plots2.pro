pro paul_plots2


dateSel = 20160315;20010716;
timeSel = 1942;1052;
coords = "mlt"
velScale = [ 0, 800 ]

xrange_nth = [-40,40]
yrange_nth = [-40,40]

load_usersym, /circle

rad_map_read, dateSel


set_format, /sard, /portrait
rad_load_colortable,/leicester


ps_open, '/home/bharatr/Docs/plots/paul-plots-type2-' + strtrim( string(dateSel[0]), 2) + '.ps'

rad_mapex_paul, date = datesel, time = timesel, hemisphere = 1, coords = 'mlt', $
				/no_plot_imf_ind, xrange = xrange_nth, yrange = yrange_nth, scale = velScale,/contour_fill



ps_close,/no_filename


end