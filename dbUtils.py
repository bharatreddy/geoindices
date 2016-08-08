if __name__ == "__main__":
    import dbUtils
    dbo = dbUtils.DbUtils()
    dbo.create_dst_table()
    dbo.close()

class DbUtils(object):
    """
    A utilities class to create the Logbook mysql Db and corresponding tables.
    """

    def __init__(self):
        import mysql.connector
        # set up connections to the DB
        self.conn = mysql.connector.Connect(host='localhost',user='root',\
                                password='',database='geoindices')
        self.cursor = self.conn.cursor()

    def create_dst_table(self):
        import mysql.connector
        # create the StockSymbols table
        tabStr = """
                    CREATE TABLE dst(
                        date DATETIME NOT NULL,
                        dst_index INT NOT NULL,
                        PRIMARY KEY (date)
                        )
                    """
        self.cursor.execute(tabStr)
        self.conn.commit()

    def close(self):
        """
        Disconnect from DB
        """
        self.cursor.close()
        self.conn.close()