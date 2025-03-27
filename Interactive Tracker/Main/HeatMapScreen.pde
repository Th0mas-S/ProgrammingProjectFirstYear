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
  float flightDistance;
  String scheduledArrival;
  String actualArrival;
  boolean diverted;
  boolean cancelled;
  boolean mouseOver;
  
  
  Flight(String date, String airlineCode, String flightNumber, String origin, String destination, String scheduledDeparture, String actualDeparture, int departureDelay, float flightDistance, String scheduledArrival, String actualArrival, boolean diverted, boolean cancelled) {
    this.date = date;
    this.airlineCode = airlineCode;                            //setup...
    this.flightNumber = flightNumber;
    this.origin = origin;
    this.destination = destination;
    this.scheduledDeparture = scheduledDeparture;
    this.actualDeparture = actualDeparture;
    this.departureDelay = departureDelay;
    this.flightDistance = flightDistance;
    this.scheduledArrival = scheduledArrival;
    this.actualArrival = actualArrival;
    this.diverted = diverted;
    this.cancelled = cancelled;
  }
  

  void drawData(int x, int y, int textSize){
      text(date, x-5, y);
      text("   " + airlineCode + flightNumber, x+(textSize*4.791), y);
      text("    " + origin + " -> " + destination, x+(textSize*8.958), y);
      text("    Scheduled: " + scheduledDeparture + " - " + scheduledArrival, x+(textSize*15), y);
      text("    Actual: " + actualDeparture + " - " + actualArrival, x+(textSize*26.25), y);
      text("    Delay: " + departureDelay + " min ", x+(textSize*35.833), y);
      text("    Diverted: " + diverted, x+(textSize*43.333), y);
      text("    Cancelled: " + cancelled, x+(textSize*50.833), y);
      text("    Distance: " + flightDistance + " km", x+(textSize*58.75), y);
    
    
      if(mouseX>x && mouseX<x+width-150 && mouseY>y-textSize && mouseY<y){
        mouseOver = true;
      }
      else mouseOver = false;
  }


}

String convertDate(String dateIn){              //used for initializing flights
  String[] mess = split(dateIn, '-');
  return(mess[2]+"/"+mess[1]+"/"+mess[0]);
}

ArrayList<Flight> flights;  

void loadData(int amountOfRows) { // amount of rows tells me how much data to load, it crashes my computer when i load too much
  String[] rows = loadStrings("flight_data_2017.csv");          //contain all the data for an individual flight
    flights = new ArrayList<Flight>();

  
  for(int i=1; i<20000; i++){
    String[] data = split(rows[i], ',');
   
    String date = convertDate(data[0]);
    String airlineCode = data[2];
    String flightNumber = data[3];
    String origin = data[4];
    String destination = data[5];
    String scheduledDeparture = cropData(data[6]);
    String actualDeparture = cropData(data[8]);
    int departureDelay = int(data[10]);
    float flightDistance = float(data[11]);
    String scheduledArrival = cropData(data[7]);
    String actualArrival = cropData(data[9]);
    boolean diverted = (data[13].equals("TRUE"));
    boolean cancelled = (data[12].equals("TRUE"));

    flights.add( new Flight(date, airlineCode, flightNumber, origin, destination, scheduledDeparture, actualDeparture, departureDelay, flightDistance, scheduledArrival, actualArrival, diverted, cancelled));
  }
  println("flights loaded ("+flights.size()+")");
}


String cropData(String dataIn){                 //used for initializing flights
  if(dataIn.equals("")) return "00:00";
  String[] mess = split(dataIn, ' ');
  return(mess[1]);
}

///////////////////////// JASON CODE END /////////////////////////////////////////////////////

import java.util.List;
import java.util.ArrayList;
import java.util.Collections;
import java.util.concurrent.*;



HashMap<String, Location> loadAirportCoordinates(String filepath) {
  String[] rows = loadStrings(filepath);
  HashMap<String, Location> airportLocations = new HashMap<String, Location>();
  for(int i=1; i<rows.length; i++){
      String[] data = split(rows[i], ',');
      // println(data[2] + " " + data[6] + " " + data[7]);
      airportLocations.put(data[0], new Location(parseFloat(data[1]), parseFloat(data[2])));
  }
  
  return airportLocations;
}

class HeatMapScreen extends Screen {
  
  PImage earthImage;
  HashMap<String, Location> airportLocations;     // probably should make this global seems useful for EarthScreen
  
  final float SCALE = 1; // idk what to call this, this is how big the sqaures are EDIT: sqaure size seems like a good name
  final int heatMapOpacity = 150;
  final int heatMapWidth = (int)(width / SCALE);
  final int heatMapHeight = (int)(height / SCALE);
  int[][] heatMap;
    
  int medianIntensity = 0;
  
  float scaleFactor = 1.0;
  float offsetX = 0;
  float offsetY = 0;
  float startX, startY;
  boolean isDragging = false;
  
  PGraphics heatMapLayer;
  
  CalendarDisplay calendar;

  
  HeatMapScreen() {
    earthImage = loadImage("worldmap.png");
    loadData(400000);
    this.airportLocations = loadAirportCoordinates("coordinate.csv");
    heatMap = new int[heatMapWidth][heatMapHeight];
    
    calendar = new CalendarDisplay();
    
    generateHeatMap();
    
  }
  
