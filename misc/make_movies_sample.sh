# The shell script takes the filename without extension as input
# so for example, if the filename is sample.ps, then we can
# use the command "sh make_movies_sample sample" to run the shell script
# and the output would be sample.gif
echo "working with-->"$1.ps
# create a pdf from the ps file - easier to format a pdf and convert to pngs
gs -sDEVICE=pdfwrite -sOutputFile=$1.pdf -dUseArtBox -dNOPAUSE -dEPSCrop -c "<</Orientation 2>> setpagedevice" -f $1.ps -c quit
# crop the pdf
pdfcrop $1.pdf
mv $1-crop.pdf $1.pdf
# convert each page of the pdf into seperate pngs
# these will be used to create the movie
pdftocairo -png $1.pdf
# Covner the pngs into a animated gif
convert -delay 100 frames -loop 0 $1-*.png $1.gif
# Since there are so many pngs, you may want to delete them
rm *.png