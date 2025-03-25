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

import java.util.Collections;


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
  
  final float SCALE = 1; // idk what to call this, this is how big the sqaures are EDIT: sqaure size seems like a good name
  final int heatMapOpacity = 100;
  final int heatMapWidth = (int)(width / SCALE);
  final int heatMapHeight = (int)(height / SCALE);
  int[][] heatMap;
    
  int medianIntensity = 0;
  
  float scaleFactor = 1.0;
  float offsetX = 0;
  float offsetY = 0;
  float startX, startY;
  boolean isDragging = false;

  
  HeatMapScreen() {
    earthImage = loadImage("worldmap.png");
    loadData(400000);
    this.airportLocations = loadAirportCoordinates("coordinate.csv");
    heatMap = new int[heatMapWidth][heatMapHeight];
    generateHeatMap();
    
  }
  
  void draw() {
    background(0);

    pushMatrix();
    translate(offsetX, offsetY);
    scale(scaleFactor);

    image(earthImage, 0, 0, width, height);
    drawHeatMap();
    popMatrix();
    
    int zoomedMouseX = (int)((mouseX - offsetX) / scaleFactor);
    int zoomedMouseY = (int)((mouseY - offsetY) / scaleFactor);
    
    if(heatMap[zoomedMouseX][zoomedMouseY] != 0)
      drawIntensityTab(heatMap[zoomedMouseX][zoomedMouseY]);
  }
  
  void drawIntensityTab(int intensity) {
    stroke(0);
    strokeWeight(5);
    fill(255);
    rect(10, 10, 200, 50);
    noStroke();
    
    fill(0);
    textSize(20);
    text("Flights This Area: " + intensity, 15, 35);
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
    
    medianIntensity = 0;
    ArrayList<Integer> tempList = new ArrayList<Integer>();
    
    for(int x = 0; x < heatMapWidth; x++)
      for(int y = 0; y < heatMapHeight; y++)
        if(heatMap[x][y] != 0)
          tempList.add(heatMap[x][y]);
  
      
     Collections.sort(tempList);
         
     if(tempList.size() % 2 == 0)
       medianIntensity = tempList.get(tempList.size() / 2);
     else
       medianIntensity = tempList.get((tempList.size() + 1) / 2);
     
     println(medianIntensity);
  }
  
  void drawHeatMap() {
    for(int x = 0; x < heatMapWidth; x++) {
      for (int y = 0; y < heatMapHeight; y++) {
        int intesity = heatMap[x][y];
        
        if (intesity > 0) {
          
          color intesityColor = getIntensityColor(intesity);
          
          fill(intesityColor);
          rect(x * SCALE, y * SCALE, SCALE, SCALE);
        }
      }
    }
  }
  
  color getIntensityColor(float intensity) {
    if(intensity < medianIntensity)
      return lerpColor(color(0, 0, 255, heatMapOpacity), color(255, 255, 0, heatMapOpacity), map(intensity, 1, medianIntensity, 0, 1));
    else
      return lerpColor(color(255, 255, 0, heatMapOpacity), color(255, 0, 0, heatMapOpacity), map(intensity, medianIntensity, medianIntensity * 4, 0, 1));

  }
  
  //color getIntensityColor(float intensity) { // n0thing -> blue (quartar median) -> yellow (half median) -> orange (median) -> red (double median)
  //  if(intensity < medianIntensity / 4)
  //    return lerpColor(color(0, 0, 0, 0), color(0, 0, 255, heatMapOpacity), map(intensity, 1, medianIntensity / 4, 0, 1));
  //  else if (intensity < medianIntensity / 2)
  //    return lerpColor(color(0, 0, 255, heatMapOpacity), color(255, 255, 0, heatMapOpacity), map(intensity, medianIntensity / 4, medianIntensity / 2, 0, 1));
  //  else if (intensity < medianIntensity)
  //    return lerpColor(color(255, 255, 0, heatMapOpacity), color(255, 110, 0, heatMapOpacity), map(intensity, medianIntensity / 2, medianIntensity, 0, 1));
  //  else
  //    return lerpColor(color(255, 110, 0, heatMapOpacity), color(255, 0, 0, heatMapOpacity), map(intensity, medianIntensity, medianIntensity * 5, 0, 1));

  //}
  float mapX(float lon) {
    return map(lon, -180, 180, 0, width);
  }

  float mapY(float lat) {
    return map(lat, 90, -90, 0, height);
  }
  
  void mouseWheel(MouseEvent event) {
    float zoomFactor = 1.05;
    float e = event.getCount();
  
    // Calculate zoom towards the mouse position
    float newScale = (e < 0) ? scaleFactor * zoomFactor : scaleFactor / zoomFactor;
    if(newScale >= 1) {
      float dx = mouseX - offsetX;
      float dy = mouseY - offsetY;
    
      // Adjust offset to keep the zoom centered on the mouse
      offsetX -= (newScale - scaleFactor) * dx / scaleFactor;
      offsetY -= (newScale - scaleFactor) * dy / scaleFactor;
    
      scaleFactor = newScale;
    }
    
  }
  
  // Handle mouse drag for panning
  void mousePressed() {
    startX = mouseX - offsetX;
    startY = mouseY - offsetY;
    isDragging = true;
  }
  
  void mouseDragged() {
    if (isDragging) {
      float newoffsetX = mouseX - startX;
      float newoffsetY = mouseY - startY;
       
            
      float zoomedWidth = width * scaleFactor;
      float zoomedHeight = height * scaleFactor;
    
      // Clamp offsetX and offsetY so edges stay within the canvas
      offsetX = constrain(newoffsetX, width - zoomedWidth, 0);
      offsetY = constrain(newoffsetY, height - zoomedHeight, 0);

    }
  }
  
  void mouseReleased() {
    isDragging = false;
  }
  
}
