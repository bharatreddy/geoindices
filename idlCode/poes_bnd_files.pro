pro poes_bnd_files


date_rng = [ 20110101, 20131231 ]



time_rng=[0000,2400]

del_skip_time = 30.d
del_juls = del_skip_time/1440.d ;;; This is the time step used to read the data



dt_skip_time=1440.d ;;; 
del_jul=dt_skip_time/1440.d 
sfjul, date_rng, time_rng, sjul_day, fjul_day
ndays_search=((fjul_day-sjul_day)/del_jul)+1 



; now instead of putting all the data in a single file
; we'll seperate data by event days into seperate files
; then deal with one event/day at a time!!!
baseDir = '/home/bharatr/Docs/data/aurdata/poes/'



for srchDay=0.d,double(ndays_search) do begin

	
	;;;Calculate the current jul
	juls_day=sjul_day+srchDay*del_jul
    sfjul,dateDay,timeDay,juls_day,/jul_to_date
    print, "date and time sel--->", dateDay,timeDay

    fname_peos = baseDir + 'poes-fit-' + strtrim( string(dateDay), 2 ) + '.txt'
	print, 'OPENING FIRST EVENT FILE-->', fname_peos
	openw,1,fname_peos

	
	sfjul, dateDay, time_rng, sjjCurr, fjjCurr
	nele_search=((fjjCurr-sjjCurr)/del_juls)+1 

	for srch=0, double(nele_search)-1 do begin

			jul_curr = sjjCurr + srch*del_juls 

			sfjul, date_curr, time_curr, jul_curr, /jul_to_date
	
			date_curr = date_curr[0]

			fitPOESjul = jul_curr

			equ_oval_bnd_data_arr = aur_equ_bnd( date_curr, time_curr, coords="magn" )
			fitPOESjul = jul_curr


			if ( equ_oval_bnd_data_arr[0,0] eq 0. ) then begin
				print, "no data in poes!"
				continue
			endif

			poesOutSize = size(equ_oval_bnd_data_arr)
			for p =0, poesOutSize[1] -1 do begin

				printf,1, date_curr, time_curr, equ_oval_bnd_data_arr[p,0], equ_oval_bnd_data_arr[p,1], format='(I8, I5, 2f11.4)'

			endfor


	endfor

	print, 'CLOSED FILE-->', fname_peos
	close,1
	

endfor			



end