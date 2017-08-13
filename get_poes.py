if __name__ == "__main__":
    import datetime
    import poesUtils
    import os
    sTimePOES = datetime.datetime( 2014,1,1 )
    eTimePOES = datetime.datetime( 2015,12,31 )
    dayCount = (eTimePOES - sTimePOES).days + 1
    for inpDate in (sTimePOES + \
            datetime.timedelta(n) for n in range(dayCount)):
        print "currently working with---->", inpDate
        poesObj = poesUtils.PoesData(inpDate)
        # change outDir bro! to shift them to a different loc
        poesFiles = poesObj.get_all_sat_data(outDir="/home/bharat/Documents/data/poes-new-fits-raw/")
        # poesFiles = [ "./poes_n15_20130302_proc.nc",\
        #             "./poes_n18_20130302_proc.nc",\
        #             "./poes_m01_20130302_proc.nc",\
        #             "./poes_n19_20130302_proc.nc",\
        #             "./poes_m02_20130302_proc.nc",\
        #             "./poes_n16_20130302_proc.nc",\
        #             "./poes_n17_20130302_proc.nc" ]
        poesAllEleDataDF, poesAllProDataDF = poesObj.read_poes_data_files( poesFiles )
        if poesAllEleDataDF is None:
            continue
        timeRange = [ poesAllEleDataDF["date"].min(), poesAllEleDataDF["date"].max() ]
        aurPassDF = poesObj.get_closest_sat_passes( poesAllEleDataDF, poesAllProDataDF, timeRange )
        if aurPassDF is None:
            continue
        eqBndLocsDF = poesObj.get_nth_ele_eq_bnd_locs( aurPassDF, poesAllEleDataDF )
        if eqBndLocsDF is None:
            continue
        poesObj.fit_circle_aurbnd( eqBndLocsDF,outDir="/home/bharat/Documents/data/poes-new-fits/" )
        # remove the POES files
        for pFile in poesFiles:
            os.remove(pFile)