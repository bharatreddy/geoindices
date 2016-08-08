if __name__ == "__main__":
    import dbUtils
    dbo = dbUtils.DbUtils()
    dbo.fill_dst_tab(None)
    dbo.close()

class DbUtils(object):
    """
    A utilities class to insert/update data into tables.
    """

    def __init__(self):
        import mysql.connector
        # set up connections to the DB
        self.conn = mysql.connector.Connect(host='localhost',user='root',\
                                password='',database='geoindices')
        self.cursor = self.conn.cursor()

    def fill_dst_tab(self, dstTuple):
        import datetime
        import math
        # insert dst_index values into the dst table
        # loop through the dst tuple and fill the values in database.
        for currDst,currDate in zip(dstTuple[0],dstTuple[1]):
            if not isinstance(currDst,float):
                print "dst value shoule be float type-->", currDst
                continue
            if not isinstance(currDate,datetime.datetime):
                print "date value shoule be datetime type-->", currDate
                continue
            if math.isnan(currDst):
                print "nan values, skipping!"
                continue
            try:
                query = ("INSERT INTO dst "
                       " (date, dst_index) "
                       " VALUES (%s, %s) "
                       " ON DUPLICATE KEY UPDATE "
                       "   date=VALUES(date), "
                       "   dst_index=VALUES(dst_index) "
                       )
                params = (
                    currDate,
                    currDst)
                self.cursor.execute(query, params)
            except:
                print "--INSERT FAILED-->", date, dst_index
        self.conn.commit()

    def close(self):
        """
        Disconnect from DB
        """
        self.cursor.close()
        self.conn.close()