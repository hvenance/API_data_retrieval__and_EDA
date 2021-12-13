##############
### IMPORT ###
##############

import pandas as pd
import matplotlib.pyplot as plt


#################
### FUNCTIONS ###
#################

plt.style.use('ggplot')		# Apply GGPLot library styling to our graph


def create_hist(data,  title, x_label, y_label, output_name, color='#85BDBF', orientation='vertical', bins=10, log=False, edgecolor='#040F0F'):
    """Given paramaters, this function will output an .PNG file containing an histogram in the 
    directory of script's excecution.
    """
    fig, ax = plt.subplots()  # Initialize our plot

    # Add element inside the plots
    ax.hist(
        data,
        bins=bins,
        log=log,
        color=color,
        orientation=orientation,
        edgecolor=edgecolor
    )

    # Add element outside the plot
    ax.set_xlabel(x_label)
    ax.set_ylabel(y_label)
    ax.set_title(title)

    # Save the plot as .png file
    plt.savefig(f'{output_name}.png')


def create_barh(data, title, output_name, x_label, y_label, color='#85BDBF', graph='barh'):
    """Given parameters, by default this function will outpute a .PNG file containing an horizontal barhart.
    However, if the parameter graph is set as 'bar', this will output a vertical bar.

    You can pass dictionary or pandas DataFrame as data parameter.
    """
    fig, ax = plt.subplots()

    if graph == 'barh':
        if isinstance(data, dict):
            ax.barh(
                list(data.keys()),
                list(data.values()),
                color=color,
            )
        else:
            ax.barh(
                data.index,
                data,
                color=color,
            )

    elif graph == 'bar':		# Only used for one graph
        ax.bar(
            data.index[1:],
            data[1:],
            color=color
        )
        plt.xticks(rotation=70, fontsize=8)

    ax.set_xlabel(x_label)
    ax.set_ylabel(y_label)
    ax.set_title(title)

    fig.tight_layout()
    plt.savefig(f'{output_name}.png')


#################
### LOAD DATA ###
#################

# Load the different dataframe.
# The runtime_cleaned.csv has been cleaned in the 'Data Exploration.ipynb' jupyter notebook.
df = pd.read_csv('output_db.csv')
df_runtime = pd.read_csv('runtime_cleaned.csv')


##############
### GRAPHS ###
##############

"""
In this sections we will create all the necessary graphs. 
For some we used dictionnaries, created in the 'Data Exploration.ipynb' jupyter notebook as this was more convinient, time and ressources less intensive.
"""
# YEAR
create_hist(df['Year'], title="Histogram of films' data release",
            x_label='Year', y_label='# of films', output_name='hist_year')

# RUNTIME
create_hist(df_runtime['runtime'], title="Histogram of films' runtime",
            x_label="Runtime (min)", y_label='# of films', output_name='runtime', bins=int(5), log=True)

# GENRE
dict_genre = {'Documentary': 153, 'Short': 967, 'Animation': 16, 'Comedy': 189, 'Sport': 13, 'Romance': 25, 'News': 16, 'Drama': 233, 'Fantasy': 54, 'Horror': 25,
              'Biography': 7, 'Music': 4, 'War': 10, 'Crime': 24, 'Western': 27, 'Family': 8, 'Adventure': 14, 'Action': 28, 'History': 14, 'Sci-Fi': 2, 'Mystery': 4}
# Sort the dictionary by ascending values.
dict_genre = {k: v for k, v in sorted(
    dict_genre.items(), key=lambda item: item[1], reverse=True)}

create_barh(dict_genre, title="Barchart of film per genre",
            output_name="genre", x_label="# Film", y_label="Genre")

# DIRECTOR

dict_directors = {'William K.L. Dickson': 17, 'Louis Lumière': 16, 'Georges Méliès': 109, 'Alice Guy': 172, 'George Albert Smith': 21, 'Walter R. Booth': 13, 'Fructuós Gelabert': 46,
                  'J. Stuart Blackton': 22, 'Edwin S. Porter': 27, 'Wallace McCutcheon': 34, 'Ignacio Coyne': 10, "Gilbert M. 'Broncho Billy' Anderson": 12, 'Viggo Larsen': 35, 'D.W. Griffith': 142, 'Theo Frenkel': 20}
# Sort the dictionary by ascending values.
dict_directors = {k: v for k, v in sorted(
    dict_directors.items(), key=lambda item: item[1], reverse=True)}


create_barh(dict_directors, title="Barchart of the most activate writer",
            output_name='director', x_label="# of films directed", y_label='Director')

# COUNTRY

dict_country = {'United States': 347, 'France': 335, 'Germany': 16,
                'United Kingdom': 75, 'UK': 29, 'Portugal': 15, 'Spain': 89, 'Denmark': 56}
# Sort the dictionary by descending values.
dict_country = {k: v for k, v in sorted(
    dict_country.items(), key=lambda item: item[1], reverse=1)}

create_barh(dict_country, title="Barchart of the most productive country",
            x_label='# of films shot', y_label='Country', output_name='country')

# RATING
create_hist(df['imdbRating'], title="Histogram of film rating",
            x_label="Imdb Rating", y_label="Frequency", output_name='ratings', bins=40)


# MISSING VALUES
"""
# To determine the number of missing values for each feature, we used the pandas .isna() function.
# This functions return an array of the same shape as the dataframe. With True if the value is missing, False otherwise.
# As True == 1 and False == 0, when we sum those values together we obtain the number of missing values.
"""
create_barh(df.isna().sum(), output_name='missing', title='Missing values per columns',
            x_label='# missing values', y_label='Column name', graph='bar')
