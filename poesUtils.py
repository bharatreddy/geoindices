import urllib
import bs4
import ssl
import shutil
import os
import netCDF4
import pandas
import datetime
import numpy

class PoesData(object):
    """
    A class to download poes data from noaa website.
    Also has functions to process the data!
    """
    def __init__(self, inpDate):
        # set up urls and dates
        self.homepage = "http://satdat.ngdc.noaa.gov/" +\
             "sem/poes/data/processed/ngdc/uncorrected/full/"
        self.inpDate = inpDate
        self.minCutoffFitLat = 45.
        self.delTimeCutOffNrstPass = 50 # min
        self.mlonDiffOtrEndCutoff = 50.
        self.delLatCutoff = 2.
        self.delCtimeCutoff = 60. #min

    def get_all_sat_urls(self, dataFolder="./"):
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        # get a list of satellites avaiable for the date
        yearUrl = self.homepage + str( self.inpDate.year )
        try:
            conn = urllib.urlopen(yearUrl, context=ctx)
            htmlSource = conn.read()
            soup = bs4.BeautifulSoup(htmlSource, 'html.parser')
            # Get all the urls
            urlDict = {}
            for a in soup.find_all('a', href=True):
                if ( "metop" in a.contents[0] or "noaa" in a.contents[0] ):
                    urlDict[str(a['href'])] = yearUrl + "/" + a['href']
        except:
            print "data download from url failed-->" + yearUrl
            return None
        return urlDict

    def get_all_sat_data(self,outDir="./"):
        # generate urls to download POES satellite data from 
        # all files for a given date
        urlDict = self.get_all_sat_urls()
        if urlDict is None:
            print "url retreival failed!"
            return None
        if len(urlDict.keys()) == 0.:
            print "no urls/sats found!"
            return None
        try:
            # Get data from all the urls
            fileList = []
            for currSat in urlDict.keys():
                currFileName = "poes_" + currSat[0] + currSat[-3:-1] + "_"+\
                    self.inpDate.strftime("%Y%m%d") + "_proc.nc"
                print "downloading file from url-->" + \
                    urlDict[currSat] + currFileName
                self.get_file_from_url(urlDict[currSat], currFileName)
                # List of files to return
                fileList.append( outDir + "/" + currFileName )
                # Move the files to destination folder
                if outDir != "./":
                    # check if file exists and then transfer!
                    if os.path.isfile(outDir + "/" + currFileName):
                        print "file exists! check again..."
                    else:
                        print "moving file to destination folder", currFileName
                        shutil.move("./" + currFileName, outDir)
            return fileList
        except:
            print "download failed!!"
            return None

    def get_file_from_url(self, url, fileName):
        # Download a given poes file
        urllib.urlretrieve(url + fileName, fileName)

    def read_poes_data_files(self, fileList):
        # read data from given POES files
        # Note these should be local files
        # and I expect a list for input
        if not isinstance(fileList, list):
            print "input fileList should be a list type"
            return None
        if len(fileList) == 0:
            print "fileList input is empty"
            return None
        # We'll store all the data into two dataframes
        # one for electron flux and the other for protons
        poesAllEleDataDF = pandas.DataFrame( columns =  ["timestamp", "date", "aacgm_lat_foot",\
                         "aacgm_lon_foot", "MLT", "log_ele_flux", "sat"] )
        poesAllProDataDF = pandas.DataFrame( columns =  ["timestamp", "date", "aacgm_lat_foot",\
                                 "aacgm_lon_foot", "MLT", "log_pro_flux", "sat"] )
        for f in fileList:
            # print "reading file-->", f
            # read variable from the netCDF files
            poesRawData = netCDF4.Dataset(f)
            poesDF = pandas.DataFrame( poesRawData.variables['time'][:], columns=[ "timestamp" ] )
            poesDF['date'] = pandas.to_datetime(poesDF['timestamp'], unit='ms')
            poesDF["alt"] = poesRawData.variables['alt'][:]
            poesDF["aacgm_lat_foot"] = poesRawData.variables['aacgm_lat_foot'][:]

            poesDF["aacgm_lon_foot"] = poesRawData.variables['aacgm_lon_foot'][:]
            poesDF["MLT"] = poesRawData.variables['MLT'][:]
            # round of to 2 decimals
            poesDF['alt'] = [ round( x, 2 ) for x in poesDF['alt']]
            poesDF['aacgm_lat_foot'] = [ round( x, 2 ) for x in poesDF['aacgm_lat_foot']]
            poesDF['aacgm_lon_foot'] = [ round( x, 2 ) for x in poesDF['aacgm_lon_foot']]
            poesDF['MLT'] = [ round( x, 2 ) for x in poesDF['MLT']]
            # Add up the fluxes
            poesDF["ted_ele_total_flux"] = poesRawData.variables['ted_ele_tel0_flux_4'][:] +\
                    poesRawData.variables['ted_ele_tel0_flux_8'][:] + \
                    poesRawData.variables['ted_ele_tel0_flux_11'][:] + \
                    poesRawData.variables['ted_ele_tel0_flux_14'][:] + \
                    poesRawData.variables['ted_ele_tel30_flux_4'][:] +\
                    poesRawData.variables['ted_ele_tel30_flux_8'][:] + \
                    poesRawData.variables['ted_ele_tel30_flux_11'][:] + \
                    poesRawData.variables['ted_ele_tel30_flux_14'][:]
            poesDF["ted_pro_total_flux"] = poesRawData.variables['ted_pro_tel0_flux_4'][:] +\
                    poesRawData.variables['ted_pro_tel0_flux_8'][:] + \
                    poesRawData.variables['ted_pro_tel0_flux_11'][:] + \
                    poesRawData.variables['ted_pro_tel0_flux_14'][:] + \
                    poesRawData.variables['ted_pro_tel30_flux_4'][:] +\
                    poesRawData.variables['ted_pro_tel30_flux_8'][:] + \
                    poesRawData.variables['ted_pro_tel30_flux_11'][:] + \
                    poesRawData.variables['ted_pro_tel30_flux_14'][:]
            poesDF['log_ele_flux'] = [0. if x <= 0. else round( numpy.log10(x), 2 )\
                         for x in poesDF['ted_ele_total_flux']]
            poesDF['log_pro_flux'] = [0. if x <= 0. else round( numpy.log10(x), 2 )\
                         for x in poesDF['ted_pro_total_flux']]
            # the current satellite number
            poesDF["sat"] = f[-19:-17]
            # seperate out electron and proton flux and discard all zeros
            currPoesEleFluxDF = poesDF[poesDF["log_ele_flux"] > 0.][ ["timestamp",\
                             "date", "aacgm_lat_foot", "aacgm_lon_foot", "MLT",\
                             "log_ele_flux", "sat"] ].reset_index(drop=True)
            currPoesProFluxDF = poesDF[poesDF["log_pro_flux"] > 0.][ ["timestamp",\
                             "date", "aacgm_lat_foot", "aacgm_lon_foot", "MLT",\
                             "log_pro_flux", "sat"] ].reset_index(drop=True)
            poesAllEleDataDF = poesAllEleDataDF.append( currPoesEleFluxDF )
            poesAllProDataDF = poesAllProDataDF.append( currPoesProFluxDF )
            # now delete all the rows for prev DFs
            # we don't want to duplicate data
            poesDF = poesDF.drop( poesDF.index )
            currPoesEleFluxDF = currPoesEleFluxDF.drop( currPoesEleFluxDF.index )
            currPoesProFluxDF = currPoesProFluxDF.drop( currPoesProFluxDF.index )
        # create a date and time columns
        poesAllEleDataDF["dateStr"] = poesAllEleDataDF["date"].map(lambda x: x.strftime('%Y%m%d'))
        poesAllEleDataDF["time"] = poesAllEleDataDF["date"].map(lambda x: x.strftime('%H%M'))
        poesAllProDataDF["dateStr"] = poesAllProDataDF["date"].map(lambda x: x.strftime('%Y%m%d'))
        poesAllProDataDF["time"] = poesAllProDataDF["date"].map(lambda x: x.strftime('%H%M'))
        return ( poesAllEleDataDF, poesAllProDataDF )

    def get_closest_sat_passes( self, poesAllEleDataDF, poesAllProDataDF, timeRange,\
         timeInterval=datetime.timedelta(minutes=30) ):
        # given a timeRange, timestep
        # get the locations of auroral boundaries
        # for each of the satellites.
        outDFList = []
        ctime = timeRange[0]
        while ctime <= timeRange[1]:
            ctime += timeInterval
            # We only need those times when POES was above self.minCutoffFitLat(45) MLAT
            poesAllEleDataDF = poesAllEleDataDF[ \
                            ( abs( poesAllEleDataDF["aacgm_lat_foot"] ) >= self.minCutoffFitLat )\
                            ].reset_index(drop=True)
            # We only need a few columns, discard the rest
            poesAllEleDataDF = poesAllEleDataDF[ [ 'sat', 'date',\
                                    'aacgm_lat_foot', 'aacgm_lon_foot',\
                                        'MLT', 'log_ele_flux' ] ]
            poesAllEleDataDF["delCtime"] = abs(poesAllEleDataDF["date"] - ctime)
            poesAllEleDataDF["delLatFit"] = abs( abs( poesAllEleDataDF["aacgm_lat_foot"] ) -\
                                                abs( self.minCutoffFitLat ) )
            # We are sorting by sats, dates and lats to pick the nearest time
            # when the satellite is between two 45 MLATs
            poesAllEleDataDFNth = poesAllEleDataDF[ poesAllEleDataDF["aacgm_lat_foot"]\
                                    >= 0. ].sort_values( ['sat', 'date', 'aacgm_lat_foot'],\
                                            ascending=True ).reset_index(drop=True).drop_duplicates()
            poesAllEleDataDFSth = poesAllEleDataDF[ poesAllEleDataDF["aacgm_lat_foot"]\
                                    < 0. ].sort_values( ['sat', 'date', 'aacgm_lat_foot'],\
                                            ascending=True ).reset_index(drop=True).drop_duplicates()
            # Now we need to pick the satellite path
            # which is closest to the selected time.!
            # Northern Hemisphere
            poesAllEleDataDFNthST = poesAllEleDataDFNth[ \
                                        (poesAllEleDataDFNth["date"] \
                                            >= ctime-datetime.timedelta(\
                                            minutes=self.delTimeCutOffNrstPass)) &\
                                            (poesAllEleDataDFNth["date"] <=\
                                             ctime+datetime.timedelta(\
                                            minutes=self.delTimeCutOffNrstPass))].reset_index(drop=True)
            poesAllEleDataDFNthST = poesAllEleDataDFNthST.sort_values(\
                                        ["sat","date"], ascending=[True, True]\
                                        ).reset_index(drop=True)
            # We'll get the the satellite pass which is moving polewards
            # Basically percent change in latitudes should be positive
            # for a satellite moving polewards (percent change would help
            # with the southern hemisphere lcoations.)
            poesAllEleDataDFNthST["latRowDiffs"] = poesAllEleDataDFNthST.groupby("sat")[[\
                            "aacgm_lat_foot" ] ].pct_change()
            poesAllEleDataDFNthST = poesAllEleDataDFNthST[\
                                    poesAllEleDataDFNthST["latRowDiffs"] > 0.\
                                    ].reset_index(drop=True)
            poesAllEleDataDFNthST = poesAllEleDataDFNthST.sort_values(\
                                        ["sat", "aacgm_lat_foot","delCtime"]\
                                        ).reset_index(drop=True)
            # get the start time
            selTimeRangeNthDF = poesAllEleDataDFNthST.groupby("sat").first().reset_index()
            # Now if the time difference is too large, discard the satellite data
            selTimeRangeNthDF = selTimeRangeNthDF[ selTimeRangeNthDF["delCtime"] <= \
                                datetime.timedelta(minutes=self.delTimeCutOffNrstPass)\
                                ].reset_index()
            selTimeRangeNthDF = selTimeRangeNthDF[ ["sat", "date"] ]
            selTimeRangeNthDF.columns = [ "sat", "start_time" ] 

            # Now get the end times, simply get all times that are
            # greater than start time, sort them by date and get
            # lowest deLatFit
            poesAllEleDataDFNthET = pandas.merge( poesAllEleDataDFNth,\
                                        selTimeRangeNthDF, on="sat" )
            poesAllEleDataDFNthET = poesAllEleDataDFNthET[ (\
                                            poesAllEleDataDFNthET["date"] >=\
                                            poesAllEleDataDFNthET["start_time"] ) &\
                                            (poesAllEleDataDFNthET["date"] <=\
                                            poesAllEleDataDFNthET["start_time"]+datetime.timedelta(\
                                            minutes=self.delTimeCutOffNrstPass)) ].reset_index(drop=True)
            poesAllEleDataDFNthET = poesAllEleDataDFNthET.sort_values(\
                                        ["sat","date"], ascending=[True, True]\
                                        ).reset_index(drop=True)
            # We'll get the the satellite pass which is moving equatorwards
            # Basically percent change in latitudes should be negative
            # for a satellite moving polewards (percent change would help
            # with the southern hemisphere lcoations.)
            poesAllEleDataDFNthET["latRowDiffs"] = poesAllEleDataDFNthET.groupby("sat")[[\
                            "aacgm_lat_foot" ] ].pct_change()
            poesAllEleDataDFNthET = poesAllEleDataDFNthET[\
                                    poesAllEleDataDFNthET["latRowDiffs"] < 0.\
                                    ].reset_index(drop=True)
            poesAllEleDataDFNthET = poesAllEleDataDFNthET.sort_values(\
                                        ["sat", "aacgm_lat_foot","delCtime"]\
                                        ).reset_index(drop=True)
            # get the start time
            eTimeNthDF = poesAllEleDataDFNthET.groupby("sat").first().reset_index()
            eTimeNthDF = eTimeNthDF[ ["sat", "date"] ]
            eTimeNthDF.columns = [ "sat", "end_time" ] 
            selTimeRangeNthDF = pandas.merge( selTimeRangeNthDF, eTimeNthDF, on="sat" )
            selTimeRangeNthDF["selTime"] = ctime
            # Now we need to pick the satellite path
            # which is closest to the selected time.!
            # Northern Hemisphere
            poesAllEleDataDFSthST = poesAllEleDataDFSth[ \
                                        (poesAllEleDataDFSth["date"] \
                                            >= ctime-datetime.timedelta(\
                                            minutes=self.delTimeCutOffNrstPass)) &\
                                            (poesAllEleDataDFSth["date"] <=\
                                             ctime+datetime.timedelta(\
                                            minutes=self.delTimeCutOffNrstPass))].reset_index(drop=True)
            poesAllEleDataDFSthST = poesAllEleDataDFSthST.sort_values(\
                                        ["sat","date"], ascending=[True, True]\
                                        ).reset_index(drop=True)
            # We'll get the the satellite pass which is moving polewards
            # Basically percent change in latitudes should be positive
            # for a satellite moving polewards (percent change would help
            # with the southern hemisphere lcoations.)
            poesAllEleDataDFSthST["latRowDiffs"] = poesAllEleDataDFSthST.groupby("sat")[[\
                            "aacgm_lat_foot" ] ].pct_change()
            poesAllEleDataDFSthST = poesAllEleDataDFSthST[\
                                    poesAllEleDataDFSthST["latRowDiffs"] > 0.\
                                    ].reset_index(drop=True)
            poesAllEleDataDFSthST = poesAllEleDataDFSthST.sort_values(\
                                        ["sat", "aacgm_lat_foot","delCtime"],\
                                        ascending=[True, False, True]\
                                        ).reset_index(drop=True)
            # # get the start time
            selTimeRangeSthDF = poesAllEleDataDFSthST.groupby("sat").first().reset_index()
            # Now if the time difference is too large, discard the satellite data
            selTimeRangeSthDF = selTimeRangeSthDF[ selTimeRangeSthDF["delCtime"] <= \
                                datetime.timedelta(minutes=self.delTimeCutOffNrstPass)\
                                ].reset_index()
            selTimeRangeSthDF = selTimeRangeSthDF[ ["sat", "date"] ]
            selTimeRangeSthDF.columns = [ "sat", "start_time" ] 


            # # Now get the end times, simply get all times that are
            # # greater than start time, sort them by date and get
            # # lowest deLatFit
            poesAllEleDataDFSthET = pandas.merge( poesAllEleDataDFSth,\
                                        selTimeRangeSthDF, on="sat" )
            poesAllEleDataDFSthET = poesAllEleDataDFSthET[ (\
                                            poesAllEleDataDFSthET["date"] >=\
                                            poesAllEleDataDFSthET["start_time"] ) &\
                                            (poesAllEleDataDFSthET["date"] <=\
                                            poesAllEleDataDFSthET["start_time"]+datetime.timedelta(\
                                            minutes=self.delTimeCutOffNrstPass)) ].reset_index(drop=True)
            poesAllEleDataDFSthET = poesAllEleDataDFSthET.sort_values(\
                                        ["sat","date"], ascending=[True, True]\
                                        ).reset_index(drop=True)
            # We'll get the the satellite pass which is moving equatorwards
            # Basically percent change in latitudes should be negative
            # for a satellite moving polewards (percent change would help
            # with the southern hemisphere lcoations.)
            poesAllEleDataDFSthET["latRowDiffs"] = poesAllEleDataDFSthET.groupby("sat")[[\
                            "aacgm_lat_foot" ] ].pct_change()
            poesAllEleDataDFSthET = poesAllEleDataDFSthET[\
                                    poesAllEleDataDFSthET["latRowDiffs"] < 0.\
                                    ].reset_index(drop=True)
            poesAllEleDataDFSthET = poesAllEleDataDFSthET.sort_values(\
                                        ["sat", "aacgm_lat_foot","delCtime"],\
                                        ascending=[True, False, True]\
                                        ).reset_index(drop=True)
            # get the start time
            eTimeSthDF = poesAllEleDataDFSthET.groupby("sat").first().reset_index()
            eTimeSthDF = eTimeSthDF[ ["sat", "date"] ]
            eTimeSthDF.columns = [ "sat", "end_time" ] 
            selTimeRangeSthDF = pandas.merge( selTimeRangeSthDF, eTimeSthDF, on="sat" )
            selTimeRangeSthDF["selTime"] = ctime
            # Merge the two time range DFs to one
            currselTimeRangeDF = pandas.merge( selTimeRangeNthDF, selTimeRangeSthDF,\
                             on=["sat", "selTime"], how="outer", suffixes=( '_nth', '_sth' ) )
            outDFList.append( currselTimeRangeDF )
        # Concat all the DFs for differnt time ranges
        selTimeRangeDF = pandas.concat( outDFList )
        return selTimeRangeDF