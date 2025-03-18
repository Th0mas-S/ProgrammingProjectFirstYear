
import pandas as pd

# https://github.com/ip2location/ip2location-iata-icao

flightsdf = pd.read_csv("flights.csv")
iatadf = pd.read_csv("iata-icao.csv")

# all the airport codes in our dataset
airportCodes = flightsdf["ORIGIN"].drop_duplicates()

# filteredIatadf = iatadf.loc[iatadf["iata"].isin(airportCodes)]

coordinateDf = iatadf[["iata", "latitude", "longitude"]]

coordinateDf.to_csv("coordinate.csv", index=False)