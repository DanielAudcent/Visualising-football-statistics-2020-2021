# -*- coding: utf-8 -*-
"""
@author: Daniel Audcent 
Fundamentals to information visualisation

Web Scraping (worldfootball.net)
"""

#packages/libraries required
import requests
import csv
from bs4 import BeautifulSoup

#Season / Matchweek required (15Sep/15Jan)
season = "2020-2021"
matchweek = "17"

output_filename = season + "_matchweek" + matchweek + ".txt" 
save_loc = "C:\\Users\\Daniel\\Desktop\\MSc Data Science\\Semester 2\\Fundamentals to Information visualisation\\Assignment1\\Data\\worldfootball.net\\"
file = save_loc + output_filename

#Requested web page URL and custom header
URL = "https://www.worldfootball.net/schedule/eng-premier-league-" + season + "-spieltag/" + matchweek

header = {'User-Agent':"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:86.0) Gecko/20100101 Firefox/86.0"}

#Store webpage content in a python variable
Webpage_response = requests.get(URL, headers=header)
HTML_content = BeautifulSoup(Webpage_response.content, 'html.parser')

#Extract contents of table into one long string
club_names = []
table_contents = HTML_content.find_all("table",{"class": "standard_tabelle"})
reduced_table_contents = table_contents[1].text.replace("\n", ",").strip()

#build table by removing all cases of consecutive commas
mystring = ""
for i in range(1, len(reduced_table_contents)-1,1):
    if reduced_table_contents[i] == ",":
        if reduced_table_contents[i+1] == ",":
            continue
        else:
            mystring += str(reduced_table_contents[i])
    else:
        mystring += str(reduced_table_contents[i])

#additional changes if necessary:
#remove leading commas
full_string = mystring[1:]

#create list of table rows
rows_list = []
comma_count = 0
last_pos = 0

for i in range(1, len(full_string)-1,1):
    if full_string[i] == ",":
        if len(rows_list) > 19:
            break
        else:
            comma_count += 1
            if comma_count > 7:
                rows_list.append(full_string[last_pos:i])
                last_pos = i+1
                comma_count = 0
    else:
        continue

# Add final missing row to list of rows
rows_list.append(full_string[i-2:])

#Split Draws/Loss column
rows_list[0] = rows_list[0].replace(" ", ",")
com_count = 0
for i in range(1,21,1):
    for j in range(1, len(rows_list[i]),1):
        if rows_list[i][j] == ",":
            com_count += 1
        elif com_count > 3 and rows_list[i][j] == " ":
            rows_list[i] = rows_list[i][:j] + "," + rows_list[i][j+1:]
            
    
# replace colon with comma in every line and separate goals column name
rows_list[0] = rows_list[0].replace("goals", "goals for,goals against")
for i in range(1,21,1):
    position = rows_list[i].find(":")
    rows_list[i] = rows_list[i][:position] + "," + rows_list[i][position+1:] 
    
#add new lines indicators to each row and write to txt file

with open(file, "w") as f:
    f.write("\n".join(rows_list))

    

 