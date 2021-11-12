import pandas as pd

dataset = pd.read_json("C:/Users/Hadrien Venance/python_and_r_luiss_2021/python_and_r_luiss_2021/output_db.json")
dataset.head()
dataset.tail()

dataset.to_csv('output_db.csv')