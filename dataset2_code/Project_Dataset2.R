rm(list=ls())

#install and load libraries
packages = c("dplyr", "ggplot2", "ggmap", "sf", "mapview", "corrplot", "plotly", "lubridate")

# Install packages not yet installed
installed_packages = packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
#packages loading
lapply(packages, library, character.only = TRUE)


#read csv file
data <- read.csv("C:/Users/Hadrien Venance/python_and_r_luiss_2021/python_and_r_luiss_2021/Dataset2_OpenMeteo.txt")

View(data)
head(data)
summary(data)

#remove all the columns containing unit measures
data <- data %>% 
    select(-contains("units"))

#rename the columns, without the hourly and other useless punctuation
colnames(data)<-gsub("hourly","",colnames(data))

data <- data %>%
  rename_with(~ gsub('[[:punct:]]', '', .x))

head(data)

#transform the lat and long coordinates into cities location
locations<- st_as_sf(data, coords = c("longitude", "latitude"), crs = 4326)
mapview(locations)
#in this df we now also have a unique identifier for the variables

unique(data$elevation)
unique(locations$geometry)
data[505,] == data[1,]
#unlike what we read in the README file it seems that only 5 cities data have been uploaded.
#as such, Rome is missing in the dataset; the issue is that the content of what was supposed to be Rome only contains info related to the 1st city 
#which is Berlin 

#we decided then to remove the duplicates
data %>% distinct()

#converts in character type for ggplot object
data$elevation <- as.character(data$elevation)

ggplot(data) +
  geom_point(mapping = aes(x = time, y= temperature2m, color = elevation))+
  #scale_color_discrete(name = "City", labels = c("New York", "London", "Tokyo", "Berlin", "Paris"))+
  ggtitle("Temperature in cities across time")+
  theme(plot.title = element_text(hjust = 0.5))
#on this plot it seems that elevation  is not really an indicator of the temperature
#we observe no negative temperature and the maximum temperature is above 20 degrees


names = c("New York", "London", "Tokyo", "Berlin", "Paris")
elevation = sort(unique(data$elevation))
dico = c()
#populate the dico
for (i in 1:5){
  dico[elevation[i]] = names[i]
}

#group the observations per day to have a more readable x-axis
data$day <- day(data$time)
ggplot(data) +
  geom_point(mapping = aes(x = day, y= temperature2m, color = elevation))+
  scale_color_discrete(name = "City", labels = c("New York", "London", "Tokyo", "Berlin", "Paris"))+
  ggtitle("Temperature in cities across days")+
  theme(plot.title = element_text(hjust = 0.5))

#one of the advantages of using facet is that with categorical data we can focus on particular facets alone
elevation.labs <- elevation
names(elevation.labs) <- c("New York", "London", "Tokyo", "Berlin", "Paris")
ggplot(data) +
  geom_point(mapping = aes(x = day, y= temperature2m)) +
  facet_wrap(~elevation, nrow = 2)+
  ggtitle("Facet of temperature in elevation cities across days")+
  theme(plot.title = element_text(hjust = 0.5))



#because the geom_boxplot line of code reads 'day' as numeric we have to edit the type of the variable
data$day <- as.character(data$day)
ggplot(data) +
  geom_boxplot(mapping = aes(x = day, y= temperature2m, color=day))+
  ggtitle("Boxplot of temperature in cities across days")+
  theme(plot.title = element_text(hjust = 0.5))
#on the day 3 it seems that there the most outliers


#compute air temperature 2 meters above the ground
temperature_by_cities <- data %>% 
                      select(elevation, apparenttemperature) %>%
                      group_by(elevation) %>% 
                        summarise(temperature = mean(apparenttemperature, na.rm=TRUE))
#rename the columns for visualisation purposes in ggplot
names = c("New York", "London", "Tokyo", "Berlin", "Paris")
temperature_by_cities$City_names <- names

ggplot(temperature_by_cities)+
  geom_point(mapping = aes(y = temperature, x= City_names , size = elevation))+
  ggtitle("Temperature in cities displayed with their elevation")+
  theme(plot.title = element_text(hjust = 0.5))

#from this plot, we can rightfully inspect if there is a correlation between the temperature and the elevation of the cities


temperature_by_cities$elevation <- as.numeric(temperature_by_cities$elevation)
temperature_by_cities.cor <- cor(temperature_by_cities[,-3])
corrplot(temperature_by_cities.cor, title="Correlation between cities elevation and temperature", mar=c(0,0,2,0))



#in the database, we also noticed that there were 2 kind of temperatures, namely the air temperature 2 meters above the ground and the perceived
#feel like temperature
feels_temp_by_cities <- data %>% 
  select(elevation, temperature2m, apparenttemperature, relativehumidity2m) %>%
  group_by(elevation) %>% 
  summarise(temperature = mean(temperature2m, na.rm=TRUE), feels_like_temp = mean(apparenttemperature, na.rm=TRUE), humidity = mean(apparenttemperature, na.rm=TRUE))
feels_temp_by_cities$City_names <- names
head(feels_temp_by_cities)

#we moved the city names at the beginning of the dataframe for clarity purposes
feels_temp_by_cities <- feels_temp_by_cities %>%
    select(City_names, everything())
