import urllib
import bs4
# Use beautiful soup to retreive dst data
currUrl = \
'http://wdc.kugi.kyoto-u.ac.jp/dst_realtime/presentmonth/index.html'
conn = urllib.urlopen(currUrl)
htmlSource = conn.read()
soup = bs4.BeautifulSoup(htmlSource, 'html.parser')
dataResObj = soup.find("pre", { "class" : "data" })
# get the data as a list of strings after removing white space
textList = dataResObj.text.strip().splitlines()
print textList