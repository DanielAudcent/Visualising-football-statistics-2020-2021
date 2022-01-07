# -*- coding: utf-8 -*-
"""
@author: Daniel Audcent 
Fundamentals to information visualisation

Web Scraping (Transfermarkt)
"""

#packages/libraries required
import requests
import pandas as pd
from bs4 import BeautifulSoup

#Date of club value evaluation
Date = "2020-10-15"


#Requested web page URL and custom header
URL = "https://www.transfermarkt.co.uk/premier-league/marktwerteverein/wettbewerb/GB1/stichtag/" + Date

header = {'User-Agent':"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:86.0) Gecko/20100101 Firefox/86.0"}

#Store webpage content in a python variable
Webpage_response = requests.get(URL, headers=header)
HTML_content = BeautifulSoup(Webpage_response.content, 'html.parser')

#Extract club names
club_names = []
club_tags = HTML_content.find_all("a", {"class":"vereinprofil_tooltip"} )

for i in range(0, len(club_tags)):
    if (club_tags[i].text != ""):
        club_names.append(club_tags[i].text)
        
#Extract club values at date evaluated   
club_values_at_date = []
club_current_values = []

for club_name in club_names:
    club_value_tags = HTML_content.find_all("a", {"title":club_name})
    if (club_value_tags[0].text != club_name):
        club_values_at_date.append(club_value_tags[0].text)
        club_current_values.append(club_value_tags[1].text)
    else:
        club_values_at_date.append(club_value_tags[1].text)
        club_current_values.append(club_value_tags[2].text)        

#Strip "£" and "m" in values at date selected
cust_cvad = []
for value in club_values_at_date:
    value = value.replace("£","")
    if "bn" in value:
        value = value.replace("bn","")
        #Also convert to numeric value (float)
        float_val = float(value)*1000
        cust_cvad.append(float_val)
    elif "m" in value:
        value = value.replace("m","")
        #Also convert to numeric value (float)
        float_val = float(value)
        cust_cvad.append(float_val)       
#Strip "£" and "m" in current values
cust_ccv = []
for value in club_current_values:
    value = value.replace("£","")
    if "bn" in value:
        value = value.replace("bn","")
        #Also convert to numeric value (float)
        float_val = float(value)*1000
        cust_ccv.append(float_val)
    elif "m" in value:
        value = value.replace("m","")
        #Also convert to numeric value (float)
        float_val = float(value)
        cust_ccv.append(float_val)  

output = pd.DataFrame({"Club Name": club_names, "Club value at " + Date + " (mil)":cust_cvad, "Current club value (mil)":cust_ccv})

output.to_csv(r"C:\Users\Daniel\Desktop\MSc Data Science\Semester 2\Fundamentals to Information visualisation\Assignment1\Data\TransferMarkt\Club_values_" + Date + ".csv", encoding='utf8', float_format='%.2f', index = False )






