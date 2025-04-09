// --------------------------------------------------------------------------
// Enumerations and Global Declarations
// --------------------------------------------------------------------------

enum SortField {
  CODE,
  NAME,
  COUNTRY
}

enum SortOrder {
  ASC,
  DESC
}

final int SCREEN_SELECTION = 0;
final int SCREEN_OVERVIEW = 1;
int screenMode = SCREEN_SELECTION;

Utility util;
AirportSelectorMenu airportSelector;
GraphSelectorMenu graphScreen;
ProcessData processData;
String[] airports;
PFont unicodeFont;
PImage flighthubLogo;

boolean backspaceHeld = false;
int backspaceHoldStart = 0;
int backspaceLastDelete = 0;
int initialDelay = 300;
int repeatRate = 50;

char heldKey = 0;
boolean keyBeingHeld = false;
int keyHoldStart = 0;
int keyLastRepeat = 0;

HashMap<String, String> airportLookup = new HashMap<String, String>();

interface StringLookup {
  String get(String code);
}

// --------------------------------------------------------------------------
// setup(), draw(), mouse and key events
// --------------------------------------------------------------------------

void setup() {
  size(1920, 1055, P3D);
  
  util = new Utility();
  
  loadAirportDictionary();
  
  processData = new ProcessData("flight_data_2017.csv");
  airports = processData.getUniqueAirports();
  processData.filterDate = null;
  
  flighthubLogo = loadImage("Flighthub Logo.png");
  
  StringLookup airportNameLookup = new StringLookup() {
    public String get(String code) {
      if (airportLookup.containsKey(code)) return airportLookup.get(code);
      return code;
    }
  };

  airportSelector = new AirportSelectorMenu(airports, airportNameLookup, flighthubLogo);
}

void draw() {
  background(0);

  if (screenMode == SCREEN_SELECTION) {
    airportSelector.display();

    if (airportSelector.searchFocused) {
      int now = millis();
      if (backspaceHeld && now - backspaceHoldStart > initialDelay && now - backspaceLastDelete > repeatRate) {
        handleBackspace();
        backspaceLastDelete = now;
      }
      if (keyBeingHeld && heldKey != 0 && heldKey != BACKSPACE) {
        if (now - keyHoldStart > initialDelay && now - keyLastRepeat > repeatRate) {
          insertKeyChar(heldKey);
          keyLastRepeat = now;
        }
      }
    }
  }
  else if (screenMode == SCREEN_OVERVIEW) {
    if (graphScreen != null) graphScreen.display();
  }
}

void mousePressed() {
  if (screenMode == SCREEN_SELECTION) {
    String selected = airportSelector.handleMousePressed(mouseX, mouseY);
    airportSelector.handleSliderMousePressed(mouseX, mouseY);
    
    if (selected != null) {
      processData.filterDate = null;
      if (graphScreen != null) graphScreen.lastSelectedDate = null;
      
      processData.process(selected);
      graphScreen = new GraphSelectorMenu(selected, processData);
      screenMode = SCREEN_OVERVIEW;
    }
  }
  else if (screenMode == SCREEN_OVERVIEW && graphScreen != null) {
    graphScreen.mousePressedMenu(mouseX, mouseY);
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
  // In graph view, handle BACKSPACE as a way to navigate pages.
  if (screenMode == SCREEN_OVERVIEW) {
    if (key == BACKSPACE) {
      // If we're displaying a graph (graphScreen.inMenu == false), go back to the graph selection menu.
      if (!graphScreen.inMenu) {
        graphScreen.inMenu = true;
        return;
      }
      // If we're already in the graph selection menu, go back to airport search.
      else {
        screenMode = SCREEN_SELECTION;
        graphScreen = null;
        return;
      }
    }
  }
  
  if (screenMode == SCREEN_SELECTION && airportSelector.searchFocused) {
    int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
    int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);

    if (key == BACKSPACE) {
      backspaceHeld = true;
      backspaceHoldStart = millis();
      backspaceLastDelete = millis();
      if (keyEvent.isControlDown() || keyEvent.isMetaDown()) {
        handleCtrlBackspace();
      } else {
        handleBackspace();
      }
    }
    else if (key == DELETE) {
      if (airportSelector.hasSelection()) {
        airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                        airportSelector.searchQuery.substring(selEnd);
        airportSelector.caretIndex = selStart;
        airportSelector.clearSelection();
        airportSelector.resetScroll();
      } 
      else if (airportSelector.caretIndex < airportSelector.searchQuery.length()) {
        airportSelector.searchQuery = airportSelector.searchQuery.substring(0, airportSelector.caretIndex) +
                                        airportSelector.searchQuery.substring(airportSelector.caretIndex + 1);
        airportSelector.clearSelection();
        airportSelector.resetScroll();
      }
    }
    else if (key == CODED) {
      if (keyCode == LEFT && airportSelector.caretIndex > 0) {
        airportSelector.caretIndex--;
        airportSelector.clearSelection();
      } 
      else if (keyCode == RIGHT && airportSelector.caretIndex < airportSelector.searchQuery.length()) {
        airportSelector.caretIndex++;
        airportSelector.clearSelection();
      }
    }
    else if (key == ENTER || key == RETURN) {
      // If only one airport remains in the filtered list, select it.
      String[] filteredAirports = airportSelector.getFilteredAirports();
      if (filteredAirports.length == 1) {
        String selected = filteredAirports[0];
        processData.filterDate = null;
        if (graphScreen != null) graphScreen.lastSelectedDate = null;
        processData.process(selected);
        graphScreen = new GraphSelectorMenu(selected, processData);
        screenMode = SCREEN_OVERVIEW;
      }
      // Optionally, handle other ENTER functionality here.
    }
    else {
      char c = key;
      insertKeyChar(c);
      if (key != CODED && key != BACKSPACE && key != DELETE) {
        heldKey = key;
        keyBeingHeld = true;
        keyHoldStart = millis();
        keyLastRepeat = millis();
      }
    }
  }
}

