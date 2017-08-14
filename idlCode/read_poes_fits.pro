FUNCTION read_poes_fits, date, time, old=old, new=new

;; read the appropriate file based on
;; the options set!!!

sfjul, date, time, jul
caldat, jul, month, day, year


if keyword_set(old) and keyword_set(new) then begin
    print, "choose only one format, either old or new!"
    return, fltarr(25,2)*0.
endif

if ~keyword_set(old) and ~keyword_set(new) then begin
    if (year lt 2014) then begin
        old=1
    endif else begin
        new=1
    endelse
endif

if keyword_set(old) then begin
    if (year gt 2014) then begin
        print, "choose 'new' format if year > 2015"
        return, fltarr(25,2)*0.
    endif else begin
        fnamePoes = "/sd-data/poes-bnds/old/poes-fit-" + strtrim(string(date),2) + ".txt"
    endelse
endif

if keyword_set(new) then begin
    if (year lt 2014) then begin
        print, "choose 'old' format if year < 2014"
        return, fltarr(25,2)*0.
    endif else begin
        fnamePoes = "/sd-data/poes-bnds/new/poes-fit-" + strtrim(string(date),2) + ".txt"
    endelse
endif

print, "reading file-->", fnamePoes

;; read data from the files and store them into arrays

nel_arr_all = 1000
poesMagnCoords = fltarr(nel_arr_all, 2)


nv=0.d
OPENR, 1, fnamePoes
WHILE not eof(1) do begin

    if keyword_set(new) then begin
        READF,1, poesMlat, poesMlon, poesDate, poesTime
    endif else begin
        READF,1, poesDate, poesTime, poesMlat, poesMlon
    endelse
    ; choose only the time we need
    if poesTime ne time then continue

    ;; Now due to a bug when creating "old" format files
    ;; some 0. Mlon is acccidentally assigned 0. MLAT value
    ;; we'll fix it here.
    if poesMlat eq 0. then continue

    ;; sometimes the fits are not good. Discard them
    if (abs(poesMlat) gt 85.) or (abs(poesMlat) lt 30.) then begin
        print, "fit results are not good! Choose another time"
        close,1
        return, fltarr(25,2)*0.
    endif


    poesMagnCoords[nv, 0] = poesMlat
    poesMagnCoords[nv, 1] = poesMlon
    
    nv=nv+1   
ENDWHILE         
close,1


poesMagnCoords = poesMagnCoords[0:nv-1,*] 

jindsChkGoodFit = where( poesMagnCoords[*,0]  gt 75. )
if n_elements(jindsChkGoodFit) ge 15 then begin
    print, "fit results are not good! Choose another time"
    return, fltarr(25,2)*0.
endif

return, poesMagnCoords

end