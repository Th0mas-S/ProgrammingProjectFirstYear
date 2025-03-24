// Data already loaded in jasons flight directory code, copied and pasted here,
// Once integrated remove the load data
class Flight{
  String date;                          //list of all data points stored for each flight
  String airlineCode;
  String flightNumber;
  String origin;
  String destination;
  String scheduledDeparture;
  String actualDeparture;
  int departureDelay;
  int taxiOut;
  String wheelsOff;
  int scheduledFlightTime;
  int elapsedTime;
  int airTime;
  float flightDistance;
  String wheelsOn;
  int taxiIn;
  String scheduledArrival;
  String actualArrival;
  int arrivalDelay;
  boolean diverted;
  boolean cancelled;
  
  Flight(String date, String airlineCode, String flightNumber, String origin, String destination, String scheduledDeparture, String actualDeparture, int departureDelay, int taxiOut, String wheelsOff, int scheduledFlightTime, int elapsedTime, int airTime, float flightDistance, String wheelsOn, int taxiIn, String scheduledArrival, String actualArrival, int arrivalDelay, boolean diverted, boolean cancelled) {
    this.date = date;
    this.airlineCode = airlineCode;                            //setup...
    this.flightNumber = flightNumber;
    this.origin = origin;
    this.destination = destination;
    this.scheduledDeparture = scheduledDeparture;
    this.actualDeparture = actualDeparture;
    this.departureDelay = departureDelay;
    this.taxiOut = taxiOut;
    this.wheelsOff = wheelsOff;
    this.scheduledFlightTime = scheduledFlightTime;
    this.elapsedTime = elapsedTime;
    this.airTime = airTime;
    this.flightDistance = flightDistance;
    this.wheelsOn = wheelsOn;
    this.taxiIn = taxiIn;
    this.scheduledArrival = scheduledArrival;
    this.actualArrival = actualArrival;
    this.arrivalDelay = arrivalDelay;
    this.diverted = diverted;
    this.cancelled = cancelled;
  }

  public String toString() {
    return date + " | " + airlineCode + flightNumber + " | " + origin + " -> " + destination + 
           " | Scheduled: " + scheduledDeparture + " - " + scheduledArrival + 
           " | Actual: " + actualDeparture + " - " + actualArrival + 
           " | Delay: " + departureDelay + " min | Flight time: " + elapsedTime + " min | Diverted: " + diverted + " | Cancelled: " + cancelled + " | Distance: " + flightDistance + " km";
  }

}


String convertToDate(String day, String month, String year){          //used to format dd/mm/yyyy for all flights
  if(day.length()==1) day="0"+day;                                    //not used outside of initializeFlights()
  if(month.length()==1) month="0"+month;
  return(day+"/"+month+"/"+year);
}

ArrayList<Flight> flights;  

void loadData(int amountOfRows) { // amount of rows tells me how much data to load, it crashes my computer when i load too much
  flights = new ArrayList<Flight>();
  String[] rows = loadStrings("flights.csv");                      //contain all the data for an individual flight
  for(int i=1; i<amountOfRows; i++){
    String[] data = split(rows[i], ',');
    
    String date = convertToDate(data[3], data[1], data[0]);
    String airlineCode = data[4];
    String flightNumber = data[5];
    String origin = data[7];
    String destination = data[8];
    String scheduledDeparture = data[9];
    String actualDeparture = data[10];
    int departureDelay = int(data[11]);
    int taxiOut = int(data[12]);
    String wheelsOff = data[13];
    int scheduledFlightTime = int(data[14]);
    int elapsedTime = int(data[15]);
    int airTime = int(data[16]);
    float flightDistance = float(data[17]);
    String wheelsOn = data[18];
    int taxiIn = int(data[19]);
    String scheduledArrival = data[20];
    String actualArrival = data[21];
    int arrivalDelay = int(data[22]);
    boolean diverted = (int(data[23])==1);
    boolean cancelled = (int(data[24])==1);

    flights.add( new Flight(date, airlineCode, flightNumber, origin, destination, scheduledDeparture, actualDeparture, departureDelay, taxiOut, wheelsOff, scheduledFlightTime, elapsedTime, airTime, flightDistance, wheelsOn, taxiIn, scheduledArrival, actualArrival, arrivalDelay, diverted, cancelled));
  }
}
///////////////////////// JASON CODE END /////////////////////////////////////////////////////

