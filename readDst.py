if __name__ == "__main__":
    import readDst
    rdDst = readDst.ReadDstData()
    rdDst.read_for_dst_calendar()

class ReadDstData(object):
    """
    A class to read dst data from the mysql DB
    """
    def __init__(self):
        import mysql.connector
        # set up db conns
        self.conn = mysql.connector.Connect(host='localhost',user='root',\
                        password='',database='geoindices')

    def read_for_dst_calendar(self):
        import pandas
        qryDst = "SELECT * FROM dst"
        dstDF = pandas.read_sql( qryDst, self.conn )
        # add year, month and day columns
        dstDF['year'] = dstDF['date'].map(lambda x: x.year)
        dstDF['month'] = dstDF['date'].map(lambda x: x.month)
        dstDF['day'] = dstDF['date'].map(lambda x: x.day)
        # get min dst in each day, this will be used for creating
        # the dst calendar
        dstGrp = dstDF.groupby( ['year', 'month', 'day'] )
        minDst = dstGrp.min()
        minDst.reset_index(level=['year', 'month','day'],inplace=True)
        resDF = pandas.merge( minDst, dstDF,\
                                 on=['dst_index','year','month','day'], how='inner' )
        resDF.drop('date_x', axis=1, inplace=True)
        resDF.rename(columns={'date_y': 'date'}, inplace=True)
        resDF.drop_duplicates(['year', 'month','day'],inplace=True)
        resDF.reset_index(drop=True, inplace=True)
        return resDF