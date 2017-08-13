import urllib
import bs4
import ssl
import shutil
import os
import netCDF4
import pandas
import datetime
import numpy
import math
from scipy import signal, ndimage, optimize

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
        # Roughly corresponds to 1 deg in MLAT
        self.gauss_smooth_sigma = 5. 
        self.diffElctrCutoffBnd = 0.1
        # More than an order of magnitude, remember its a log scale
        self.filtEleFluxCutoffMagn = 1.25 

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
        # get the closest 45 MLAT - 45 MLAT passes
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

    def get_nth_ele_eq_bnd_locs( self, poesDataDF, poesAllEleDataDF ):
        # given a dataframe, loop through times and
        # get the locations of auroral boundaries
        # for each of the satellites.
        aurEqBndList = []
        for currTime in poesDataDF["selTime"].unique():
            # For each unique time, get the pass times
            passTimeRange = poesDataDF[ \
                poesDataDF["selTime"] == currTime ][ [\
                "sat","start_time_nth","end_time_nth"] ].dropna()
            currPOESDF = pandas.merge( poesAllEleDataDF, passTimeRange, on="sat")
            # get data from poesSatellites
            currPOESDF = currPOESDF[ \
                         (currPOESDF["date"] >= currPOESDF["start_time_nth"]) &\
                         (currPOESDF["date"] <= currPOESDF["end_time_nth"])\
                         ].reset_index(drop=True)
            # Divide satellite data to two passes
            # we'll get boundary data from each pass
            # In the first pass, sat is moving from 
            # low to high latitudes and in the second one
            # We'll get the opposite case
            currPOESDF = currPOESDF.sort_values( ["sat","date"],\
                            ascending=[True, True] \
                            ).reset_index(drop=True)
            # We'll get the the satellite pass which is moving polewards
            # Basically percent change in latitudes should be positive
            # for a satellite moving polewards.
            currPOESDF["latRowDiffs"] = currPOESDF.groupby("sat")[[\
                            "aacgm_lat_foot" ] ].pct_change()
            currPOESDFPolewards = currPOESDF[\
                                    currPOESDF["latRowDiffs"] > 0.\
                                    ].reset_index(drop=True)
            currPOESDFEquatorwards = currPOESDF[\
                                    currPOESDF["latRowDiffs"] < 0.\
                                    ].reset_index(drop=True)
            currPOESDFPolewards["filtEleFluxPoleArr"] = ndimage.filters.gaussian_filter1d(\
                                    currPOESDFPolewards["log_ele_flux"],self.gauss_smooth_sigma) 
            currPOESDFPolewards["diffEleFluxPoleArr"] = numpy.gradient(\
                                    numpy.gradient(currPOESDFPolewards["filtEleFluxPoleArr"]))
            # Get laplacian of gaussian for Equatorward pass
            currPOESDFEquatorwards["filtEleFluxEquatorArr"] = \
                                ndimage.filters.gaussian_filter1d(\
                                currPOESDFEquatorwards["log_ele_flux"],self.gauss_smooth_sigma) #
            currPOESDFEquatorwards["diffEleFluxEquatorArr"] = \
                                numpy.gradient(numpy.gradient(\
                                    currPOESDFEquatorwards["filtEleFluxEquatorArr"]))

            # get indices of min location Poleward pass
            minLocs = currPOESDFPolewards.groupby(['sat'])\
                                ['diffEleFluxPoleArr'].transform(min) ==\
                                 currPOESDFPolewards['diffEleFluxPoleArr']
            minPolePassLoc = currPOESDFPolewards[ minLocs ]
            minPolePassLoc = minPolePassLoc[ ["sat"] ]
            minPolePassLoc = minPolePassLoc.reset_index()
            minPolePassLoc.columns = [ "min_loc_index", "sat" ]
            # get indices of max location Poleward pass
            maxLocs = currPOESDFPolewards.groupby(['sat'])\
                                ['diffEleFluxPoleArr'].transform(max) ==\
                                 currPOESDFPolewards['diffEleFluxPoleArr']
            maxPolePassLoc = currPOESDFPolewards[ maxLocs ]
            maxPolePassLoc = maxPolePassLoc[ ["sat"] ]
            maxPolePassLoc = maxPolePassLoc.reset_index()
            maxPolePassLoc.columns = [ "max_loc_index", "sat" ]
            selLocPolePass = pandas.merge( minPolePassLoc, maxPolePassLoc, on="sat" )
            selLocPolePass["nrstInd"] = selLocPolePass[ \
                            ["min_loc_index", "max_loc_index"] ].min(axis=1)
            # get indices of min location Equatorward pass
            minLocs = currPOESDFEquatorwards.groupby(['sat'])\
                                ['diffEleFluxEquatorArr'].transform(min) ==\
                                 currPOESDFEquatorwards['diffEleFluxEquatorArr']
            minEquatorPassLoc = currPOESDFEquatorwards[ minLocs ]
            minEquatorPassLoc = minEquatorPassLoc[ ["sat"] ]
            minEquatorPassLoc = minEquatorPassLoc.reset_index()
            minEquatorPassLoc.columns = [ "min_loc_index", "sat" ]
            # get indices of max location Equatorward pass
            maxLocs = currPOESDFEquatorwards.groupby(['sat'])\
                                ['diffEleFluxEquatorArr'].transform(max) ==\
                                 currPOESDFEquatorwards['diffEleFluxEquatorArr']
            maxEquatorPassLoc = currPOESDFEquatorwards[ maxLocs ]
            maxEquatorPassLoc = maxEquatorPassLoc[ ["sat"] ]
            maxEquatorPassLoc = maxEquatorPassLoc.reset_index()
            maxEquatorPassLoc.columns = [ "max_loc_index", "sat" ]
            selLocEquatorPass = pandas.merge( minEquatorPassLoc, maxEquatorPassLoc, on="sat" )
            selLocEquatorPass["nrstInd"] = selLocEquatorPass[ \
                            ["min_loc_index", "max_loc_index"] ].max(axis=1)
            # Now get the actual locations
            polePassEqBndDF = currPOESDFPolewards.ix[selLocPolePass["nrstInd"]]\
                                    [ ["diffEleFluxPoleArr", "aacgm_lat_foot", "sat"] ].reset_index()
            equatorPassEqBndDF = currPOESDFEquatorwards.ix[selLocEquatorPass["nrstInd"]]\
                                    [ ["diffEleFluxEquatorArr", "aacgm_lat_foot", "sat"] ].reset_index()
            polePassEqBndDF.columns = [ "ind_sel", "diffEleFlux_chosen", "lat_chosen", "sat" ]
            equatorPassEqBndDF.columns = [ "ind_sel", "diffEleFlux_chosen", "lat_chosen", "sat" ]
            # Poleward
            polePassEqBndDF = pandas.merge( currPOESDFPolewards,\
                                 polePassEqBndDF, on="sat" )
            equatorPassEqBndDF = pandas.merge( currPOESDFEquatorwards,\
                                 equatorPassEqBndDF, on="sat" )
            # get max ele flux values
            maxFiltEleFluxPole = polePassEqBndDF.groupby("sat")["filtEleFluxPoleArr"].max().reset_index()
            maxFiltEleFluxPole.columns = [ "sat", "filtEleFluxPoleArr_max" ]
            maxFiltEleFluxEquator = equatorPassEqBndDF.groupby("sat")["filtEleFluxEquatorArr"].max().reset_index()
            maxFiltEleFluxEquator.columns = [ "sat", "filtEleFluxEquatorArr_max" ]

            # Setup filters to identify boundaries
            polePassEqBndDF = pandas.merge( polePassEqBndDF,\
                                     maxFiltEleFluxPole, on="sat" )
            equatorPassEqBndDF = pandas.merge( equatorPassEqBndDF,\
                                     maxFiltEleFluxEquator, on="sat" )

            polePassEqBndDF = polePassEqBndDF[  \
                        abs( polePassEqBndDF["diffEleFluxPoleArr"] ) <= \
                        abs(polePassEqBndDF["diffEleFlux_chosen"]*self.diffElctrCutoffBnd) ]

            polePassEqBndDF = polePassEqBndDF[ \
                                ( abs(polePassEqBndDF["aacgm_lat_foot"]) < \
                                abs(polePassEqBndDF["lat_chosen"]) ) &\
                                 (polePassEqBndDF["filtEleFluxPoleArr_max"] -\
                                 polePassEqBndDF["filtEleFluxPoleArr"] > self.filtEleFluxCutoffMagn) ]
            maxFiltLatPole = polePassEqBndDF.groupby("sat")["aacgm_lat_foot"].max().reset_index()
            maxFiltLatPole.columns = [ "sat", "max_lat" ]
            polePassEqBndDF = pandas.merge( polePassEqBndDF, maxFiltLatPole, on="sat" )
            polePassEqBndDF = polePassEqBndDF[ polePassEqBndDF["aacgm_lat_foot"] ==\
                                              polePassEqBndDF["max_lat"] ]
            # Equatorward
            equatorPassEqBndDF = equatorPassEqBndDF[  \
                        abs( equatorPassEqBndDF["diffEleFluxEquatorArr"] ) <= \
                        abs(equatorPassEqBndDF["diffEleFlux_chosen"]*self.diffElctrCutoffBnd) ]
            equatorPassEqBndDF = equatorPassEqBndDF[ \
                                ( abs(equatorPassEqBndDF["aacgm_lat_foot"]) < \
                                abs(equatorPassEqBndDF["lat_chosen"]) ) &\
                                 (equatorPassEqBndDF["filtEleFluxEquatorArr_max"] -\
                                 equatorPassEqBndDF["filtEleFluxEquatorArr"] > self.filtEleFluxCutoffMagn) ]
            maxLatEquator = equatorPassEqBndDF.groupby("sat")["aacgm_lat_foot"].max().reset_index()
            maxLatEquator.columns = [ "sat", "max_lat" ]
            equatorPassEqBndDF = pandas.merge( equatorPassEqBndDF, maxLatEquator, on="sat" )
            equatorPassEqBndDF = equatorPassEqBndDF[ equatorPassEqBndDF["aacgm_lat_foot"] ==\
                                              equatorPassEqBndDF["max_lat"] ]
            # We only need a few columns
            polePassEqBndDF = polePassEqBndDF[ ["sat", "aacgm_lat_foot",\
                                 "aacgm_lon_foot", "MLT"] ]
            polePassEqBndDF.columns = [ "sat", "pole_mlat",\
                                         "pole_mlon", "pole_mlt"  ]
            equatorPassEqBndDF = equatorPassEqBndDF[ ["sat", "aacgm_lat_foot",\
                                 "aacgm_lon_foot", "MLT"] ]
            equatorPassEqBndDF.columns = [ "sat", "equator_mlat",\
                                        "equator_mlon", "equator_mlt"  ]
            currAurEqBndDF = pandas.merge( polePassEqBndDF, equatorPassEqBndDF,\
                             on="sat", how="outer" )
            currAurEqBndDF["time"] = currTime
            aurEqBndList.append( currAurEqBndDF )
        aurEqBndDF = pandas.concat( aurEqBndList )
        return aurEqBndDF

    def fit_circle_aurbnd( self, bndLocDF ):
        # Given the boundary locations obtained
        # from different satellites, estimate the
        # auroral oval boundary by fitting a circle!
        for currTime in bndLocDF["time"].unique():
            currBndDF = bndLocDF[ bndLocDF["time"] == currTime ]
            # Convert to numpy arrays 
            poleMlatArr = currBndDF["pole_mlat"].values
            poleMlonArr = currBndDF["pole_mlon"].values
            poleMltArr = currBndDF["pole_mlt"].values
            equMlatArr = currBndDF["equator_mlat"].values
            equMlonArr = currBndDF["equator_mlon"].values
            equMltArr = currBndDF["equator_mlt"].values
            # discard nan values
            poleMlatArr = poleMlatArr[~numpy.isnan(poleMlatArr)]
            poleMlonArr = poleMlonArr[~numpy.isnan(poleMlatArr)]
            poleMltArr = poleMltArr[~numpy.isnan(poleMlatArr)]
            equMlatArr = equMlatArr[~numpy.isnan(equMlatArr)]
            equMlonArr = equMlonArr[~numpy.isnan(equMlatArr)]
            equMltArr = equMltArr[~numpy.isnan(equMlatArr)]
            # Concat the arrays together
            latPoesAll = numpy.append( poleMlatArr, equMlatArr )
            lonPoesAll = numpy.append( poleMlonArr, equMlonArr )
            # Now we do the fitting part...
            # Target function
            fitfunc = lambda p, x: p[0] + \
                        p[1]*numpy.cos(\
                        2*math.pi*(x/360.)+p[2]) 
            # Distance to the target function
            errfunc = lambda p, x,\
                         y: fitfunc(p, x) - y 
            # get the fitting results
            # Initial guess
            p0Equ = [ 1., 1., 1.]
            p1Equ, successEqu = optimize.leastsq(errfunc,\
                         p0Equ[:], args=(lonPoesAll, latPoesAll))
            eqPlotLons = numpy.linspace(0., 360., 25.)
            eqPlotLons[-1] = 0.
            eqBndLocs = []
            for xx in eqPlotLons :
                currLatEst = p1Equ[0] +\
                        p1Equ[1]*numpy.cos(2*math.pi*(xx/360.)+p1Equ[2] )
                eqBndLocs.append( ( round(currLatEst,1), xx ) )
            # Convert to DF
            aurFitDF = pandas.DataFrame( eqBndLocs, \
                        columns=["MLAT", "MLON"] )
            cnvrtTime = pandas.to_datetime(str(currTime)) 
            aurFitDF["date"] = cnvrtTime.strftime( "%Y%m%d" )
            aurFitDF["time"] = cnvrtTime.strftime( "%H%M" )
            outFitResFil = "../poes-fit-" +\
                    cnvrtTime.strftime( "%Y%m%d" ) + ".txt"
            if cnvrtTime.strftime( "%H%M" ) == "0000":
                with open(outFitResFil, 'w') as fra:
                    aurFitDF.to_csv(fra, header=False,\
                                      index=False, sep=' ' )
            else:
                with open(outFitResFil, 'a') as fra:
                    aurFitDF.to_csv(fra, header=False,\
                                      index=False, sep=' ' )