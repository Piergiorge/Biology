import plotly.graph_objs as go
import pandas as pd

# Read the data with latitude and longitude
df = pd.read_csv('sampling_sites.csv')

# Create a scatter_geo trace
trace = go.Scattergeo(
    lon = df['longitude'],
    lat = df['latitude'],
    mode = 'markers',
    marker = dict(
        size = 8,
        symbol = 'circle',
        color = 'red',
        line = dict(
            width = 2,
            color = 'black'
        )
    ),
    text = df['site_name'], #text to show on hover
)

# Create a layout for the map
layout = go.Layout(
    title = 'Sampling Sites',
    geo = dict(
        scope = 'world',
        showland = True,
        landcolor = "rgb(212, 212, 212)",
        subunitcolor = "rgb(255, 255, 255)",
        countrycolor = "rgb(255, 255, 255)",
        lataxis = dict(
            range = [df['latitude'].min()-5, df['latitude'].max()+5],
            showgrid = True
        ),
        lonaxis = dict(
            range = [df['longitude'].min()-5, df['longitude'].max()+5],
            showgrid = True
        ),
        projection = dict(
            type = 'equirectangular'
        ),
    ),
)

# Create a figure
fig = go.Figure(data=[trace], layout=layout)

# Show the figure
fig.show()
