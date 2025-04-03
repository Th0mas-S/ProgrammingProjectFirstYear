import processing.data.Table;
import processing.data.TableRow;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Map;

// --- Screen Mode Constants ---
final int SCREEN_SELECTION = 0;
final int SCREEN_OVERVIEW = 1;
final int SCREEN_TRAFFIC_DETAIL = 2;
final int SCREEN_DESTINATION_DETAIL = 3;
final int SCREEN_DELAY_DETAIL = 4;
final int SCREEN_CANCELLATION_DETAIL = 5;

// --- Global Variables ---
int screenMode = SCREEN_SELECTION; // Start with selection screen
AirportSelector airportSelector;
GraphScreen graphScreen;
ProcessData processData; // Our data processor
String[] airports;      // This will be generated from CSV data

// --- Define Graph Quadrant Areas (for click detection) ---
float overviewMarginX = 20;
float overviewMarginY = 60;
float overviewQuadrantWidth = 360;
float overviewQuadrantHeight = 220;
float overviewGapX = 40; // Gap between left and right columns
float overviewGapY = 20; // Gap between top and bottom rows

// Quadrant positions
float q1x = overviewMarginX;
float q1y = overviewMarginY;
float q1w = overviewQuadrantWidth;
float q1h = overviewQuadrantHeight;

float q2x = q1x + q1w + overviewGapX;
float q2y = overviewMarginY;
float q2w = overviewQuadrantWidth;
float q2h = overviewQuadrantHeight;

float q3x = overviewMarginX;
float q3y = q1y + q1h + overviewGapY;
float q3w = overviewQuadrantWidth;
float q3h = overviewQuadrantHeight;

float q4x = q2x;
float q4y = q3y;
float q4w = overviewQuadrantWidth;
float q4h = overviewQuadrantHeight;

void setup() {
  size(1920, 1055);
  textFont(createFont("Arial", 18)); // Base font
  
  // Load CSV data
  processData = new ProcessData("flight_data_2017.csv"); 
  if (processData.table == null) {
    println("Error: Could not load flight_data_2017.csv. Make sure it is in the 'data' folder.");
    exit();
  }
  
  // Dynamically generate a sorted unique list of airports from the CSV's "origin" column
  airports = processData.getUniqueAirports();
  
  // Create the airport selection screen using the dynamically generated list
  airportSelector = new AirportSelector(airports);
}

void draw() {
  background(245);
  switch (screenMode) {
    case SCREEN_SELECTION:
      airportSelector.display();
      break;
    case SCREEN_OVERVIEW:
      if (graphScreen != null) graphScreen.displayOverview();
      break;
    case SCREEN_TRAFFIC_DETAIL:
      if (graphScreen != null) graphScreen.displayTrafficDetail();
      break;
    case SCREEN_DESTINATION_DETAIL:
      if (graphScreen != null) graphScreen.displayDestinationDetail();
      break;
    case SCREEN_DELAY_DETAIL:
      if (graphScreen != null) graphScreen.displayDelayDetail();
      break;
    case SCREEN_CANCELLATION_DETAIL:
      if (graphScreen != null) graphScreen.displayCancellationDetail();
      break;
  }
}

void mousePressed() {
  switch (screenMode) {
    case SCREEN_SELECTION:
      String selected = airportSelector.handleMousePressed(mouseX, mouseY);
      airportSelector.handleSliderMousePressed(mouseX, mouseY);
      if (selected != null) {
        processData.process(selected);
        graphScreen = new GraphScreen(selected, processData);
        screenMode = SCREEN_OVERVIEW;
      }
      break;
    case SCREEN_OVERVIEW:
      if (mouseX > 10 && mouseX < 90 && mouseY > 10 && mouseY < 40) {
        screenMode = SCREEN_SELECTION;
        graphScreen = null;
        return;
      }
      if (mouseX > q1x && mouseX < q1x + q1w && mouseY > q1y && mouseY < q1y + q1h) {
        screenMode = SCREEN_TRAFFIC_DETAIL;
      } else if (mouseX > q2x && mouseX < q2x + q2w && mouseY > q2y && mouseY < q2y + q2h) {
        screenMode = SCREEN_DESTINATION_DETAIL;
      } else if (mouseX > q3x && mouseX < q3x + q3w && mouseY > q3y && mouseY < q3y + q3h) {
        screenMode = SCREEN_DELAY_DETAIL;
      } else if (mouseX > q4x && mouseX < q4x + q4w && mouseY > q4y && mouseY < q4y + q4h) {
        screenMode = SCREEN_CANCELLATION_DETAIL;
      }
      break;
    case SCREEN_TRAFFIC_DETAIL:
    case SCREEN_DESTINATION_DETAIL:
    case SCREEN_DELAY_DETAIL:
    case SCREEN_CANCELLATION_DETAIL:
      if (mouseX > 10 && mouseX < 90 && mouseY > 10 && mouseY < 40) {
        screenMode = SCREEN_OVERVIEW;
      }
      break;
  }
}

void mouseDragged() {
  if (screenMode == SCREEN_SELECTION) {
    airportSelector.handleSliderMouseDragged(mouseX, mouseY);
  }
}

void mouseReleased() {
  if (screenMode == SCREEN_SELECTION) {
    airportSelector.handleSliderMouseReleased();
  }
}
