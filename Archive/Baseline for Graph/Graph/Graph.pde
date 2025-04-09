import java.util.HashMap;

String selectedAirport = ""; 
String[] airportCodes = {"LAX", "SEA", "SFO", "ATL", "JFK"}; 
int buttonWidth = 120, buttonHeight = 40;

int totalFlights, departedOnTime, delayedFlights, canceledFlights;

void setup() {
  size(800, 600);
  background(255);
  textFont(createFont("Comic Sans MS", 20));
  drawButtons();
}

void draw() {
  if (!selectedAirport.equals("")) {
    drawPieChart();
  }
}

void drawButtons() {
  background(255);
  fill(0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Select an Airport", width/2, 50);

  for (int i = 0; i < airportCodes.length; i++) {
    int x = 60 + (i * (buttonWidth + 20)); 
    int y = 100;
    
    fill(100, 150, 255);
    rect(x, y, buttonWidth, buttonHeight, 10); 
    
    fill(255);
    textSize(18);
    text(airportCodes[i], x + buttonWidth / 2, y + buttonHeight / 2);
  }
}

void drawPieChart() {
  float chartX = width/2;    // Keep horizontal center
  float chartY = height/2 + 100;  // Move down by 100 pixels
  int chartSize = 300;       // Diameter of the pie chart
  background(255);
  drawButtons(); 

  if (totalFlights == 0) {
    fill(255, 0, 0);
    text("No flight data found for " + selectedAirport, chartX, chartY);
    return;
  }

  float onTimeAngle = (float) departedOnTime / totalFlights * TWO_PI;
  float delayedAngle = (float) delayedFlights / totalFlights * TWO_PI;
  float canceledAngle = (float) canceledFlights / totalFlights * TWO_PI;

  color[] sliceColors = {color(0, 255, 0), color(255, 165, 0), color(255, 0, 0)};
  String[] labels = {"On Time", "Delayed", "Canceled"};
  
  float lastAngle = 0;
  int[] counts = {departedOnTime, delayedFlights, canceledFlights};
  float[] angles = {onTimeAngle, delayedAngle, canceledAngle};

  for (int i = 0; i < 3; i++) {
    fill(sliceColors[i]);
  arc(chartX, chartY, chartSize, chartSize, lastAngle, lastAngle + angles[i], PIE);

    float midAngle = lastAngle + angles[i] / 2;
    float labelRadius = 150;
    float x = chartX + labelRadius * cos(midAngle);
    float y = chartY + labelRadius * sin(midAngle);

    fill(0);
    textAlign(CENTER, CENTER);
    textSize(12);
    text(labels[i] + "\n" + nf((counts[i]*100.0/totalFlights), 0, 1) + "%", x, y);

    lastAngle += angles[i];
  }
}

void mousePressed() {
  for (int i = 0; i < airportCodes.length; i++) {
    int x = 100 + (i * (buttonWidth + 20));
    int y = 100;
    
    if (mouseX > x && mouseX < x + buttonWidth && mouseY > y && mouseY < y + buttonHeight) {
      selectedAirport = airportCodes[i];
      println("Selected airport: " + selectedAirport);
      processFlightData();
      redraw();
      break;
    }
  }
}

void processFlightData() {
  // Reset counters
  totalFlights = 0;
  departedOnTime = 0;
  delayedFlights = 0;
  canceledFlights = 0;


  String[] lines = loadStrings("flights.csv");
  if (lines == null) {
    println("Error: Could not load flights.csv");
    return;
  }
  println("Loaded", lines.length, "lines from CSV");

  for (int i = 1; i < lines.length; i++) { 
    String[] cols = split(trim(lines[i]), ',');
    if (cols.length >= 25) { 
      String originAirport = cols[7].replace("\"", "").trim(); 
      String delayStr = cols[11].replace("\"", "").trim();
      String canceledStr = cols[24].replace("\"", "").trim();


      try {
        int departureDelay = int(delayStr);
        int canceled = int(float(canceledStr));
        
        if (originAirport.equalsIgnoreCase(selectedAirport)) {
          totalFlights++;
          
          if (canceled == 1) {
            canceledFlights++;
          } else if (departureDelay > 0) {
            delayedFlights++;
          } else {
            departedOnTime++;
          }
        }
      } catch (NumberFormatException e) {
        println("Skipping invalid data in row", i);
      }
    }
  }  String[] fontList = PFont.list();
  println("Available Fonts:");
  for (String f : fontList) {
    println(f);
  }
  
  println("Processed data for", selectedAirport);
  println("Total flights:", totalFlights);
  println("On time:", departedOnTime);
  println("Delayed:", delayedFlights);
  println("Canceled:", canceledFlights);
}
