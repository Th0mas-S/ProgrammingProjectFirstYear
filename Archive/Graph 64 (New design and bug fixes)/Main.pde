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

boolean arrowLeftHeld = false;
boolean arrowRightHeld = false;
int arrowHoldStart = 0;
int arrowLastRepeat = 0;

int arrowInitialDelay = 300;
int arrowRepeatRate = 50;    

boolean ctrlBackspaceHeld = false;
int ctrlBackspaceHoldStart = 0;
int ctrlBackspaceLastRepeat = 0;
int ctrlBackspaceInitialDelay = 300; // milliseconds before repeat starts
int ctrlBackspaceRepeatRate = 50;    // milliseconds between repeats

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
    
    int now = millis();
    
    // Handle backspace repeat.
    if (backspaceHeld && now - backspaceHoldStart > initialDelay && now - backspaceLastDelete > repeatRate) {
      handleBackspace();
      backspaceLastDelete = now;
    }
    
    // Handle held arrow keys.
    if (airportSelector.searchFocused) {
      if (arrowLeftHeld && now - arrowHoldStart > arrowInitialDelay && now - arrowLastRepeat > arrowRepeatRate) {
        airportSelector.setCaretIndex(airportSelector.caretIndex - 1);
        airportSelector.clearSelection();
        arrowLastRepeat = now;
      }
      if (arrowRightHeld && now - arrowHoldStart > arrowInitialDelay && now - arrowLastRepeat > arrowRepeatRate) {
        airportSelector.setCaretIndex(airportSelector.caretIndex + 1);
        airportSelector.clearSelection();
        arrowLastRepeat = now;
      }
    }
    
    // Handle CTRL-backspace repeat.
    if (airportSelector.searchFocused && ctrlBackspaceHeld) {
      if (now - ctrlBackspaceHoldStart > ctrlBackspaceInitialDelay && now - ctrlBackspaceLastRepeat > ctrlBackspaceRepeatRate) {
        handleCtrlBackspace();
        ctrlBackspaceLastRepeat = now;
      }
    }
    
    // Handle repeat for other keys.
    if (keyBeingHeld && heldKey != 0 && heldKey != BACKSPACE) {
      if (now - keyHoldStart > initialDelay && now - keyLastRepeat > repeatRate) {
        insertKeyChar(heldKey);
        keyLastRepeat = now;
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
  if (screenMode == SCREEN_SELECTION &&
     ((mouseX >= airportSelector.listX && mouseX <= airportSelector.listX + airportSelector.listWidth &&
       mouseY >= airportSelector.listY && mouseY <= airportSelector.listY + airportSelector.itemsToShow * airportSelector.itemHeight) ||
      (mouseX >= airportSelector.sliderX && mouseX <= airportSelector.sliderX + airportSelector.sliderWidth &&
       mouseY >= airportSelector.sliderY && mouseY <= airportSelector.sliderY + airportSelector.sliderHeight))) {
        
    float e = event.getCount();
    String[] filtered = airportSelector.getFilteredAirports();
    int maxTopIndex = max(0, filtered.length - airportSelector.itemsToShow);
    airportSelector.topIndex += (int) e;
    airportSelector.topIndex = constrain(airportSelector.topIndex, 0, maxTopIndex);
    airportSelector.sliderPos = (maxTopIndex == 0) ? 0 : airportSelector.topIndex / (float) maxTopIndex;
  }
}

void keyPressed() {
  // In graph view, handle BACKSPACE for navigation.
  if (screenMode == SCREEN_OVERVIEW) {
    if (key == BACKSPACE) {
      if (!graphScreen.inMenu) {
        graphScreen.inMenu = true;
        return;
      } else {
        screenMode = SCREEN_SELECTION;
        graphScreen = null;
        return;
      }
    }
  }
  
  if (screenMode == SCREEN_SELECTION && airportSelector.searchFocused) {
    // Ignore the event if it's a repeat event for the same key.
    if (keyBeingHeld && key == heldKey) {
      return;
    }
    
    int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
    int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);

    if (key == BACKSPACE) {
      if (keyEvent.isControlDown() || keyEvent.isMetaDown()) {
        ctrlBackspaceHeld = true;
        ctrlBackspaceHoldStart = millis();
        ctrlBackspaceLastRepeat = millis();
        handleCtrlBackspace();
      } else {
        backspaceHeld = true;
        backspaceHoldStart = millis();
        backspaceLastDelete = millis();
        handleBackspace();
      }
    }
    else if (key == DELETE) {
      if (airportSelector.hasSelection()) {
        airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                        airportSelector.searchQuery.substring(selEnd);
        airportSelector.setCaretIndex(selStart);
        airportSelector.clearSelection();
        airportSelector.resetScroll();
      } else if (airportSelector.caretIndex < airportSelector.searchQuery.length()) {
        airportSelector.searchQuery = airportSelector.searchQuery.substring(0, airportSelector.caretIndex) +
                                        airportSelector.searchQuery.substring(airportSelector.caretIndex + 1);
        airportSelector.clearSelection();
        airportSelector.resetScroll();
      }
    }
    else if (key == CODED) {
      if (keyCode == LEFT) {
        arrowLeftHeld = true;
        arrowHoldStart = millis();
        arrowLastRepeat = millis();
        airportSelector.setCaretIndex(airportSelector.caretIndex - 1);
        airportSelector.clearSelection();
      } else if (keyCode == RIGHT) {
        arrowRightHeld = true;
        arrowHoldStart = millis();
        arrowLastRepeat = millis();
        airportSelector.setCaretIndex(airportSelector.caretIndex + 1);
        airportSelector.clearSelection();
      }
    }
    else if (key == ENTER || key == RETURN) {
      String[] filteredAirports = airportSelector.getFilteredAirports();
      if (filteredAirports.length == 1) {
        String selected = filteredAirports[0];
        processData.filterDate = null;
        if (graphScreen != null) graphScreen.lastSelectedDate = null;
        processData.process(selected);
        graphScreen = new GraphSelectorMenu(selected, processData);
        screenMode = SCREEN_OVERVIEW;
      }
    }
    else {
      // Insert the key and set the custom repeat flags.
      char c = key;
      insertKeyChar(c);
      // Set flags for our own key repeat logic.
      heldKey = key;
      keyBeingHeld = true;
      keyHoldStart = millis();
      keyLastRepeat = millis();
    }
  }
}

