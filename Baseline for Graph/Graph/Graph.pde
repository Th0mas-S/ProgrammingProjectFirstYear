import processing.data.Table;
import processing.data.TableRow;

String selectedAirport = ""; 
String[] airportCodes = {"LAX", "SEA", "SFO", "ATL", "JFK"}; 
int buttonWidth = 120, buttonHeight = 40;

int totalFlights, departedOnTime, delayedFlights, cancelledFlights;
boolean dataProcessed = false;

void setup() {
  size(800, 600);
  textFont(createFont("Comic Sans MS", 20));
  drawButtons();
}

void draw() {
  if (!selectedAirport.equals("") && dataProcessed) {
    background(255);
    drawButtons();
    drawPieChart();
  }
}

void drawButtons() {
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
  float chartX = width/2;    
  float chartY = height/2 + 100;  
  int chartSize = 300;       

  if (totalFlights == 0) {
    fill(255, 0, 0);
    text("No flight data found for " + selectedAirport, width/2, height/2);
    return;
  }
  
  // Calculate angles for each segment
  float onTimeAngle = map(departedOnTime, 0, totalFlights, 0, TWO_PI);
  float delayedAngle = map(delayedFlights, 0, totalFlights, 0, TWO_PI);
  float cancelledAngle = map(cancelledFlights, 0, totalFlights, 0, TWO_PI);
  
  float lastAngle = 0;
  
  // On-time flights: green
  fill(0, 255, 0);
  arc(chartX, chartY, chartSize, chartSize, lastAngle, lastAngle + onTimeAngle);
  lastAngle += onTimeAngle;
  
  // Delayed flights: yellow
  fill(255, 255, 0);
  arc(chartX, chartY, chartSize, chartSize, lastAngle, lastAngle + delayedAngle);
  lastAngle += delayedAngle;
  
  // Cancelled flights: red
  fill(255, 0, 0);
  arc(chartX, chartY, chartSize, chartSize, lastAngle, lastAngle + cancelledAngle);
  
  // Display flight counts
  fill(0);
  textSize(16);
  text("Total Flights: " + totalFlights, chartX, chartY + chartSize/2 + 20);
  text("On Time: " + departedOnTime, chartX, chartY + chartSize/2 + 40);
  text("Delayed: " + delayedFlights, chartX, chartY + chartSize/2 + 60);
  text("Cancelled: " + cancelledFlights, chartX, chartY + chartSize/2 + 80);
}

void mousePressed() {
  for (int i = 0; i < airportCodes.length; i++) {
    int x = 60 + (i * (buttonWidth + 20)); 
    int y = 100;
    
    if (mouseX > x && mouseX < x + buttonWidth && mouseY > y && mouseY < y + buttonHeight) {
      selectedAirport = airportCodes[i];
      println("Selected airport: " + selectedAirport);
      processFlightData();
      dataProcessed = true;
      break;
    }
  }
}

void processFlightData() {
  totalFlights = 0;
  departedOnTime = 0;
  delayedFlights = 0;
  cancelledFlights = 0;

  // Load the CSV file from the data folder.
  // Ensure your CSV file is in the sketch's "data" folder.
  Table table = loadTable("flight_data_2017.csv", "header,csv");
  
  for (TableRow row : table.rows()) {
    // Use the correct column names from your CSV
    String origin = row.getString("origin").trim();
    if (!origin.equalsIgnoreCase(selectedAirport)) {
      continue;
    }
    
    totalFlights++;
    
    // Determine if the flight was cancelled
    String cancelledStr = row.getString("cancelled").trim().toLowerCase();
    if (cancelledStr.equals("true") || cancelledStr.equals("1")) {
      cancelledFlights++;
    } else {
      int minutesLate = row.getInt("minutes_late");
      if (minutesLate > 0) {
        delayedFlights++;
      } else {
        departedOnTime++;
      }
    }
  }
  
  println("Processed data for " + selectedAirport);
  println("Total flights: " + totalFlights);
  println("On Time: " + departedOnTime);
  println("Delayed: " + delayedFlights);
  println("Cancelled: " + cancelledFlights);
}