void keyReleased() {
  if (key == BACKSPACE) {
    backspaceHeld = false;
  }
  if (key == heldKey) {
    keyBeingHeld = false;
    heldKey = 0;
  }
}

void insertKeyChar(char c) {
  int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
  int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
  if (airportSelector.hasSelection()) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                    c +
                                    airportSelector.searchQuery.substring(selEnd);
    airportSelector.caretIndex = selStart + 1;
    airportSelector.clearSelection();
  } else {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, airportSelector.caretIndex) +
                                    c +
                                    airportSelector.searchQuery.substring(airportSelector.caretIndex);
    airportSelector.caretIndex++;
    airportSelector.clearSelection();
  }
  airportSelector.resetScroll();
}

void handleBackspace() {
  int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
  int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
  if (airportSelector.hasSelection()) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                    airportSelector.searchQuery.substring(selEnd);
    airportSelector.caretIndex = selStart;
    airportSelector.clearSelection();
    airportSelector.resetScroll();
  } 
  else if (airportSelector.caretIndex > 0) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, airportSelector.caretIndex - 1) +
                                    airportSelector.searchQuery.substring(airportSelector.caretIndex);
    airportSelector.caretIndex--;
    airportSelector.clearSelection();
    airportSelector.resetScroll();
  }
}

void handleCtrlBackspace() {
  int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
  int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
  if (airportSelector.hasSelection()) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                    airportSelector.searchQuery.substring(selEnd);
    airportSelector.caretIndex = selStart;
    airportSelector.clearSelection();
    airportSelector.resetScroll();
    return;
  }
  String text = airportSelector.searchQuery;
  int caret = airportSelector.caretIndex;
  if (caret == 0) return;
  int left = caret;
  while (left > 0 && text.charAt(left - 1) == ' ') {
    left--;
  }
  while (left > 0 && isSpecialChar(text.charAt(left - 1))) {
    left--;
  }
  while (left > 0 && isWordChar(text.charAt(left - 1))) {
    left--;
  }
  int right = caret;
  while (right < text.length() && text.charAt(right) == ' ') {
    right++;
  }
  airportSelector.searchQuery = text.substring(0, left) + text.substring(right);
  airportSelector.caretIndex = left;
  while (airportSelector.caretIndex > 0 &&
         airportSelector.searchQuery.charAt(airportSelector.caretIndex - 1) == ' ') {
    airportSelector.caretIndex--;
  }
  airportSelector.clearSelection();
  airportSelector.resetScroll();
}

boolean isWordChar(char c) {
  return Character.isLetterOrDigit(c);
}

boolean isSpecialChar(char c) {
  return !Character.isLetterOrDigit(c) && c != ' ';
}

void loadAirportDictionary() {
  String[] rows = loadStrings("airport_data.csv");
  if (rows == null) {
    println("Could not find 'airport_data.csv' in the data folder.");
    return;
  }
  for (int i = 1; i < rows.length; i++) {
    String[] cols = split(rows[i], ',');
    if (cols.length >= 5) {
      String airportName = cols[1].trim();
      String iataCode = cols[2].trim();
      String city = cols[3].trim();
      String country = cols[4].trim();
      String label = airportName + " (" + city + ", " + country + ")";
      airportLookup.put(iataCode, label);
    }
  }
  println("Loaded airport_data.csv. Dictionary size = " + airportLookup.size());
}
