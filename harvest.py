import requests, csv, io

response = requests.get("https://data.un.org/ws/rest/data/DF_UNData_UNFCC", headers={"Accept":"text/csv"})
response.encoding = 'utf-8'
csvio = io.StringIO(response.text, newline="")
reader = csv.DictReader(csvio)
responsestructure = requests.get("https://data.un.org/ws/rest/data/DF_UNData_UNFCC", headers={"Accept":"text/json"})
structure = responsestructure.json()['structure']
code = 'EN_ATM_METH_XLULUCF'
methaneonly = []
structuredict = {}
for struct in structure['dimensions']['series']:
    for value in struct['values']:
        structuredict[value['id']] = value['name']
for row in reader:
    if row['INDICATOR'] == code:
        newrow = {}
        for key in row:
            newrowvalue = structuredict[row[key]] if row[key] in structuredict.keys() else row[key]
            newrow[key] = newrowvalue
        methaneonly.append(newrow)
with open("{}.csv".format(code), 'w', newline='') as csvfile:
    fieldnames = methaneonly[0].keys()
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    for row in methaneonly:
        writer.writerow(row)