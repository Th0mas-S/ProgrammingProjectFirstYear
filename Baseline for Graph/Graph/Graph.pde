import processing.data.Table;
import processing.data.TableRow;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap; // Added explicit import
import java.util.ArrayList; // Added explicit import
import java.util.Map; // <--- ADD THIS LINE
import java.util.Arrays; // <--- ADD THIS LINE

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
ProccessData processData; // Our data processor

// Sample airport list (extend as needed)
String[] airports = {
  "LAX", "SEA", "SFO", "ATL", "JFK",
  "ORD", "DFW", "DEN", "MIA", "BOS",
  "PHX", "CLT", "LAS", "PHL", "IAH"
  // Add more if your data includes them
};

// --- Define Graph Quadrant Areas (for click detection) ---
float overviewMarginX = 20;
float overviewMarginY = 60;
float overviewQuadrantWidth = 360;
float overviewQuadrantHeight = 220;
float overviewGapX = 40; // Gap between left and right columns
float overviewGapY = 20; // Gap between top and bottom rows

// Quadrant 1 (Top Left - Traffic)
float q1x = overviewMarginX;
float q1y = overviewMarginY;
float q1w = overviewQuadrantWidth;
float q1h = overviewQuadrantHeight;
// Quadrant 2 (Top Right - Destination)
float q2x = q1x + q1w + overviewGapX;
float q2y = overviewMarginY;
float q2w = overviewQuadrantWidth;
float q2h = overviewQuadrantHeight;
// Quadrant 3 (Bottom Left - Delay)
float q3x = overviewMarginX;
float q3y = q1y + q1h + overviewGapY;
float q3w = overviewQuadrantWidth;
float q3h = overviewQuadrantHeight;
// Quadrant 4 (Bottom Right - Cancellation)
float q4x = q2x;
float q4y = q3y;
float q4w = overviewQuadrantWidth;
float q4h = overviewQuadrantHeight;


void setup() {
  size(800, 600);
  // Set a base font size, can be overridden locally
  textFont(createFont("Arial", 18)); // Slightly larger base font

  // Create the airport selection screen - it now calculates its own centered position
  airportSelector = new AirportSelector(airports);

  // Load the CSV data once.
  processData = new ProccessData("flight_data_2017.csv"); // Make sure this file is in a 'data' subfolder
  if (processData.table == null) {
     println("Error: Could not load flight data CSV. Make sure 'flight_data_2017.csv' is in the 'data' folder.");
     exit(); // Stop the sketch if data isn't loaded
  }
}

void draw() {
  background(245); // Slightly off-white background

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
      // Check if an airport was clicked.
      String selected = airportSelector.handleMousePressed(mouseX, mouseY);
      // Also check for slider clicks.
      airportSelector.handleSliderMousePressed(mouseX, mouseY); // Renamed for clarity
      if (selected != null) {
        // Process data for the selected airport and switch screens.
        processData.process(selected); // Calculate overall stats (optional use)
        graphScreen = new GraphScreen(selected, processData); // Create graph screen instance
        screenMode = SCREEN_OVERVIEW; // Go to overview screen
      }
      break;

    case SCREEN_OVERVIEW:
      // Check for back button click (to selection)
      if (mouseX > 10 && mouseX < 90 && mouseY > 10 && mouseY < 40) {
        screenMode = SCREEN_SELECTION;
        graphScreen = null; // Release graph screen resources if desired
        return; // Prevent checking graph clicks if back button was hit
      }
      // Check for clicks within graph quadrants
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

    // Handle "Back" button for all detail screens
    case SCREEN_TRAFFIC_DETAIL:
    case SCREEN_DESTINATION_DETAIL:
    case SCREEN_DELAY_DETAIL:
    case SCREEN_CANCELLATION_DETAIL:
      if (mouseX > 10 && mouseX < 90 && mouseY > 10 && mouseY < 40) {
        screenMode = SCREEN_OVERVIEW; // Go back to overview
      }
      break;
  }
}

void mouseDragged() {
  if (screenMode == SCREEN_SELECTION) {
    airportSelector.handleSliderMouseDragged(mouseX, mouseY); // Renamed for clarity
  }
}

void mouseReleased() {
  if (screenMode == SCREEN_SELECTION) {
    airportSelector.handleSliderMouseReleased(); // Renamed for clarity
  }
}
