if __name__ == "__main__":
    import readDst
    import plotsDst
    rdDst = readDst.ReadDstData()
    dstCalDF = rdDst.read_for_dst_calendar()
    plotObj = plotsDst.PlotDstData()
    # plotObj.line_plot(dstCalDF)
    plotObj.calendar_plot(dstCalDF)

class PlotDstData(object):
    """
    A class to make bokeh plots of the Dst data
    """

    def line_plot(self,dstCalDF):
        from bokeh.plotting import figure, output_file, show
        # prepare some data
        x = dstCalDF["date"]
        y = dstCalDF["dst_index"]

        # output to static HTML file
        output_file("lines.html", title="line plot example")

        # create a new plot with a title and axis labels
        p = figure(title="dst line plot", \
            x_axis_label='date', y_axis_label='dst-index',\
             x_axis_type="datetime")

        # add a line renderer with legend and line thickness
        p.line(x, y, legend="Dst", line_width=2)

        # show the results
        show(p)

    def calendar_plot(self,dstCalDF):
        from bokeh.layouts import row
        from bokeh.plotting import figure, show, output_file

        factors = ["a", "b", "c", "d", "e", "f", "g", "h"]
        x =  [50, 40, 65, 10, 25, 37, 80, 60]

        # dot = figure(title="Categorical Dot Plot", tools="", toolbar_location=None,
        #             y_range=factors, x_range=[0,100])

        # dot.segment(0, factors, x, factors, line_width=2, line_color="green", )
        # dot.circle(x, factors, size=15, fill_color="orange", line_color="green", line_width=3, )

        factors = ["foo", "bar", "baz"]
        x = ["foo", "foo", "foo", "bar", "bar", "bar", "baz", "baz", "baz"]
        y = ["foo", "bar", "baz", "foo", "bar", "baz", "foo", "bar", "baz"]
        colors = [
            "#0B486B", "#79BD9A", "#CFF09E",
            "#79BD9A", "#0B486B", "#79BD9A",
            "#CFF09E", "#79BD9A", "#0B486B"
        ]

        hm = figure(title="Categorical Heatmap", tools="hover", toolbar_location=None,
            x_range=factors, y_range=factors)

        hm.rect(x, y, color=colors, width=1, height=1)

        output_file("categorical.html", title="categorical.py example")

        show(row(hm))  # open a browser