head(feels_temp_by_cities)
hottest_city <- which(feels_temp_by_cities$temperature == max(feels_temp_by_cities$temperature))
hottest_city_name <- feels_temp_by_cities[hottest_city,1]
hottest_city_name
#from our analysis, it seems that Tokyo is by fat the hottest city in the dataset 

figure <- with(feels_temp_by_cities, plot_ly(x=feels_like_temp, y=City_names, z=temperature, type="scatter3d", mode="markers", color=feels_like_temp))
figure <- figure %>% add_markers()
figure <- figure %>% layout(scene = list(xaxis = list(title = 'Apparent temperature'),
                                     yaxis = list(title = 'City names'),
                                     zaxis = list(title = 'Real temperature')))
#as we can see from this 3D plot it seems that a higher apparent temperature is as expected related with a higher real measured temperature
#to confirm our visual insights, let us compute the correlation
feels_temp_by_cities$elevation <- as.numeric(feels_temp_by_cities$elevation)
(feels_temp_by_cities.cor <- cor(feels_temp_by_cities[,-1]))
corrplot(feels_temp_by_cities.cor, title = "Correlation between feels like temperature /n and supposedly correlated variables", mar=c(0,0,2,0))
#correlations are really high between temperature and feels like temperature, as well as between temperatures and humidity 


#look at humidity and precipitation
water_by_cities <- data %>% 
  select(elevation, precipitation, relativehumidity2m) %>%
  group_by(elevation) %>% 
  summarise(precipitation = mean(precipitation, na.rm=TRUE), humidity = mean(relativehumidity2m, na.rm=TRUE))

#same renaming of columns as before 
water_by_cities$City_names <- names

ggplot(water_by_cities)+
  geom_point(mapping = aes(y = precipitation, x= City_names , size = humidity))+
  ggtitle("Precipitations in cities displayed with their elevation")+
  theme(plot.title = element_text(hjust = 0.5))

water_by_cities$elevation <- as.numeric(water_by_cities$elevation)
(water_by_cities.cor <- cor(water_by_cities[,-4]))
corrplot(water_by_cities.cor, title = "Correlation between water related variables in cites and elevation", mar=c(0,0,2,0))
#it seems that the elevation is slightly highly correlated with the humidity
#surprisingly, the precipitation that happened the hour before the weather report does not seem correlated to humidity at all

#winter/cold conditions
unique(data[,9])
#for all the selected cities, none of them has a single meter of snow on he ground


#atmospheric pressure is an indicator of weather. As such, according to National Geographic,
#When a low-pressure system moves into an area, it usually leads to cloudiness, wind, and precipitation. High-pressure systems usually lead to fair, calm weather. 
#Let's try to verifiy this stated fact
#(https://www.nationalgeographic.org/encyclopedia/atmospheric-pressure/#:~:text=Atmospheric%20pressure%20is%20an%20indicator,lead%20to%20fair%2C%20calm%20weather.)
atmosphere_by_cities <- data %>% 
  select(elevation, pressuremsl, relativehumidity2m, precipitation, temperature2m) %>%
  group_by(elevation) %>% 
  summarise(pressure = mean(pressuremsl, na.rm=TRUE), humidity = mean(relativehumidity2m, na.rm=TRUE), precipitation = mean(precipitation, na.rm=TRUE), temperature = mean(temperature2m, na.rm=TRUE))

#same renaming of columns 
atmosphere_by_cities$City_names <- names
head(atmosphere_by_cities)

atmosphere_by_cities <- atmosphere_by_cities%>% 
   select(City_names, everything())

ggplot(atmosphere_by_cities)+
  geom_point(mapping = aes(y = precipitation, x= pressure , size = humidity))+
  ggtitle("Precipitations by pressure levels displayed with their humidity level")+
  theme(plot.title = element_text(hjust = 0.5))
#contrarily to what we expected from national geographic, a higher pressure does not seem to indicate higher precipitation

atmosphere_by_cities$elevation <- as.numeric(atmosphere_by_cities$elevation)
(atmosphere_by_cities.cor <- cor(atmosphere_by_cities[,-1]))
corrplot(atmosphere_by_cities.cor, title = "Correlation between atmosphere and water related variables", mar=c(0,0,2,0))
#it looks like there is a strong negative correlation between pressure and humidity and precipitation

#let us now considerate the relation between the freezing level height and the atmospheric pressure
freezing_by_cities <- data %>% 
  select(elevation, freezinglevelheight ,pressuremsl, relativehumidity2m, precipitation, temperature2m) %>%
  group_by(elevation) %>% 
  summarise(freezing_height = mean(freezinglevelheight, na.rm= T), pressure = mean(pressuremsl, na.rm=TRUE), humidity = mean(relativehumidity2m, na.rm=TRUE), precipitation = mean(precipitation, na.rm=TRUE), temperature = mean(temperature2m, na.rm=TRUE))

ggplot(freezing_by_cities)+
  geom_point(mapping = aes(y = freezing_height, x= pressure , color = elevation))+
  ggtitle("Freezing height by pressure levels displayed with their elevation level")+
  theme(plot.title = element_text(hjust = 0.5))
#it seems that freezing height is not really related to pressure 



