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