void keyReleased() {
  // Reset all key repeat flags on any key release to prevent stale flags.
  backspaceHeld = false;
  ctrlBackspaceHeld = false;
  arrowLeftHeld = false;
  arrowRightHeld = false;
  keyBeingHeld = false;
  heldKey = 0;
}

void insertKeyChar(char c) {
  if (airportSelector.searchQuery.length() >= SEARCH_CHAR_LIMIT) return;

  if (airportSelector.hasSelection()) {
    int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
    int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
    String oldText = airportSelector.searchQuery;
    airportSelector.searchQuery = oldText.substring(0, selStart) + c + oldText.substring(selEnd);
    airportSelector.setCaretIndex(selStart + 1);
    airportSelector.selectionStart = airportSelector.selectionEnd = airportSelector.caretIndex;
  } else {
    int caret = airportSelector.caretIndex;
    String oldText = airportSelector.searchQuery;
    airportSelector.searchQuery = oldText.substring(0, caret) + c + oldText.substring(caret);
    airportSelector.setCaretIndex(caret + 1);
  }
}

void handleBackspace() {
  if (airportSelector.hasSelection()) {
    int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
    int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                    airportSelector.searchQuery.substring(selEnd);
    airportSelector.setCaretIndex(selStart);
    airportSelector.selectionStart = airportSelector.selectionEnd = airportSelector.caretIndex;
    airportSelector.resetScroll();
  } else if (airportSelector.searchQuery.length() > 0 && airportSelector.caretIndex > 0) {
    int caret = airportSelector.caretIndex;
    String oldText = airportSelector.searchQuery;
    airportSelector.searchQuery = oldText.substring(0, caret - 1) + oldText.substring(caret);
    airportSelector.setCaretIndex(caret - 1);
  }
}

void handleCtrlBackspace() {
  // If searchQuery is empty, disable ctrlBackspaceHeld to prevent deletion of new text.
  if (airportSelector.searchQuery.length() == 0) {
    ctrlBackspaceHeld = false;
    return;
  }
  
  int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
  int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
  if (airportSelector.searchQuery.length() > 0 && selStart != selEnd) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                    airportSelector.searchQuery.substring(selEnd);
    airportSelector.setCaretIndex(selStart);
    airportSelector.selectionStart = airportSelector.selectionEnd = airportSelector.caretIndex;
    airportSelector.resetScroll();
    return;
  }
  
  String text = airportSelector.searchQuery;
  int caret = airportSelector.caretIndex;
  if (caret == 0) return;
  int left = caret;
  
  // Remove trailing spaces.
  while (left > 0 && text.charAt(left - 1) == ' ') {
    left--;
  }
  // Remove any special characters.
  while (left > 0 && isSpecialChar(text.charAt(left - 1))) {
    left--;
  }
  // Remove word characters.
  while (left > 0 && isWordChar(text.charAt(left - 1))) {
    left--;
  }
  // Remove additional trailing whitespace.
  while (left > 0 && text.charAt(left - 1) == ' ') {
    left--;
  }
  
  airportSelector.searchQuery = text.substring(0, left) + text.substring(caret);
  airportSelector.setCaretIndex(left);
  airportSelector.selectionStart = airportSelector.selectionEnd = airportSelector.caretIndex;
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
