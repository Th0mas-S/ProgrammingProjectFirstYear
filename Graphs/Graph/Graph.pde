import processing.data.Table;
import processing.data.TableRow;
import java.util.Collections;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Map;
import java.util.Calendar; // For calendar display

// --- Screen Mode Constants ---
final int SCREEN_SELECTION = 0;
final int SCREEN_OVERVIEW = 1;
final int SCREEN_TRAFFIC_DETAIL = 2;
final int SCREEN_DESTINATION_DETAIL = 3;
final int SCREEN_DELAY_DIST_DETAIL = 4;
final int SCREEN_CANCELLATION_DETAIL = 5;

// --- Global Variables ---
int screenMode = SCREEN_SELECTION;
AirportSelector airportSelector;
GraphScreen graphScreen;
ProcessData processData;
String[] airports; // Airport list generated from CSV

// Global mapping for airport codes to full names (loaded from CSV)
HashMap<String, String> airportNamesMap = new HashMap<String, String>();

// --- Graph Quadrant Layout (recalculated in draw) ---
float overviewMarginX, overviewMarginY, overviewQuadrantWidth, overviewQuadrantHeight, overviewGapX, overviewGapY;
float q1x, q1y, q1w, q1h;
float q2x, q2y, q2w, q2h;
float q3x, q3y, q3w, q3h;
float q4x, q4y, q4w, q4h;

void setup() {
<<<<<<< Updated upstream
  size(800, 600);
  textFont(createFont("Arial", 18)); // Base font
  
  // Load CSV data
  processData = new ProcessData("flight_data_2017.csv"); 
=======
  size(1920, 1055, P3D);
  textFont(createFont("Arial", 18));

  // Load airport names from CSV (ensure file is in data folder)
  Table airportInfoTable = null;
  try {
    // Ensure the CSV file has "IATA Code" and "Airport Name" columns
    airportInfoTable = loadTable("airport_data.csv", "header,csv");
    if (airportInfoTable != null) {
      println("Loaded " + airportInfoTable.getRowCount() + " rows from airport_data.csv");
      for (TableRow row : airportInfoTable.rows()) {
        // Use getString(columnName) and check for null
        String iataCode = row.getString("IATA Code");
        String airportName = row.getString("Airport Name");
        if (iataCode != null && !iataCode.isEmpty() && airportName != null && !airportName.isEmpty()) { // Added null/empty checks
          airportNamesMap.put(iataCode.trim(), airportName.trim());
        } else {
           // println("Warning: Skipping row with missing IATA Code or Airport Name in airport_data.csv");
        }
      }
      println("Populated airportNamesMap with " + airportNamesMap.size() + " entries.");
    } else {
       println("Warning: airport_data.csv loaded but returned null or empty table.");
    }
  } catch (Exception e) {
    println("Error loading airport_data.csv: " + e.getMessage());
    println("Airport names will not be displayed. Ensure 'airport_data.csv' is in the data folder and has 'IATA Code' and 'Airport Name' columns.");
  }

  // Load flight data
  processData = new ProcessData("flight_data_2017.csv");
>>>>>>> Stashed changes
  if (processData.table == null) {
    println("Error: flight_data_2017.csv not loaded. Check file in data folder.");
    exit();
  }

  airports = processData.getUniqueAirports();
  if (airports.length == 0) {
     println("Error: No unique airports found in flight data. Check CSV format.");
     exit();
  }
  airportSelector = new AirportSelector(airports);
}

