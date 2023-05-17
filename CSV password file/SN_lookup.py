import csv
import pyperclip

with open('/home/dru/simple_example.csv') as csv_file:
    csv_data = list(csv.reader(csv_file, delimiter=','))
    del csv_data[0]
    while True:
        serial = input("Please enter SN: ")
        for row in csv_data:
            if row[3] == serial: 
                print(f'{row[11]} {row[12]}')
                pyperclip.copy(row[12])