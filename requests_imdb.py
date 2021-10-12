import requests
import pandas as pd

# Constant objects
API_KEY = "bfea7860"
API_ADDRESS = f"http://www.omdbapi.com/?apikey={API_KEY}&"
INITIAL_IMDB_ID_PREFIX = "tt"


def generate_1000_ids():
    """ Generate 1000 imdb film ids """

    suffix_list = [str(i).zfill(7) for i in range(1, 1001)]
    ids_list = []

    for suffix in suffix_list:
        id = INITIAL_IMDB_ID_PREFIX + suffix
        ids_list.append(id)

    return ids_list


def populate_dataframe():
    ids_list = generate_1000_ids()
    response = requests.get(API_ADDRESS + "i=" + ids_list[0])
    response = response.json()

    df = pd.DataFrame(data=response)

    return df


def create_database():
    data = populate_dataframe()
    data.to_json("out.json")
    print('out')


if __name__ == "__main__":
    create_database()
