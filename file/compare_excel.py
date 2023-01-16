import pandas as pd

# Read data from two sheets of the Excel file
df1 = pd.read_excel('file.xlsx', sheet_name='Sheet1')
df2 = pd.read_excel('file.xlsx', sheet_name='Sheet2')

# Compare the values in the same columns
result = df1.eq(df2)

# Print the comparison results
print(result)
