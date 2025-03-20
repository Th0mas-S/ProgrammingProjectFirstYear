import processing.data.*;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Collections;

HashMap<String, Integer> flightCounts;
HashMap<String, Integer> cancellations;
Table flights;
ArrayList<String> airports;
String selectedAirport = null;
int maxFlights = 0;
int currentScreen = 0; // 0: Bar Chart Screen, 1: Pie Chart Screen

// Variables for slider (for bar chart screen)
float offsetX = 0;  // Horizontal offset for drawing bars
float totalBarAreaWidth = 0; // Total width needed for all bars
// Slider track parameters
float sliderX, sliderY, sliderW, sliderH;
float handleWidth = 30;
boolean draggingSlider = false;

void setup() {
  fullScreen();  // Increase canvas size for more vertical space
  flights = loadTable("flights.csv", "header");

  flightCounts = new HashMap<String, Integer>();
  cancellations = new HashMap<String, Integer>();
  
  // Aggregate data from every row in the CSV
  for (TableRow row : flights.rows()) {
    String origin = row.getString("ORIGIN");
    boolean cancelled = row.getFloat("CANCELLED") == 1;
    
    // Count total flights per airport
    flightCounts.put(origin, flightCounts.getOrDefault(origin, 0) + 1);
    
    // Count cancellations per airport
    if (cancelled) {
      cancellations.put(origin, cancellations.getOrDefault(origin, 0) + 1);
    }
  }
  
  // Create a sorted list of airports (alphabetical order)
  airports = new ArrayList<String>(flightCounts.keySet());
  Collections.sort(airports);
  
  // Determine the maximum flight count among all airports
  for (String airport : airports) {
    int count = flightCounts.get(airport);
    if (count > maxFlights) {
      maxFlights = count;
    }
  }
  
  // Setup slider track parameters (for the bar chart screen)
  sliderX = 100;              // same as bar chart startX
  sliderY = height - 40;      // vertical position of the slider
  sliderW = width - 150;      // width available for the slider
  sliderH = 20;
  
  // Use continuous redraw for smooth slider interaction.
}

void draw() {
  background(240);
  
  if (currentScreen == 0) {
    drawBarChart();
    drawSlider();
  } else if (currentScreen == 1) {
    drawPieChartScreen();
  }
}

// Draws an enlarged bar chart for all airports with horizontal scrolling
void drawBarChart() {
  fill(0);
  textSize(20);
  textAlign(CENTER);
  text("Number of Flights Per Airport", width/2, 30);
  
  int barWidth = 50;
  int spacing = 30;
  int startX = 100;      // left margin for bars
  int bottomMargin = 100;
  int chartHeight = height - 150;  // use most of the canvas height
  
  // Calculate the total width needed for all bars
  totalBarAreaWidth = startX + airports.size() * (barWidth + spacing);
  
  // Draw each bar using the horizontal offset (offsetX) controlled by the slider
  for (int i = 0; i < airports.size(); i++) {
    String airport = airports.get(i);
    int count = flightCounts.get(airport);
    float barHeight = map(count, 0, maxFlights, 0, chartHeight);
    // x position shifted by offsetX
    int x = startX + i * (barWidth + spacing) - int(offsetX);
    int y = height - int(barHeight) - bottomMargin;
    
    // Only draw bars that are at least partially visible on screen
    if (x + barWidth >= startX && x <= width) {
      fill(0, 100, 255);
      rect(x, y, barWidth, int(barHeight));
      
      fill(0);
      textSize(14);
      text(airport, x + barWidth/2, height - bottomMargin + 20);
      text(count, x + barWidth/2, y - 5);
    }
  }
}

// Draws a slider below the bar chart to scroll horizontally
void drawSlider() {
  // Determine the maximum offset (if bars exceed the visible area)
  int startX = 100;
  float visibleWidth = width - startX - 50;
  float maxOffset = max(0, totalBarAreaWidth - visibleWidth);
  
  // Draw slider track
  fill(200);
  rect(sliderX, sliderY, sliderW, sliderH);
  
  // Calculate handle position based on offsetX
  float handleX = sliderX;
  if (maxOffset > 0) {
    handleX = sliderX + (offsetX / maxOffset) * (sliderW - handleWidth);
  }
  
  // Draw slider handle
  fill(100);
  rect(handleX, sliderY, handleWidth, sliderH);
}

