if __name__ == "__main__":
    import readDst
    import plotsDst
    rdDst = readDst.ReadDstData()
    # dstCalDF = rdDst.read_for_dst_calendar()
    plotObj = plotsDst.PlotDstData()
    # plotObj.line_plot(dstCalDF)
    plotObj.calendar_plot()

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

    def calendar_plot(self):
        from plotly.offline import download_plotlyjs, init_notebook_mode, plot, iplot
        import plotly.plotly as py
        from plotly.graph_objs import Bar, Scatter, Figure, Layout
        trace = Bar(x=[1,2,3],y=[4,5,6])
        data = [trace]
        layout = Layout(title='Test')
        fig = Figure(data=data,layout=layout)

        # Save the figure as a png image:
        py.image.save_as(fig, 'test.png')