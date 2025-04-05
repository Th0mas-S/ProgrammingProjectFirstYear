// Main.pde
// Global variables, screen switching, and main loop

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.text.Normalizer;

final int SCREEN_SELECTION = 0;
final int SCREEN_OVERVIEW = 1;
int screenMode = SCREEN_SELECTION;

AirportSelector airportSelector;
GraphScreen graphScreen;
ProcessData processData;
String[] airports;
ArrayList<String> airportCode = new ArrayList<String>();
ArrayList<String> airportName = new ArrayList<String>();
PFont unicodeFont; // retained from your original code

boolean backspaceHeld = false;
int backspaceHoldStart = 0;
int backspaceLastDelete = 0;
int initialDelay = 300;
int repeatRate = 50;

// Global airportLookup maps three-letter codes to full descriptive names.
HashMap<String, String> airportLookup = new HashMap<String, String>();

// Interface for looking up airport names
interface StringLookup {
  String get(String code);
}

void setup() {
  size(1920, 1055, P3D); // Use your original size and renderer
  
  // Load airport dictionary from airport_data.csv
  loadAirportDictionary();
  
  // Load flight data from flight_data_2017.csv
  processData = new ProcessData("flight_data_2017.csv");
  airports = processData.getUniqueAirports();
  
  // Create a lookup that returns a friendly name (if available)
  StringLookup airportNameLookup = new StringLookup() {
    public String get(String code) {
      if (airportLookup.containsKey(code)) {
        return airportLookup.get(code);
      }
      return code;
    }
  };
  
  airportSelector = new AirportSelector(airports, airportNameLookup);
}

void draw() {
  background(245);
  
  if (screenMode == SCREEN_SELECTION) {
    airportSelector.display();
    if (backspaceHeld && airportSelector.searchFocused) {
      int now = millis();
      if (now - backspaceHoldStart > initialDelay && now - backspaceLastDelete > repeatRate) {
        handleBackspace();
        backspaceLastDelete = now;
      }
    }
  } else if (screenMode == SCREEN_OVERVIEW) {
    if (graphScreen != null) {
      graphScreen.display();
    }
  }
}

void mousePressed() {
  if (screenMode == SCREEN_SELECTION) {
    String selected = airportSelector.handleMousePressed(mouseX, mouseY);
    airportSelector.handleSliderMousePressed(mouseX, mouseY);
    if (selected != null) {
      processData.process(selected);
      graphScreen = new GraphScreen(selected, processData);
      screenMode = SCREEN_OVERVIEW;
    }
  } else if (screenMode == SCREEN_OVERVIEW) {
    // Delegate to GraphScreen's custom mousePressed method
    if (graphScreen != null) {
      graphScreen.mousePressedMenu(mouseX, mouseY);
    }
  }
}

void mouseDragged() {
  if (screenMode == SCREEN_SELECTION) {
    airportSelector.handleSliderMouseDragged(mouseX, mouseY);
    airportSelector.handleMouseDraggedInSearch(mouseX);
  }
}

void mouseReleased() {
  if (screenMode == SCREEN_SELECTION) {
    airportSelector.handleSliderMouseReleased();
  }
}

void mouseWheel(MouseEvent event) {
  if (screenMode == SCREEN_SELECTION) {
    float e = event.getCount();
    String[] filtered = airportSelector.getFilteredAirports();
    int maxTopIndex = max(0, filtered.length - airportSelector.itemsToShow);
    airportSelector.topIndex += (int)e;
    airportSelector.topIndex = constrain(airportSelector.topIndex, 0, maxTopIndex);
    airportSelector.sliderPos = (maxTopIndex == 0) ? 0 : airportSelector.topIndex / (float)maxTopIndex;
  }
}

void keyPressed() {
  if (screenMode == SCREEN_SELECTION && airportSelector.searchFocused) {
    int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
    int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
    if (key == BACKSPACE) {
      backspaceHeld = true;
      backspaceHoldStart = millis();
      backspaceLastDelete = millis();
      handleBackspace();
    } else if (key == DELETE) {
      if (airportSelector.hasSelection()) {
        airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) + airportSelector.searchQuery.substring(selEnd);
        airportSelector.caretIndex = selStart;
        airportSelector.clearSelection();
        airportSelector.resetScroll();
      } else if (airportSelector.caretIndex < airportSelector.searchQuery.length()) {
        airportSelector.searchQuery = airportSelector.searchQuery.substring(0, airportSelector.caretIndex) + airportSelector.searchQuery.substring(airportSelector.caretIndex + 1);
        airportSelector.clearSelection();
        airportSelector.resetScroll();
      }
    } else if (key == CODED) {
      if (keyCode == LEFT && airportSelector.caretIndex > 0) {
        airportSelector.caretIndex--;
        airportSelector.clearSelection();
      } else if (keyCode == RIGHT && airportSelector.caretIndex < airportSelector.searchQuery.length()) {
        airportSelector.caretIndex++;
        airportSelector.clearSelection();
      }
    } else if (key == ENTER || key == RETURN) {
      // Optionally confirm the search
    } else {
      char c = key;
      if (airportSelector.hasSelection()) {
        airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) + c + airportSelector.searchQuery.substring(selEnd);
        airportSelector.caretIndex = selStart + 1;
        airportSelector.clearSelection();
      } else {
        airportSelector.searchQuery = airportSelector.searchQuery.substring(0, airportSelector.caretIndex) + c + airportSelector.searchQuery.substring(airportSelector.caretIndex);
        airportSelector.caretIndex++;
        airportSelector.clearSelection();
      }
      airportSelector.resetScroll();
    }
  } else if (screenMode == SCREEN_OVERVIEW && graphScreen != null) {
    // Add key controls for detailed graph view if desired.
  }
}

void keyReleased() {
  if (key == BACKSPACE) {
    backspaceHeld = false;
  }
}

void handleBackspace() {
  int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
  int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
  if (airportSelector.hasSelection()) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) + airportSelector.searchQuery.substring(selEnd);
    airportSelector.caretIndex = selStart;
    airportSelector.clearSelection();
    airportSelector.resetScroll();
  } else if (airportSelector.caretIndex > 0) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, airportSelector.caretIndex - 1) + airportSelector.searchQuery.substring(airportSelector.caretIndex);
    airportSelector.caretIndex--;
    airportSelector.clearSelection();
    airportSelector.resetScroll();
  }
}

// ------------------------------------------------------------------
// Load Airport Dictionary from airport_data.csv
// Expected CSV columns (from your screenshot):
// Rank, Airport Name, IATA Code, City, Country, Passenger, latitude, longitude, flights, updated flights
// We use: Airport Name, IATA Code, City, Country
// ------------------------------------------------------------------
void loadAirportDictionary() {
  String[] rows = loadStrings("airport_data.csv");
  if (rows == null) {
    println("Could not find 'airport_data.csv' in the data folder.");
    return;
  }
  // Assume first row is header; start from row 1.
  for (int i = 1; i < rows.length; i++) {
    String[] cols = split(rows[i], ',');
    if (cols.length >= 5) {
      String airportName = cols[1].trim();
      String iataCode    = cols[2].trim();
      String city        = cols[3].trim();
      String country     = cols[4].trim();
      String label = airportName + " (" + city + ", " + country + ")";
      airportLookup.put(iataCode, label);
    }
  }
  println("Loaded airport_data.csv. Dictionary size = " + airportLookup.size());
}
