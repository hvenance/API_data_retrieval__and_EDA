# Initial imports
import requests
import pprint
import pandas as pd

# Constant objects
API_KEY = "bfea7860"
API_ADDRESS = f"http://www.omdbapi.com/?apikey={API_KEY}&"
INITIAL_IMDB_ID = "tt0000001"
#FINAL_IMDB_ID ="tt0010001"

# Requests
response = requests.get(API_ADDRESS + "i=" + INITIAL_IMDB_ID)
print(response)
# pprint(response.json())

#Create a 1000 IDs
lst = [str(i).zfill(7) for i in range(1,1001)]
lst
type(lst[1])
ID = []
for i in lst:
    incr = "tt"+i
    ID.append(incr)
print(ID)

#Create the Dataframe for the 1st ID
new_response=[]
initial_df = requests.get(API_ADDRESS + "i=" + INITIAL_IMDB_ID)
initial_df_json = initial_df.json()
print(initial_df_json)
df = pd.DataFrame(data=initial_df_json)
df

#Add other IDs to the Dataframe
for i in ID:
    #new_response.append(requests.get(API_ADDRESS + "i=" + INITIAL_IMDB_ID))
    rep = requests.get(API_ADDRESS + "i=" + i)
    rep_json = rep.json()
    df = df.append(rep_json, ignore_index=True)
    #df.add(rep_json)

df

#test
rep = requests.get(API_ADDRESS + "i=" + ID[2])


#Test
#Response by year
year ="2015"
response_year = requests.get(API_ADDRESS + "i=" + INITIAL_IMDB_ID + "y=" + year)
print(response_year)
print(response_year.json())



