if __name__ == "__main__":
    import datetime
    import poesUtils
    inpDate = datetime.date(2013,3,2)
    poesObj = poesUtils.PoesData(inpDate)
    # poesFiles = poesObj.get_all_sat_data(outDir="/Users/bharat/Desktop/poesTest/pdata")
    poesFiles = [ "/Users/bharat/Desktop/poesTest/pdata/poes_n15_20130302_proc.nc",\
                "/Users/bharat/Desktop/poesTest/pdata/poes_n18_20130302_proc.nc",\
                "/Users/bharat/Desktop/poesTest/pdata/poes_m01_20130302_proc.nc",\
                "/Users/bharat/Desktop/poesTest/pdata/poes_n19_20130302_proc.nc",\
                "/Users/bharat/Desktop/poesTest/pdata/poes_m01_20130302_proc.nc",\
                "/Users/bharat/Desktop/poesTest/pdata/poes_n16_20130302_proc.nc",\
                "/Users/bharat/Desktop/poesTest/pdata/poes_n17_20130302_proc.nc" ]
    poesAllEleDataDF, poesAllProDataDF = poesObj.read_poes_data_files( poesFiles )
    # print type(poesAllEleDataDF["date"].min())
    timeRange = [ poesAllEleDataDF["date"].min(), poesAllEleDataDF["date"].max() ]
    aurBndDF = poesObj.get_aur_bnd_locs( poesAllEleDataDF, poesAllProDataDF, timeRange )