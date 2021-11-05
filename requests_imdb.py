import requests
import pandas as pd


# Constant objects
API_KEY = "9d167066"
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
    df = pd.DataFrame()
    for id in ids_list:
        response = requests.get(API_ADDRESS + "i=" + id)
        response = response.json()
        df = df.append(response, ignore_index=True)
    return df


def create_database():
    data = populate_dataframe()
    data.to_json("output_db.json")
    data.to_csv("output_db.csv")
    print('Completed!')


if __name__ == "__main__":
    create_database()



