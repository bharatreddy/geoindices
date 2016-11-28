if __name__ == "__main__":
    import datetime
    import poesUtils
    inpDate = datetime.date(2016,1,2)
    poesObj = poesUtils.PoesData(inpDate)
    poesFiles = poesObj.get_all_sat_data(outDir="/Users/bharat/Desktop/poesTest")
    print poesFiles

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
        import urllib
        import bs4
        # get a list of satellites avaiable for the date
        yearUrl = self.homepage + str( self.inpDate.year )
        try:
            conn = urllib.urlopen(yearUrl)
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
        import urllib
        import bs4
        import shutil
        import os
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
        import urllib
        urllib.urlretrieve(url + fileName, fileName)