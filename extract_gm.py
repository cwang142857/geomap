#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib
import requests
import json
import time
import pandas as pd

def url_gen(access_token, search_text='',types_text='',next_token=''):
    base_url = 'https://maps.googleapis.com/maps/api/place/textsearch/json'
    key_string = '?key='+access_token                                           
    query_string = '&query='+urllib.quote(search_text)
    sensor_string = '&sensor=false'                                             
    type_string = ''
    if types_text!='':
        type_string = '&types='+urllib.quote(types_text)                        
    next_string=''
    if next_token!='':
        next_string='&pagetoken='+next_token
    url = base_url+key_string+query_string+sensor_string+type_string+next_string
    return url
def main():
    # repalce with user TOKEN
    token = 'AIzaSyAeTvcCLp0rIO9OM2SNxPDmxHE2g-5mD2I' #'TOKEN HERE' 
    # input parameters
    names=["mcdonald's","shake shack","chipotle mexican grill"] # name of the POIs
    city='new york'
    state='ny'
    hl=['formatted_address', 'country', 'state', 'zip', 'city', 'addr', 'lat', 'lng', 'name', 'gid']
    df_list=[]
    
    # get data per franchise name
    for nm in names:
        print 'extracting %s...' % nm
        nt=''
        st=','.join([nm,city,state]).lower()
        
        # get results from each page
        while nt!='NULL':
            time.sleep(4)
            #get url
            url=url_gen(access_token=token, search_text=st, next_token=nt)
            #connect API
            response = requests.get(url)
            #get data
            results=response.json()
            try:
                nt=results['next_page_token']
            except:
                nt='NULL'
            for s in results['results']:
				al=s['formatted_address'].split(',')
				df_list.append([s['formatted_address'],al[-1].strip(),al[-2].split()[0].strip(),al[-2].split()[1].strip(),al[-3].strip(),','.join(al[:-3]),s['geometry']['location']['lat'], s['geometry']['location']['lng'], s['name'].split('-')[0].strip(), s['id']])
    # write data to csv
    df=pd.DataFrame(df_list, columns=hl)
    df.to_csv('sample_data.csv', index=False)
    print 'data extracted!'
if __name__ == "__main__":
    print "Google Maps Places API..."
    try:
        main()
    except KeyboardInterrupt:
        print "Ctrl+C pressed. Stopping..." 