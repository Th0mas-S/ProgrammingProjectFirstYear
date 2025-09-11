# Flight Tracker
Flight Tracker allows aviation enthusiasts, data analysts, and hobbyists to visualize and analyze a full year of global flight data. Users can interact with a 3D globe, filter flights, view heatmaps of the busiest routes, and uncover trends in airline performance and delays.



https://github.com/user-attachments/assets/24969cbc-813a-4823-91e3-6466c01776d6



# Features
- **3D Visualization:** Interactive flight path simulation on a 3D globe.
- **Filtering & Search:** Search flights and filter by airline, month, or delay status.
- **Heatmaps:** View the busiest routes and regions globally.
- **Analytics:** Eight animated graphs showing top destinations, airline performance, monthly flights, and delays.

# Setup

1. Clone the repository
    
        git clone <repo-url>

2. Go to releases and download the **flight_data_2017.csv** dataset
3. Put csv file the in the **Main/data** folder
4. Open Main folder in processing
5. Make sure to install the sound module in processing by going to Sketch > Import Library > Manage Libraries. Then install Sound | The Processing Foundation
6. Hit Run in processing to start the application

# Usage

Once the program is running, you can:
- Rotate and zoom the 3D globe.
- Click on flights to view detailed information.
- Filter flights by airline, month, or delay status.
- Explore heatmaps and animated graphs to analyze flight patterns.

# Data
The data that we used came from multiple sources and stitched together into their respective csv files for easier use.

**flight_data_2017.csv** - date, airline_name, airline_code, flight_number, origin, destination, scheduled_departure, scheduled_arrival, actual_departure, actual_arrival, minutes_late,flight_distance, cancelled, diverted

**airport_data.csv** - Rank, Airport Name, IATA Code, City, Country, Passengers, latitude, longitude, flights, updated flights

**airline_codes.csv** - airline_code, airline_name

## Sources
https://www.partow.net/miscellaneous/airportdatabase
https://figshare.com/articles/dataset/flights_csv/9820139?file=17614757


# Technologies
- Java
- [Processing](https://processing.org)
- Python (for generating datasets)

# Members
 - Thomas Shanahan
 - Darragh O'Toole
 - Aman Pathak
 - Ben Murphy
 - Atticus Phoenix
 - Jason Conboy
 - Aiwan Spartan

