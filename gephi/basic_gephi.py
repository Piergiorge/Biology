import pandas as pd
from gephi_toolkit.graph import Graph

# Read the table into a DataFrame
df = pd.read_csv('table.csv')

# Create a graph from the DataFrame
g = Graph.from_dataframe(df, source='Source', target='Target')

# Display the graph
g.show()
