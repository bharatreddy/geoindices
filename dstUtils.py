if __name__ == "__main__":
    import dstUtils
    dsU = dstUtils.DownloadDst()
    print dsU.get_realtime_data()
    # print dsU.get_old_data( 2015, 6 )
    # print dsU.get_old_data( 2014, 1 )
    # print dsU.get_old_data( 2011, 10 )

class DownloadDst(object):
    """
    A class to download dst data from wdc kyoto webpage
    """
    def __init__(self):
        # set up urls
        self.homepage = "http://wdc.kugi.kyoto-u.ac.jp/"
        self.realTime = "dst_realtime"
        self.provisional = "dst_provisional"
        self.final = "dst_final"

    def get_old_data(self, year, month):
        import urllib
        import bs4
        import datetime
        # get data for a given month, year
        # validate year and month are int
        if not isinstance(year, int):
            print "enter a valid year (int)"
            return None
        if not isinstance(month, int):
            print "enter a valid month (int)"
            return None
        currUrl = self.create_url_old_data(year,month)
        if currUrl is not None:
            #This array is for converting Dst back into float
            #We want floats because python NaNs are floats
            dst_val = []
            #We need the date/time array at the same time too..
            date_dst_arr = []
            # Dst indices are plotted every hour...so our time delta is 1 hour
            dst_time_del = datetime.timedelta(hours = 1)
            try:
                conn = urllib.urlopen(currUrl)
                htmlSource = conn.read()
                soup = bs4.BeautifulSoup(htmlSource, 'html.parser')
                dataResObj = soup.find("pre", { "class" : "data" })
                # get the data as a list of strings after removing white space
                lines = dataResObj.text.strip().splitlines()
                for line in lines[6:]:
                    columns = line.split()
                    if len( columns ) > 0. :
                        date_dst_arr.append( datetime.datetime( \
                            year, month, int(columns[0]), 1 ) )
                        for cols in range( len( columns[1:] ) ) :
                            try:
                                inNumberFloatTest = float(columns[cols + 1])
                            except:
                                # split these cols as well and work on them!
                                try:
                                    missedCols = columns[cols + 1].split("-")[1:]
                                    if len(missedCols) >= 1:
                                        for mcols in missedCols:
                                            dst_val.append( -1*float( mcols ) )
                                            date_dst_arr.append ( date_dst_arr[-1] + dst_time_del )
                                except:
                                    print "something wrong with messed up vals!-->", columns[cols + 1]
                                    continue
                                continue
                            # I have to do this because of the messed up way Kyoto puts up the latest dst value..
                            # mixed with 9999 (fillers) like if latest dst is 1 then Kyoto puts it as 199999.....
                            if len( columns[ cols + 1 ] ) < 5 :
                                dst_val.append( float( columns[ cols + 1 ] ) )
                            elif ( len( columns[ cols + 1 ] ) > 5 and columns[ cols + 1 ][0:3] != '999' ) :
                                mixed_messed_dst = ''
                                for jj in range(5) :
                                    if columns[ cols + 1 ][jj] != '9' :
                                        mixed_messed_dst = mixed_messed_dst + columns[ cols + 1 ][jj]
                                
                                if mixed_messed_dst != '-' :
                                    dst_val.append( float( mixed_messed_dst ) )
                                else :
                                    dst_val.append( float( 'nan' ) )
                            else :
                                dst_val.append( float( 'nan' ) )
                            if cols > 0 :
                                date_dst_arr.append ( date_dst_arr[-1] + dst_time_del )
                return (dst_val,date_dst_arr)
            except:
                print "data download from url failed-->" + currUrl
                return None
        else:
            "url not working!"
            return None

    def get_realtime_data(self):
        import urllib
        import bs4
        import datetime
        currUrl = self.create_url_realtime()
        if currUrl is not None:
            #This array is for converting Dst back into float
            #We want floats because python NaNs are floats
            dst_val = []
            #We need the date/time array at the same time too..
            date_dst_arr = []
            # Dst indices are plotted every hour...so our time delta is 1 hour
            dst_time_del = datetime.timedelta(hours = 1)
            try:
                conn = urllib.urlopen(currUrl)
                htmlSource = conn.read()
                soup = bs4.BeautifulSoup(htmlSource, 'html.parser')
                dataResObj = soup.find("pre", { "class" : "data" })
                # get the data as a list of strings after removing white space
                lines = dataResObj.text.strip().splitlines()
                currDate = datetime.datetime.utcnow()
                for line in lines[6:]:
                    columns = line.split()
                    if len( columns ) > 0. :
                        date_dst_arr.append( datetime.datetime( \
                            currDate.year, currDate.month, int(columns[0]), 1 ) )
                        for cols in range( len( columns[1:] ) ) :
                            try:
                                inNumberFloatTest = float(columns[cols + 1])
                            except:
                                # split these cols as well and work on them!
                                try:
                                    missedCols = columns[cols + 1].split("-")[1:]
                                    if len(missedCols) >= 1:
                                        for mcols in missedCols:
                                            dst_val.append( -1*float( mcols ) )
                                            date_dst_arr.append ( date_dst_arr[-1] + dst_time_del )
                                except:
                                    print "something wrong with messed up vals!-->", columns[cols + 1]
                                    continue
                                continue
                            # I have to do this because of the messed up way Kyoto puts up the latest dst value..
                            # mixed with 9999 (fillers) like if latest dst is 1 then Kyoto puts it as 199999.....
                            if len( columns[ cols + 1 ] ) < 5 :
                                dst_val.append( float( columns[ cols + 1 ] ) )
                            elif ( len( columns[ cols + 1 ] ) > 5 and columns[ cols + 1 ][0:3] != '999' ) :
                                mixed_messed_dst = ''
                                for jj in range(5) :
                                    if columns[ cols + 1 ][jj] != '9' :
                                        mixed_messed_dst = mixed_messed_dst + columns[ cols + 1 ][jj]
                                
                                if mixed_messed_dst != '-' :
                                    dst_val.append( float( mixed_messed_dst ) )
                                else :
                                    dst_val.append( float( 'nan' ) )
                            else :
                                dst_val.append( float( 'nan' ) )
                            if cols > 0 :
                                date_dst_arr.append ( date_dst_arr[-1] + dst_time_del )
                return (dst_val,date_dst_arr)
            except:
                print "data download from url failed-->" + currUrl
                return None
        else:
            "url not working!"
            return None


    def create_url_realtime(self):
        # url creation for realtime dst data
        import urllib
        currUrl = self.homepage + self.realTime + "/presentmonth/index.html"
        conn = urllib.urlopen(currUrl)
        if ( conn.getcode() != 200 ):
            print "something wrong with url, check if website is running!!!"
            currUrl = None
        return currUrl

    def create_url_old_data(self,year,month):
        import urllib
        # create the url based on year and month
        # Also check if the url returns valid response
        # check the inputs
        if not isinstance(year, int):
            print "enter a valid year (int)"
            return None
        if not isinstance(month, int):
            print "enter a valid month (int)"
            return None
        if month <= 9:
            monthStr = "0" + str(month)
        else:
            monthStr = str(month)
        if year >= 2015:
            # create the url
            currUrl = self.homepage + self.realTime + \
                "/" + str(year) + monthStr + "/index.html"
            # check if it returns valid response
            conn = urllib.urlopen(currUrl)
            if ( conn.getcode() != 200 ):
                print "Something wrong-->" + currUrl, " returns->", conn.getcode()
                print "trying a different url"
                currUrl = self.homepage + self.provisional + \
                    "/" + str(year) + monthStr + "/index.html"
                if ( conn.getcode() != 200 ):
                    print "Something wrong-->" + currUrl, " returns->", conn.getcode()
                    print "trying a different url"
                    currUrl = self.homepage + self.final + \
                        "/" + str(year) + monthStr + "/index.html"
                    if ( conn.getcode() != 200 ):
                        print "something wrong with url, check if website is running!!!"
                        currUrl = None
        elif ( (year > 2011) and (year < 2015) ):
            # create the url
            currUrl = self.homepage + self.provisional + \
                "/" + str(year) + monthStr + "/index.html"
            # check if it returns valid response
            conn = urllib.urlopen(currUrl)
            if ( conn.getcode() != 200 ):
                print "Something wrong-->" + currUrl, " returns->", conn.getcode()
                print "trying a different url"
                currUrl = self.homepage + self.realTime + \
                    "/" + str(year) + monthStr + "/index.html"
                if ( conn.getcode() != 200 ):
                    print "Something wrong-->" + currUrl, " returns->", conn.getcode()
                    print "trying a different url"
                    currUrl = self.homepage + self.final + \
                        "/" + str(year) + monthStr + "/index.html"
                    if ( conn.getcode() != 200 ):
                        print "something wrong with url, check if website is running!!!"
                        currUrl = None
        else:
            # create the url
            currUrl = self.homepage + self.final + \
                "/" + str(year) + monthStr + "/index.html"
            # check if it returns valid response
            conn = urllib.urlopen(currUrl)
            if ( conn.getcode() != 200 ):
                print "Something wrong-->" + currUrl, " returns->", conn.getcode()
                print "trying a different url"
                currUrl = self.homepage + self.provisional + \
                    "/" + str(year) + monthStr + "/index.html"
                if ( conn.getcode() != 200 ):
                    print "Something wrong-->" + currUrl, " returns->", conn.getcode()
                    print "trying a different url"
                    currUrl = self.homepage + self.realTime + \
                        "/" + str(year) + monthStr + "/index.html"
                    if ( conn.getcode() != 200 ):
                        print "something wrong with url, check if website is running!!!"
                        currUrl = None
        return currUrl