  void draw() {
    background(0);

    pushMatrix();
    translate(offsetX, offsetY);
    scale(scaleFactor);

    image(earthImage, 0, 0, width, height);
    image(heatMapLayer, 0, 0);
    popMatrix();
    
    int zoomedMouseX = (int)(((mouseX - offsetX) / scaleFactor) / SCALE);
    int zoomedMouseY = (int)(((mouseY - offsetY) / scaleFactor) / SCALE);
    
    if(heatMap[zoomedMouseX][zoomedMouseY] != 0)
      drawIntensityTab(heatMap[zoomedMouseX][zoomedMouseY]);
    
    drawLegend();
    calendar.display();
      
     float zoomedWidth = width * scaleFactor;
     float zoomedHeight = height * scaleFactor;
    
     // Clamp offsetX and offsetY so edges stay within the canvas
     offsetX = constrain(offsetX, width - zoomedWidth, 0);
     offsetY = constrain(offsetY, height - zoomedHeight, 0);
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
  
  void drawLegend() {
    
    int legendXpos = 0;
    int legendYpos = height - 150;
    
    stroke(0);
    strokeWeight(5);
    fill(255);
    rect(legendXpos, legendYpos, 250, 150);
    
    noStroke();

    fill(0, 0, 255);
    rect(legendXpos + 10, legendYpos + 10, 20, 20);
    fill(0);
    textAlign(CORNER);
    text("reee", legendXpos + 50, legendYpos + 25);
    
    fill(255, 255, 0);
    rect(legendXpos + 10, legendYpos + 40, 20, 20);
    fill(0);
    text("reee", legendXpos + 50, legendYpos + 55); 
    
    fill(255, 0, 0);
    rect(legendXpos + 10, legendYpos + 70, 20, 20);
    fill(0);
    text("reee", legendXpos + 50, legendYpos + 85); 
  }
  
  
  // multi threading is like 10 seconds faster on my laptop
  void generateHeatMap() {
  // Reset heatmap
  for (int x = 0; x < heatMapWidth; x++) {
    for (int y = 0; y < heatMapHeight; y++) {
      heatMap[x][y] = 0;
    }
  }

  // Create a thread pool
  int numThreads = Runtime.getRuntime().availableProcessors(); // Use all CPU cores
  ExecutorService executor = Executors.newFixedThreadPool(numThreads);

  // Submit flight calculations as parallel tasks
  List<Future<Void>> futures = new ArrayList<>();

  for (Flight f : flights) {
    futures.add(executor.submit(() -> {
      processFlight(f);
      return null;
    }));
  }

  // Wait for all tasks to complete
  for (Future<Void> future : futures) {
    try {
      future.get();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  executor.shutdown();
  
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
       
     generateHeatMapLayer();

}

// Flight processing function (each runs on a separate thread)
void processFlight(Flight f) {
  Location src = this.airportLocations.get(f.origin);
  Location des = this.airportLocations.get(f.destination);

  if (src != null && des != null) {
    PVector pointA = LocationTo3D(src.toRadians());
    PVector pointB = LocationTo3D(des.toRadians());
    float angle = acos(pointA.dot(pointB));

    for (float t = 0; t <= 1; t += 0.001) {
      PVector intermediate = PVector.add(
        PVector.mult(pointA, sin((1 - t) * angle)),
        PVector.mult(pointB, sin(t * angle))
      ).div(sin(angle));

      // Convert back to 2D
      float lon = atan2(intermediate.y, intermediate.x);
      float lat = asin(intermediate.z);

      if (!Float.isNaN(degrees(lon)) && !Float.isNaN(degrees(lat))) {
        int x = (int) (mapX(degrees(lon)) / SCALE);
        int y = (int) (mapY(degrees(lat)) / SCALE);

        // Ensure thread-safe update of heatMap
        if (x >= 0 && x < heatMapWidth && y >= 0 && y < heatMapHeight) {
          synchronized (heatMap) { // Protect shared resource
            heatMap[x][y]++;
          }
        }
      }
    }
  }
}
  
  void generateHeatMapLayer() {
    
    heatMapLayer = createGraphics(width, height);
    heatMapLayer.beginDraw();
    heatMapLayer.noStroke();
  

    
    for(int x = 0; x < heatMapWidth; x++) {
      for (int y = 0; y < heatMapHeight; y++) {
        int intesity = heatMap[x][y];
        
        if (intesity > 0) {
          
          color intesityColor = getIntensityColor(intesity);
          heatMapLayer.fill(intesityColor);
          heatMapLayer.rect(x * SCALE, y * SCALE, SCALE, SCALE);
         
        }
      }
    }
    
    heatMapLayer.endDraw();
    
  }
  
  PVector LocationTo3D(Location loc) {
    return new PVector(
      cos(loc.lat) * cos(loc.lon),
      cos(loc.lat) * sin(loc.lon),
      sin(loc.lat)
    );
  }
  
  color getIntensityColor(float intensity) { // n0thing -> blue (quartar median) -> yellow (median) -> orange (median double median) -> red (4 * median)
    if(intensity < medianIntensity / 4)
      return lerpColor(color(0, 0, 0, 0), color(0, 0, 255, heatMapOpacity), map(intensity, 1, medianIntensity / 4, 0, 1));
    else if (intensity < medianIntensity)
      return lerpColor(color(0, 0, 255, heatMapOpacity), color(255, 255, 0, heatMapOpacity), map(intensity, medianIntensity / 4, medianIntensity, 0, 1));
    else if (intensity < medianIntensity * 2)
      return lerpColor(color(255, 255, 0, heatMapOpacity), color(255, 110, 0, heatMapOpacity), map(intensity, medianIntensity, medianIntensity * 2, 0, 1));
    else
      return lerpColor(color(255, 110, 0, heatMapOpacity), color(255, 0, 0, heatMapOpacity), map(intensity, medianIntensity * 2, medianIntensity * 7, 0, 1));

  }
  float mapX(float lon) {
    return map(lon, -180, 180, 0, width);
  }

  float mapY(float lat) {
    return map(lat, 90, -90, 0, height);
  }
  
  void mouseWheel(MouseEvent event) {
    float zoomFactor = 1.25;
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
