if __name__ == "__main__":
    import datetime
    import poesUtils
    inpDate = datetime.date(2013,3,2)
    poesObj = poesUtils.PoesData(inpDate)
    # poesFiles = poesObj.get_all_sat_data(outDir=".")
    poesFiles = [ "./poes_n15_20130302_proc.nc",\
                "./poes_n18_20130302_proc.nc",\
                "./poes_m01_20130302_proc.nc",\
                "./poes_n19_20130302_proc.nc",\
                "./poes_m02_20130302_proc.nc",\
                "./poes_n16_20130302_proc.nc",\
                "./poes_n17_20130302_proc.nc" ]
    poesAllEleDataDF, poesAllProDataDF = poesObj.read_poes_data_files( poesFiles )
    # print type(poesAllEleDataDF["date"].min())
    timeRange = [ poesAllEleDataDF["date"].min(), poesAllEleDataDF["date"].max() ]
    aurPassDF = poesObj.get_closest_sat_passes( poesAllEleDataDF, poesAllProDataDF, timeRange )