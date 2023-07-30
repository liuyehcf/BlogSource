import sys
import csv
import os

source_csv_file_path = sys.argv[1]
directory = os.path.dirname(os.path.abspath(__file__))

source_csv_file_name = os.path.basename(source_csv_file_path)
source_csv_file_name_without_suffix = os.path.splitext(source_csv_file_name)[0]

target_csv_file_path = "%s/%s.md" % (directory, source_csv_file_name_without_suffix)

# Open the CSV file in read mode
with open(source_csv_file_path, "r") as in_file:
    with open(target_csv_file_path, "w") as out_file:
        # Create a CSV reader object
        reader = csv.reader(in_file)

        next(reader)

        # Iterate over each row in the CSV file
        for row in reader:
            # Extract the first two columns
            content = row[1]
            out_file.write("1. %s\n" % row[1])
