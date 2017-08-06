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
            print "reading file-->", f
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

    def get_aur_bnd_locs( self, poesAllEleDataDF, poesAllProDataDF, timeRange,\
         timeInterval=datetime.timedelta(minutes=30) ):
        # given a timeRange, timestep
        # get the locations of auroral boundaries
        # for each of the satellites.
        ctime = timeRange[0]
        while ctime <= timeRange[1]:
            ctime += timeInterval
        # We'll calculate both electron and ion precipitation boundaries
        # Electron Precipitaion boundary
        poesAllEleDataDF["delCtime"] = abs(poesAllEleDataDF["date"] - ctime)
        print poesAllEleDataDF[ ( abs(poesAllEleDataDF["aacgm_lat_foot"]) > 45. ) &\
                     ( abs(poesAllEleDataDF["delCtime"]) == poesAllEleDataDF["delCtime"].min() ) ]



