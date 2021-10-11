# Initial imports
import requests

# Constant objects
API_KEY = "9d167066"
API_ADDRESS = f"http://www.omdbapi.com/?apikey={API_KEY}&"
INITIAL_IMDB_ID = "tt0000001"

# Requests
response = requests.get(API_ADDRESS + "i=" + INITIAL_IMDB_ID)
print(response)
print(response.json())
