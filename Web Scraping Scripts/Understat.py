# -*- coding: utf-8 -*-
"""

@author: Daniel Audcent 
Fundamentals to information visualisation

Script adapted from Vaastav Anaand github repository.
https://github.com/vaastav/Fantasy-Premier-League/blob/master/understat.py

Web Scraping (Understat)
"""
#packages / libraries required
import requests
import pandas as pd
from bs4 import BeautifulSoup
import json
import re
import codecs
import os

#Options
league_options = ['La_liga', 'EPL', 'Bundesliga', 'Serie_A', 'Ligue_1', 'RFPL']
season_options = ['2014', '2015', '2016', '2017', '2018', '2019', '2020']
standard_URL = "https://understat.com/league"

# URL Creation and header options
League_selected = league_options[1]
season_selected = season_options[6]
URL = standard_URL + "/" + League_selected +'/' + season_selected 
header = {'User-Agent':"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:86.0) Gecko/20100101 Firefox/86.0"}


def get_data(url):
    response = requests.get(url, headers=header)
    if response.status_code != 200:
        raise Exception("Response was code " + str(response.status_code))
    html = response.text
    parsed_html = BeautifulSoup(html, 'html.parser')
    scripts = parsed_html.findAll('script')
    filtered_scripts = []
    for script in scripts:
        if len(script.contents) > 0:
            filtered_scripts += [script]
    return scripts

def get_custom_data():
    scripts = get_data(URL)
    teamData = {}
    playerData = {}
    for script in scripts:
        for c in script.contents:
            split_data = c.split('=')
            data = split_data[0].strip()
            if data == 'var teamsData':
                content = re.findall(r'JSON\.parse\(\'(.*)\'\)',split_data[1])
                decoded_content = codecs.escape_decode(content[0], "hex")[0].decode('utf-8')
                teamData = json.loads(decoded_content)
            elif data == 'var playersData':
                content = re.findall(r'JSON\.parse\(\'(.*)\'\)',split_data[1])
                decoded_content = codecs.escape_decode(content[0], "hex")[0].decode('utf-8')
                playerData = json.loads(decoded_content)
    return teamData, playerData

def get_player_data(id):
    scripts = get_data("https://understat.com/player/" + str(id))
    groupsData = {}
    matchesData = {}
    shotsData = {}
    for script in scripts:
        for c in script.contents:
            split_data = c.split('=')
            data = split_data[0].strip()
            print(data)
            
def parse_custom_data(outfile_base):
    teamData,playerData = get_custom_data()
    new_team_data = []
    for t,v in teamData.items():
        new_team_data += [v]
    for data in new_team_data:
        team_frame = pd.DataFrame.from_records(data["history"])
        team = data["title"].replace(' ', '_')
        team_frame.to_csv(os.path.join(outfile_base, season_selected + "\\" + team + "_" + season_selected +  '.csv'), index=False)
    player_frame = pd.DataFrame.from_records(playerData)
    player_frame.to_csv(os.path.join(outfile_base, season_selected + "\\" + 'understat_player.csv'), index=False)
      

def main():
    parse_custom_data(r"C:\\Users\\Daniel\\Desktop\\MSc Data Science\\Semester 2\\Fundamentals to Information visualisation\\Assignment1\\Data\Understat\\")
    #get_player_data(318)

if __name__ == '__main__':
    main()