// Draws the pie chart screen for the selected airport
void drawPieChartScreen() {
  // Draw a back button at the top-left
  fill(200);
  rect(20, 20, 80, 40);
  fill(0);
  textSize(16);
  textAlign(CENTER, CENTER);
  text("Back", 20 + 40, 20 + 20);
  
  // Draw the pie chart in the center if an airport is selected
  if (selectedAirport != null) {
    drawPieChart(selectedAirport, width/2, height/2, 300);
  }
}

// Draws a pie chart for a given airport, showing cancelled vs. non-cancelled flights
void drawPieChart(String airport, int centerX, int centerY, int diameter) {
  int total = flightCounts.get(airport);
  int canceled = cancellations.containsKey(airport) ? cancellations.get(airport) : 0;
  int nonCanceled = total - canceled;
  
  // Calculate the angle for the cancelled segment
  float angleCancelled = map(canceled, 0, total, 0, TWO_PI);
  
  // Draw the cancelled segment (red)
  fill(255, 0, 0);
  arc(centerX, centerY, diameter, diameter, 0, angleCancelled);
  
  // Draw the non-cancelled segment (green)
  fill(0, 255, 0);
  arc(centerX, centerY, diameter, diameter, angleCancelled, TWO_PI);
  
  // Add text labels to describe the pie chart
  fill(0);
  textSize(20);
  textAlign(CENTER);
  text("Airport: " + airport, centerX, centerY + diameter/2 + 30);
  textSize(16);
  text("Cancelled: " + canceled, centerX, centerY + diameter/2 + 55);
  text("Not Cancelled: " + nonCanceled, centerX, centerY + diameter/2 + 80);
}

// Handle mouse pressed events for interactivity
void mousePressed() {
  if (currentScreen == 0) {  
    // Check if the click is within the slider area
    if (mouseX >= sliderX && mouseX <= sliderX + sliderW && mouseY >= sliderY && mouseY <= sliderY + sliderH) {
      draggingSlider = true;
    } else {
      // Check if a bar was clicked in the bar chart
      int barWidth = 50;
      int spacing = 30;
      int startX = 100;
      int bottomMargin = 100;
      int chartHeight = height - 150;
      
      for (int i = 0; i < airports.size(); i++) {
        String airport = airports.get(i);
        int count = flightCounts.get(airport);
        float barHeight = map(count, 0, maxFlights, 0, chartHeight);
        int x = startX + i * (barWidth + spacing) - int(offsetX);
        int y = height - int(barHeight) - bottomMargin;
        
        // Increase clickable area to at least 50 pixels high
        int clickableHeight = max(int(barHeight), 50);
        
        if (mouseX >= x && mouseX <= x + barWidth && mouseY >= y && mouseY <= y + clickableHeight) {
          selectedAirport = airport;
          currentScreen = 1;  // Switch to pie chart screen
          break;
        }
      }
    }
  } else if (currentScreen == 1) {
    // Check if the back button was clicked (located at 20,20 to 100,60)
    if (mouseX >= 20 && mouseX <= 100 && mouseY >= 20 && mouseY <= 60) {
      currentScreen = 0;  // Return to bar chart screen
      selectedAirport = null;
    }
  }
}

// Handle mouse dragged events (for slider movement)
void mouseDragged() {
  if (draggingSlider && currentScreen == 0) {
    int startX = 100;
    float visibleWidth = width - startX - 50;
    float maxOffset = max(0, totalBarAreaWidth - visibleWidth);
    
    // Calculate new handle position within the slider track
    float sliderPos = constrain(mouseX - sliderX, 0, sliderW - handleWidth);
    if (maxOffset > 0) {
      offsetX = (sliderPos / (sliderW - handleWidth)) * maxOffset;
    } else {
      offsetX = 0;
    }
  }
}

// Handle mouse released events
void mouseReleased() {
  draggingSlider = false;
}
