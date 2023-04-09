# folium.py
The code creates a map using the `folium` library in Python. It reads the location data from a CSV file, adds markers for each sampling site, and saves the map as an HTML file.

## Here are the steps in detail:

```python
import folium
import pandas as pd
# Read the data with latitude and longitude from a CSV file:
df = pd.read_csv('sampling_sites.csv')
# Create a map centered on the mean coordinates of the sampling sites:
center = [df['latitude'].mean(), df['longitude'].mean()]
map = folium.Map(location=center, zoom_start=5)
# Add markers for each sampling site using a loop that iterates through the rows of the data frame:
for _, row in df.iterrows():
    folium.Marker([row['latitude'], row['longitude']],
                  popup=row['site_name']).add_to(map)
# Save the map to an HTML file:
map.save('./sampling_sites.html')
```
# plotly_map.py
## Plotting Geographical Data using Plotly
This code reads a CSV file containing geographical data (latitude and longitude) for different sampling sites, creates a scattergeo trace and plots the locations on an interactive world map using Plotly. The color, size, and shape of the markers can be customized, and the map can be zoomed in or out and panned to view different regions. Hovering over a marker displays a popup with information about the site. The resulting figure can be exported as an HTML file or as a static image.