void draw() {
  // Recalculate layout based on fixed size 1920x1055
  overviewMarginX = width * 0.02;
  overviewMarginY = height * 0.06;
  overviewGapX = width * 0.02;
  overviewGapY = height * 0.04;
  overviewQuadrantWidth = (width - 2 * overviewMarginX - overviewGapX) / 2; // Adjusted calculation
  overviewQuadrantHeight = (height - overviewMarginY - (height * 0.06) - overviewGapY) / 2; // Adjusted calculation

  // Define quadrant positions explicitly
  q1x = overviewMarginX;
  q1y = overviewMarginY + (height * 0.04);
  q1w = overviewQuadrantWidth;
  q1h = overviewQuadrantHeight;

  q2x = q1x + q1w + overviewGapX;
  q2y = q1y;
  q2w = overviewQuadrantWidth;
  q2h = overviewQuadrantHeight;

  q3x = overviewMarginX;
  q3y = q1y + q1h + overviewGapY;
  q3w = overviewQuadrantWidth;
  q3h = overviewQuadrantHeight;

  q4x = q2x;
  q4y = q3y;
  q4w = overviewQuadrantWidth;
  q4h = overviewQuadrantHeight;


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
    case SCREEN_DELAY_DIST_DETAIL:
      if (graphScreen != null) graphScreen.displayDelayDistributionDetail();
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
    case SCREEN_TRAFFIC_DETAIL:
    case SCREEN_DESTINATION_DETAIL:
    case SCREEN_DELAY_DIST_DETAIL:
    case SCREEN_CANCELLATION_DETAIL:
      // Back button (positioned relative to screen)
      // Check Back button first, as it's always top-left
      float backButtonWidth = width * 0.07; // Area for back button click
      float backButtonHeight = height * 0.05;
       if (mouseX > width * 0.01 && mouseX < width * 0.01 + backButtonWidth && mouseY > height * 0.01 && mouseY < height * 0.01 + backButtonHeight) {
        if (screenMode == SCREEN_OVERVIEW) {
          screenMode = SCREEN_SELECTION;
          graphScreen = null;
          // Reset selector state
          airportSelector.searchQuery = "";
          airportSelector.sliderPos = 0;
          airportSelector.topIndex = 0;
          airportSelector.searchActive = false;
        } else {
          screenMode = SCREEN_OVERVIEW; // Go back to overview from detail
        }
        return; // Consume click
      }

      // Calendar interaction (Only check if in Overview mode)
      // *** REQUIREMENT #4: Check calendar ONLY in overview ***
      if (screenMode == SCREEN_OVERVIEW && graphScreen != null && graphScreen.calendar != null) {
          if (graphScreen.calendar.isMouseOver(mouseX, mouseY) && graphScreen.calendar.mousePressed()) {
             String newDate = graphScreen.calendar.getSelectedDate();
             if (!newDate.equals(graphScreen.selectedDate)) {
                graphScreen.selectedDate = newDate;
                println("Date updated: " + graphScreen.selectedDate);
                // Data might need reprocessing or graphs might update automatically based on selectedDate usage
             }
             return; // Consume click if it was on the calendar
          }
      }

      // In overview, check which quadrant was clicked (if not clicking back button or calendar)
      if (screenMode == SCREEN_OVERVIEW) {
        if (mouseX > q1x && mouseX < q1x + q1w && mouseY > q1y && mouseY < q1y + q1h) {
          screenMode = SCREEN_TRAFFIC_DETAIL;
        } else if (mouseX > q2x && mouseX < q2x + q2w && mouseY > q2y && mouseY < q2y + q2h) {
          screenMode = SCREEN_DESTINATION_DETAIL;
        } else if (mouseX > q3x && mouseX < q3x + q3w && mouseY > q3y && mouseY < q3y + q3h) {
          screenMode = SCREEN_DELAY_DIST_DETAIL;
        } else if (mouseX > q4x && mouseX < q4x + q4w && mouseY > q4y && mouseY < q4y + q4h) {
          screenMode = SCREEN_CANCELLATION_DETAIL;
        }
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

void mouseWheel(processing.event.MouseEvent event) {
  if (screenMode == SCREEN_SELECTION) {
    float e = event.getCount();
    airportSelector.updateScrollIndex(e);
  }
}

void keyTyped() {
  if (screenMode == SCREEN_SELECTION && airportSelector != null && airportSelector.searchActive) {
    airportSelector.updateSearch("" + key);
  }
}

void keyPressed() {
  if (keyCode == BACKSPACE) {
    if (screenMode == SCREEN_SELECTION && airportSelector != null && airportSelector.searchActive) {
      airportSelector.updateSearch("\b");
    }
  } else if (keyCode == ENTER || keyCode == RETURN) {
    if (screenMode == SCREEN_SELECTION && airportSelector != null && airportSelector.searchActive) {
      airportSelector.updateSearch("\n");
    }
  } else if (keyCode == ESC) {
     key = 0; // prevent ESC from closing sketch
     if (screenMode == SCREEN_SELECTION && airportSelector != null) {
        airportSelector.searchActive = false;
     }
  }
}


// Helper: Draws a semi-transparent header with title and description (for overview mode).
void drawGraphHeaderDesc(float x, float y, float w, String title, String description) {
  float headerHeight = 50;
  fill(0, 0, 0, 150); // semi-transparent black
  noStroke();
  rect(x, y, w, headerHeight);
  fill(255);
  textAlign(CENTER, TOP);
  textSize(20); // Adjusted size
  text(title, x + w/2, y + 5);
  textSize(14); // Adjusted size
  text(description, x + w/2, y + 30);
}

// Helper: Draws a header with just a title, airport name, and date (for detailed view).
void drawGraphHeader(float x, float y, float w, String title) {
  float headerHeight = 50;
  fill(0, 0, 0, 180); // Slightly darker background for detail view
  noStroke();
  // Draw header background across the top more definitively
  rect(0, 0, width, headerHeight + (height * 0.02)); // Extend slightly down from top margin
  // Back Button (drawn on top of header background)
   drawBackButtonInternal(headerHeight + (height * 0.02)); // Pass header bottom y

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(22); // Adjusted size for potentially longer title
  text(title, width/2, (headerHeight + (height * 0.02)) / 2); // Center title in the header area
}

// Internal helper to draw back button, called by detailed views and overview
void drawBackButtonInternal(float headerBottomY) {
    float buttonHeight = 35;
    float buttonWidth = 80;
    float buttonX = width * 0.015;
    // For detailed view, center vertically in header. For overview, position near top.
    float buttonY = (screenMode == SCREEN_OVERVIEW) ? height * 0.01 : (headerBottomY - buttonHeight) / 2;

    boolean hover = (mouseX > buttonX && mouseX < buttonX + buttonWidth && mouseY > buttonY && mouseY < buttonY + buttonHeight);

    if (hover) {
       fill(120, 170, 255); // Highlight color
       stroke(50, 80, 150);
       strokeWeight(1);
    } else {
       fill(180); // Default color
       noStroke();
    }
    rect(buttonX, buttonY, buttonWidth, buttonHeight, 5);

    fill(0);
    textSize(16); // Adjusted size
    textAlign(CENTER, CENTER);
    text("Back", buttonX + buttonWidth/2, buttonY + buttonHeight/2);
    noStroke(); // Reset stroke
}
