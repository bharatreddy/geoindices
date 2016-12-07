gs -sDEVICE=pdfwrite -sOutputFile=jo-plot.pdf -dUseArtBox -dNOPAUSE -dEPSCrop -c "<</Orientation 2>> setpagedevice" -f jo-plot.ps -c quit
pdfcrop jo-plot.pdf
mv jo-plot-crop.pdf jo-plot.pdf
pdftocairo -png jo-plot.pdf
convert -delay 100 frames -loop 0 jo-plot-*.png jo-plot.gif
rm *.png
mv jo-plot.gif movies/
