# compare_excel.py
The code compares the values in the same columns of two sheets in an Excel file using the pandas library in Python. Here's the readme.md:

## Compare values in two sheets of an Excel file using Pandas

## Steps
1 - Import the pandas library:
```python
import pandas as pd
```

2 - Read the data from the two sheets of the Excel file into separate data frames:

```python
df1 = pd.read_excel('file.xlsx', sheet_name='Sheet1')
df2 = pd.read_excel('file.xlsx', sheet_name='Sheet2')
```
* Note: Replace file.xlsx with the name of your Excel file, and Sheet1 and Sheet2 with the names of the sheets you want to compare.

3 - Compare the values in the same columns of the two data frames:

```python
result = df1.eq(df2)
```
This will return a boolean data frame with True values where the values in the same columns of the two data frames are equal, and False values where they are not.

4 - Print the comparison results:

```python
print(result)
```
This will print the comparison results to the console.

# rename_file_dir.py

This script is designed to change the file format of files in the current working directory.

## Script to Change File Format
This script allows the user to change the file format of files in the current working directory.
It prompts the user to enter the current file format and the new file format, and then iterates through the files in the directory, changing the file format of any files that match the old format.

## Usage
1 - Place the script in the directory containing the files you want to change the format of.
2 - Open a terminal or command prompt and navigate to the directory.
3 - Run the script by typing `python rename_file_dir.py` in the terminal or command prompt.
4 - Enter the current file format when prompted (e.g. txt).
5 - Enter the new file format when prompted (e.g. md).
6 - The script will then iterate through the files in the directory, changing the file format of any files that match the old format.
## Notes
* The script only changes the file format of files in the current working directory, not in any subdirectories.
* The script uses the os module to change the file format of the files. If there are any permission issues, the script may not be able to change the format of some files.
* The script will print a list of the files in the directory before and after the file format change.

# tsv2xlsx.py

This Python script reads a TSV file into a Pandas DataFrame, and then writes the DataFrame to an Excel file.

## Convert TSV file to Excel file using Pandas

This Python script reads a TSV file into a Pandas DataFrame, and then writes the DataFrame to an Excel file.

## Usage

1. Put the `tsv_to_excel.py` script in the same directory as your TSV file.
2. Open a terminal window and navigate to the directory where your TSV file and `tsv_to_excel.py` script are located.
3. Run the following command:

```python
python tsv_to_excel.py
```

4. The script will read the `data.tsv` file and create a new Excel file named `data.xlsx` in the same directory.


## Notes

- The TSV file must be formatted with tab-separated values.
- The Excel file will not include the index column of the DataFrame.
- The script assumes that the TSV file and script are located in the same directory. If they are not, you will need to modify the file paths in the script accordingly.
