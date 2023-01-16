import os
"""
Get the current working directory, and the list of files in the directory.
It then prompts the user for the old and new file formats, and uses a for
loop to iterate through the files in the directory. If a file ends with
the old format, it uses the os.rename() function to change the
file's extension to the new format.
"""
# Get the current working directory
cam = os.getcwd()

# Get the list of files in the directory
var = os.listdir(cam)

# Get the old and new file format from user input
old = input("Enter the format you want to change: ")
new = input("Enter the new format: ")


# Print the directory and the files in it
print("##Changing the format of files {} to format {} ...\n".format(old, new))
print("{} contains: \n{}\n".format(cam, var))

# Iterate through the files and rename them
for file in var:
    if file.endswith(old):
        os.rename(file, file.replace(old, new))