HashMap<String, Location> loadAirportCoordinates(String filepath) {
  String[] rows = loadStrings(filepath);
  HashMap<String, Location> airportLocations = new HashMap<String, Location>();
  for(int i=1; i<rows.length; i++){
      String[] data = split(rows[i], ',');
      
      airportLocations.put(data[0], new Location(parseFloat(data[1]), parseFloat(data[2])));
  }
  
  return airportLocations;
}

class HeatMapScreen extends Screen {
  
  PImage earthImage;
  HashMap<String, Location> airportLocations;     // probably should make this global seems useful for EarthScreen
  
  final float SCALE = 5; // idk what to call this, this is how big the sqaures are
  final int heatMapOpacity = 130;
  final int heatMapWidth = (int)(width / SCALE);
  final int heatMapHeight = (int)(height / SCALE);
  int[][] heatMap;
  
  float zoom = 1.0;

  
  HeatMapScreen() {
    earthImage = loadImage("worldmap.png");
    loadData(4000000);
    this.airportLocations = loadAirportCoordinates("coordinate.csv");
    heatMap = new int[heatMapWidth][heatMapHeight];
    generateHeatMap();
    
  }
  
  void draw() {
    background(0);

    pushMatrix();
    translate(mouseX, mouseY);
    scale(zoom);
    translate(-mouseX, -mouseY);
    image(earthImage, 0, 0, width, height);
    drawHeatMap();
    popMatrix();
  }
  
  void generateHeatMap() { // call when user wants to see a different heatmap?
    for(int x = 0; x < heatMapWidth; x++) {
      for(int y = 0; y < heatMapHeight; y++) {
        heatMap[x][y] = 0;
      }
    }
    
    for(Flight f : flights) {
       Location src = this.airportLocations.get(f.origin);
       Location des = this.airportLocations.get(f.destination);
       
       int srcMapX = (int)mapX(src.lon);
       int srcMapY = (int)mapY(src.lat);
       int desMapX = (int)mapX(des.lon);
       int desMapY = (int)mapY(des.lat);
       
       int distance = (int)dist(srcMapX, srcMapY, desMapX, desMapY);
       
       // Define a control point: midpoint, raised upwards to curve
       float controlX = (srcMapX + desMapX) / 2;
       float controlY = (srcMapY + desMapY) / 2 - distance / 4;
       
       for(int i = 0; i < distance; i++) { // this loop breaks up the line between src and des into 10 parts and adds it
         float t = map(i, 0, distance, 0, 1); // says which part we are on, range between 0 and 1 for lerp
         
         int posX = (int)(bezierPoint(srcMapX, controlX, controlX, desMapX, t) / SCALE);
         int posY = (int)(bezierPoint(srcMapY, controlY, controlY, desMapY, t) / SCALE);
         
         heatMap[posX][posY] += 1;
         
       }
    }
  }
  
  void drawHeatMap() {
    for(int x = 0; x < heatMapWidth; x++) {
      for (int y = 0; y < heatMapHeight; y++) {
        int intesity = heatMap[x][y];
        
        if (intesity > 0) {
          
          color intesityColor = getIntensityColor(map(intesity, 1, 500, 0, 1));
          
          fill(intesityColor);
          
          rect(x * SCALE, y * SCALE, SCALE, SCALE);
        }
      }
    }
  }
  
  color getIntensityColor(float intensity) {
    if(intensity < 0.5)
      return lerpColor(color(0, 0, 255, heatMapOpacity), color(255, 255, 0, heatMapOpacity), intensity);
    else
      return lerpColor(color(255, 255, 0, heatMapOpacity), color(255, 0, 0, heatMapOpacity), intensity);

  }
  float mapX(float lon) {
    return map(lon, -180, 180, 0, width);
  }

  float mapY(float lat) {
    return map(lat, 90, -90, 0, height);
  }
  
  void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    zoom -= e * 0.5;
    zoom = constrain(zoom, 1, 10);
  }
}
