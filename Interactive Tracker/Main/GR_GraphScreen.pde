

Utility util;
AirportSelectorMenu airportSelector;
GraphSelectorMenu graphScreen;
ProcessData processData;
String[] uniqueAirports;
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

interface StringLookup {
  String get(String code);
}

void initGraphGlobVariables() {
   util = new Utility();
  
  //loadAirportDictionary();
  
  processData = new ProcessData();
  uniqueAirports = processData.getUniqueAirports();
  processData.filterDate = null;
  
  flighthubLogo = loadImage("Flighthub Logo.png");
  
  StringLookup airportNameLookup = new StringLookup() {
    public String get(String code) {
      if (airportLookup.containsKey(code)) return airportLookup.get(code);
      return code;
    }
  };

  airportSelector = new AirportSelectorMenu(uniqueAirports, airportNameLookup, flighthubLogo);
}

import java.text.Normalizer;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.Collections;

// --------------------------------------------------------------------------
// AirportSelectorMenu Class
// --------------------------------------------------------------------------

class AirportSelectorMenu extends Screen {
  String[] airports;
  int topIndex = 0;
  int itemsToShow = 6;
  
  float listWidth = 0.5 * width;
  float itemHeight = 80;
  float listSliderGap = 30;
  float sliderWidth = 30;
  float sliderKnobHeight = 60;
  float listX, listY;
  float sliderX, sliderY, sliderHeight;
  
  boolean dragging = false;
  float sliderPos = 0;
  
  String searchQuery = "";
  boolean searchFocused = false;
  int lastBlinkTime = 0;
  boolean showCaret = true;
  int caretIndex = 0;
  int selectionStart = 0;
  int selectionEnd = 0;
  boolean selectingText = false;
  
  StringLookup airportLookup;
  
  PImage logo;  // The FlightHub logo
  
  SortField sortField = SortField.CODE;  
  SortOrder sortOrder = SortOrder.ASC;
  float sortMenuW = 280, sortMenuH = 55, sortMenuX, sortMenuY;
  boolean sortMenuOpen = false;
  Option[] sortOptions;
  float optionHeight = 40;
  
  class Option {
    SortField field;
    SortOrder order;
    String label;
    
    Option(SortField field, SortOrder order, String label) {
      this.field = field;
      this.order = order;
      this.label = label;
    }
  }
  
  AirportSelectorMenu(String[] airports, StringLookup lookup, PImage logo) {
    this.airports = airports;
    this.airportLookup = lookup;
    this.logo = logo;
    
    sortOptions = new Option[6];
    sortOptions[0] = new Option(SortField.CODE,    SortOrder.ASC,  "Airport Code (A–Z)");
    sortOptions[1] = new Option(SortField.CODE,    SortOrder.DESC, "Airport Code (Z–A)");
    sortOptions[2] = new Option(SortField.NAME,    SortOrder.ASC,  "Airport Name (A–Z)");
    sortOptions[3] = new Option(SortField.NAME,    SortOrder.DESC, "Airport Name (Z–A)");
    sortOptions[4] = new Option(SortField.COUNTRY, SortOrder.ASC,  "Country Name (A–Z)");
    sortOptions[5] = new Option(SortField.COUNTRY, SortOrder.DESC, "Country Name (Z–A)");
  }
  
  void recalcLayout() {
    // Offset to shift the entire UI down
    float yOffset = 100;
    
    listWidth = 0.5 * width;  
    itemHeight = 80;
    float totalElementWidth = listWidth + listSliderGap + sliderWidth;
    listX = (width - totalElementWidth) / 2;
    
    // Move the entire UI down by yOffset
    listY = (height / 2 - (itemsToShow * itemHeight) / 2) + yOffset;
    
    sliderX = listX + listWidth + listSliderGap;
    sliderY = listY;
    sliderHeight = itemsToShow * itemHeight;
    
    float searchBarHeight = 55;
    // The search bar sits above the list; its y-position is now relative to the shifted listY.
    float searchBarY = listY - searchBarHeight - 20;
    sortMenuX = listX - sortMenuW - 10;
    sortMenuY = searchBarY;
  }
  
  void resetScroll() {
    topIndex = 0;
    sliderPos = 0;
  }
  
  boolean hasSelection() {
    return selectionStart != selectionEnd;
  }
  
  void clearSelection() {
    selectionStart = selectionEnd = caretIndex;
  }
  
  void draw() {
    background(0);
    recalcLayout();
    
    // Blink caret every 500ms.
    if (millis() - lastBlinkTime > 500) {
      showCaret = !showCaret;
      lastBlinkTime = millis();
    }
    
    float searchBarHeight = 55;
    float searchBarY = listY - searchBarHeight - 20;
    
    // --- Draw the FlightHub logo above the search bar ---
    if (logo != null) {
      float desiredLogoWidth = listWidth * 0.75; 
      float aspect = (float) logo.height / logo.width;
      float desiredLogoHeight = desiredLogoWidth * aspect;
      float marginAboveSearchBar = -140;
      float centerX = width / 2;
      float centerY = searchBarY - marginAboveSearchBar - (desiredLogoHeight / 2);
      imageMode(CENTER);
      image(logo, centerX, centerY, desiredLogoWidth, desiredLogoHeight);
    }
    
    // Draw search bar.
    float clearButtonSize = 28;
    float clearButtonX = listX + listWidth - clearButtonSize - 10;
    float clearButtonY = searchBarY + (searchBarHeight - clearButtonSize) / 2;
    
    fill(255);
    stroke(searchFocused ? color(0, 120, 255) : 150);
    strokeWeight(2);
    rect(listX, searchBarY, listWidth, searchBarHeight, 10);
    
    fill(0);
    textAlign(LEFT, CENTER);
    textSize(24);
    
    // If the search bar is focused, even an empty query is shown with full opacity.
    String displayText;
    int textAlpha;
    if (searchQuery.isEmpty() && !searchFocused) {
      displayText = "Search airports...";
      textAlpha = 120;
    } else {
      displayText = searchQuery;
      textAlpha = 255;
    }
    
    fill(0, textAlpha);
    text(displayText, listX + 16, searchBarY + searchBarHeight / 2);
    
    // Draw text selection highlight.
    if (searchFocused && hasSelection() && textAlpha == 255) {
      int selStart = min(selectionStart, selectionEnd);
      int selEnd = max(selectionStart, selectionEnd);
      String before = searchQuery.substring(0, selStart);
      String selected = searchQuery.substring(selStart, selEnd);
      float highlightX = listX + 16 + textWidth(before);
      float highlightW = textWidth(selected);
      fill(180, 220, 255, 180);
      noStroke();
      rect(highlightX, searchBarY + 8, highlightW, searchBarHeight - 16, 4);
    }
    
    // Draw caret.
    if (searchFocused && textAlpha == 255 && showCaret) {
      String beforeCaret = searchQuery.substring(0, caretIndex);
      float caretX = listX + 16 + textWidth(beforeCaret);
      stroke(0);
      strokeWeight(2);
      line(caretX, searchBarY + 10, caretX, searchBarY + searchBarHeight - 10);
    }
    
    // Draw clear button if query is not empty.
    if (!searchQuery.isEmpty()) {
      fill(200);
      noStroke();
      ellipse(clearButtonX + clearButtonSize / 2, clearButtonY + clearButtonSize / 2, clearButtonSize, clearButtonSize);
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(16);
      text("X", clearButtonX + clearButtonSize / 2, clearButtonY + clearButtonSize / 2);
    }
    
    drawAirportList();
    drawSortMenu();
    
  }
  
  void drawAirportList() {
    String[] filteredAirports = getFilteredAirports();
    topIndex = constrain(topIndex, 0, max(0, filteredAirports.length - itemsToShow));
    
    textAlign(CENTER, CENTER);
    for (int i = 0; i < itemsToShow; i++) {
      int index = topIndex + i;
      float currentItemY = listY + i * itemHeight;
      boolean overMenu = false;
      
      if (mouseX > sortMenuX && mouseX < sortMenuX + sortMenuW &&
          mouseY > sortMenuY && mouseY < sortMenuY + sortMenuH) {
        overMenu = true;
      }
      
      if (sortMenuOpen) {
        float totalOptionsHeight = sortOptions.length * optionHeight;
        float menuBottom = sortMenuY + sortMenuH + totalOptionsHeight;
        if (mouseX > sortMenuX && mouseX < sortMenuX + sortMenuW &&
            mouseY > sortMenuY && mouseY < menuBottom) {
          overMenu = true;
        }
      }
      
      boolean overTile = (!overMenu &&
                          mouseX > listX && mouseX < listX + listWidth &&
                          mouseY > currentItemY && mouseY < currentItemY + itemHeight);
      
      if (index < filteredAirports.length) {
        if (overTile) {
          fill(120, 170, 255);
          stroke(50, 80, 150);
          strokeWeight(1.5);
        } else {
          fill(100, 150, 255);
          noStroke();
        }
        
        rect(listX, currentItemY, listWidth, itemHeight, 12);
        
        fill(255);
        String code = filteredAirports[index];
        String fullName = airportLookup.get(code);
        if (fullName == null) fullName = code;
        String label = fullName + " / " + code;
        
        float fontSize = 24;
        textSize(fontSize);
        while (textWidth(label) > listWidth - 20 && fontSize > 12) {
          fontSize -= 1;
          textSize(fontSize);
        }
        text(label, listX + listWidth / 2, currentItemY + itemHeight / 2);
      }
    }
    
    // Draw slider if needed.
    if (filteredAirports.length > itemsToShow) {
      fill(210);
      rect(sliderX, sliderY, sliderWidth, sliderHeight, 6);
      float availableTrackHeight = sliderHeight - sliderKnobHeight;
      float knobY = sliderY + sliderPos * availableTrackHeight;
      if (dragging || (mouseX > sliderX && mouseX < sliderX + sliderWidth &&
                       mouseY > knobY && mouseY < knobY + sliderKnobHeight)) {
        fill(80);
      } else {
        fill(120);
      }
      rect(sliderX, knobY, sliderWidth, sliderKnobHeight, 6);
    }
  }
  
  void drawSortMenu() {
    fill(255);
    stroke(150);
    strokeWeight(2);
    rect(sortMenuX, sortMenuY, sortMenuW, sortMenuH, 10);
    
    fill(0);
    textSize(20);
    textAlign(LEFT, CENTER);
    text("Sort by:", sortMenuX + 10, sortMenuY + sortMenuH / 2);
    
    String currentOption = "";
    if (sortField == SortField.CODE) {
      currentOption = (sortOrder == SortOrder.ASC) ? "Airport Code (A–Z)" : "Airport Code (Z–A)";
    } else if (sortField == SortField.NAME) {
      currentOption = (sortOrder == SortOrder.ASC) ? "Airport Name (A–Z)" : "Airport Name (Z–A)";
    } else if (sortField == SortField.COUNTRY) {
      currentOption = (sortOrder == SortOrder.ASC) ? "Country Name (A–Z)" : "Country Name (Z–A)";
    }
    
    textAlign(RIGHT, CENTER);
    text(currentOption, sortMenuX + sortMenuW - 10, sortMenuY + sortMenuH / 2);
    
    if (sortMenuOpen) {
      float totalOptionsHeight = sortOptions.length * optionHeight;
      for (int i = 0; i < sortOptions.length; i++) {
        float optionY = sortMenuY + sortMenuH + i * optionHeight;
        boolean hovered = (mouseX > sortMenuX && mouseX < sortMenuX + sortMenuW &&
                           mouseY > optionY && mouseY < optionY + optionHeight);
        if (hovered) {
          fill(200);
        } else {
          fill(255);
        }
        stroke(150);
        strokeWeight(2);
        rect(sortMenuX, optionY, sortMenuW, optionHeight, 10);
        
        fill(0);
        textSize(18);
        textAlign(LEFT, CENTER);
        text(sortOptions[i].label, sortMenuX + 10, optionY + optionHeight / 2);
      }
    }
  }
  
  void mousePressed() {
    String selected = airportSelector.handleMousePressed(mouseX, mouseY);
    airportSelector.handleSliderMousePressed(mouseX, mouseY);
    
    if (selected != null) {
      processData.filterDate = null;
      if (graphScreen != null) graphScreen.lastSelectedDate = null;
      
      processData.process(selected);
      graphScreen = new GraphSelectorMenu(selected, processData);
      screenManager.switchScreen(graphScreen);
    }
  }
  
  String handleMousePressed(float mx, float my) {
    float searchBarHeight = 55;
    float searchBarY = listY - searchBarHeight - 20;
    float clearX = listX + listWidth - 28 - 10;
    float clearY = searchBarY + (searchBarHeight - 28) / 2;
    
    if (!searchQuery.isEmpty()) {
      if (mx > clearX && mx < clearX + 28 && my > clearY && my < clearY + 28) {
        searchQuery = "";
        caretIndex = 0;
        clearSelection();
        resetScroll();
        return null;
      }
    }
    
    if (mx > listX && mx < listX + listWidth && my > searchBarY && my < searchBarY + searchBarHeight) {
      searchFocused = true;
      float relativeX = mx - (listX + 16);
      caretIndex = getCaretFromX(relativeX);
      selectionStart = selectionEnd = caretIndex;
      selectingText = true;
      sortMenuOpen = false;
      return null;
    } else {
      searchFocused = false;
    }
    
    if (mx > sortMenuX && mx < sortMenuX + sortMenuW &&
        my > sortMenuY && my < sortMenuY + sortMenuH) {
      sortMenuOpen = !sortMenuOpen;
      return null;
    }
    
    if (sortMenuOpen) {
      for (int i = 0; i < sortOptions.length; i++) {
        float optionY = sortMenuY + sortMenuH + i * optionHeight;
        if (mx > sortMenuX && mx < sortMenuX + sortMenuW &&
            my > optionY && my < optionY + optionHeight) {
          sortField = sortOptions[i].field;
          sortOrder = sortOptions[i].order;
          sortMenuOpen = false;
          return null;
        }
      }
      return null;
    }
    
    String[] filteredAirports = getFilteredAirports();
    if (mx > listX && mx < listX + listWidth && my > listY && my < listY + itemsToShow * itemHeight) {
      int itemIndex = floor((my - listY) / itemHeight);
      int index = topIndex + itemIndex;
      if (index >= 0 && index < filteredAirports.length) {
        println("Selected: " + filteredAirports[index]);
        return filteredAirports[index];
      }
    }
    
    sortMenuOpen = false;
    return null;
  }
  
  void handleMouseDraggedInSearch(float mx) {
    if (!selectingText) return;
    float relativeX = mx - (listX + 16);
    int newCaret = getCaretFromX(relativeX);
    caretIndex = newCaret;
    selectionEnd = newCaret;
  }
  
  int getCaretFromX(float relativeX) {
    for (int i = 0; i <= searchQuery.length(); i++) {
      String sub = searchQuery.substring(0, i);
      float w = textWidth(sub);
      if (w - 5 > relativeX) {
        return max(0, i - 1);
      }
    }
    return searchQuery.length();
  }
  
  void handleSliderMousePressed(float mx, float my) {
    String[] filteredAirports = getFilteredAirports();
    if (filteredAirports.length <= itemsToShow) return;
    if (mx > sliderX && mx < sliderX + sliderWidth && my > sliderY && my < sliderY + sliderHeight) {
      dragging = true;
      updateSlider(my);
    }
  }
  
  void keyPressed() {
    
    if(searchFocused) {
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
        screenManager.switchScreen(graphScreen);
      }
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
  
  void mouseDragged() {
    airportSelector.handleSliderMouseDragged(mouseX, mouseY);
    airportSelector.handleMouseDraggedInSearch(mouseX);
    
  }
  
  void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    String[] filtered = airportSelector.getFilteredAirports();
    int maxTopIndex = max(0, filtered.length - airportSelector.itemsToShow);
    airportSelector.topIndex += (int)e;
    airportSelector.topIndex = constrain(airportSelector.topIndex, 0, maxTopIndex);
    airportSelector.sliderPos = (maxTopIndex == 0) ? 0 : airportSelector.topIndex / (float)maxTopIndex;
  
  }
  
  void handleSliderMouseDragged(float mx, float my) {
    if (dragging) {
      updateSlider(my);
    }
  }
  
  void mouseReleased() {
    dragging = false;
    selectingText = false;
    handleSliderMouseReleased();

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
    void handleSliderMouseReleased() {
    dragging = false;
    selectingText = false;
  }
  
  void updateSlider(float my) {
    String[] filteredAirports = getFilteredAirports();
    if (filteredAirports.length <= itemsToShow) return;
    float targetY = my - sliderY - (sliderKnobHeight / 2);
    float availableTrackHeight = sliderHeight - sliderKnobHeight;
    sliderPos = (availableTrackHeight <= 0) ? 0 : targetY / availableTrackHeight;
    sliderPos = constrain(sliderPos, 0, 1);
    int maxTopIndex = max(0, filteredAirports.length - itemsToShow);
    topIndex = round(sliderPos * maxTopIndex);
    topIndex = constrain(topIndex, 0, maxTopIndex);
  }
  
  String[] getFilteredAirports() {
    ArrayList<String> filtered = new ArrayList<String>();
    String q = normalize(searchQuery);
    for (String code : airports) {
      String label = airportLookup.get(code);
      if (label == null) label = code;
      String combined = label + " / " + code; 
      if (normalize(combined).contains(q)) {
        filtered.add(code);
      }
    }
    Collections.sort(filtered, new java.util.Comparator<String>() {
      public int compare(String c1, String c2) {
        String label1 = airportLookup.get(c1);
        String label2 = airportLookup.get(c2);
        if (label1 == null) label1 = c1;
        if (label2 == null) label2 = c2;
        String code1 = c1;
        String code2 = c2;
        String name1 = label1;
        String name2 = label2;
        if (name1.contains("(")) name1 = name1.substring(0, name1.indexOf("(")).trim();
        if (name2.contains("(")) name2 = name2.substring(0, name2.indexOf("(")).trim();
        String country1 = "";
        String country2 = "";
        int open1 = label1.indexOf("(");
        int close1 = label1.indexOf(")");
        if (open1 >= 0 && close1 > open1) {
          String inside1 = label1.substring(open1 + 1, close1).trim();
          int commaPos = inside1.lastIndexOf(",");
          if (commaPos >= 0 && commaPos < inside1.length() - 1) {
            country1 = inside1.substring(commaPos + 1).trim();
          } else {
            country1 = inside1;
          }
        }
        int open2 = label2.indexOf("(");
        int close2 = label2.indexOf(")");
        if (open2 >= 0 && close2 > open2) {
          String inside2 = label2.substring(open2 + 1, close2).trim();
          int commaPos = inside2.lastIndexOf(",");
          if (commaPos >= 0 && commaPos < inside2.length() - 1) {
            country2 = inside2.substring(commaPos + 1).trim();
          } else {
            country2 = inside2;
          }
        }
        int result = 0;
        switch (sortField) {
          case CODE:
            result = code1.compareToIgnoreCase(code2);
            break;
          case NAME:
            result = name1.compareToIgnoreCase(name2);
            break;
          case COUNTRY:
            result = country1.compareToIgnoreCase(country2);
            break;
        }
        if (sortOrder == SortOrder.DESC) {
          result = -result;
        }
        return result;
      }
    });
    return filtered.toArray(new String[filtered.size()]);
  }
  
  String normalize(String text) {
    return Normalizer.normalize(text, Normalizer.Form.NFD)
                     .replaceAll("\\p{M}", "")
                     .toLowerCase()
                     .trim()
                     .replaceAll("\\s+", " ");
  }
}

import java.util.ArrayList;

class ProcessData 
{
  Table table;
  int totalFlights, onTimeFlights, delayedFlights, cancelledFlights;
  String filterDate = null;
  
  ProcessData()
  {
    try 
    {
      table = loadTable(currentDataset, "header,csv");
      println("Loaded " + table.getRowCount() + " rows from " + currentDataset);
    }
    catch(Exception e) 
    {
      println("Error loading CSV: " + e.getMessage());
    }
  }
  
  void process(String airport) 
  {
    if (table == null) 
    {
      println("No table loaded, cannot process data.");
      return;
    }
    totalFlights = 0;
    onTimeFlights = 0;
    delayedFlights = 0;
    cancelledFlights = 0;
    
    for (TableRow row : table.rows()) 
    {
      if (!rowMatchesFilter(row, airport)) continue;
      
      totalFlights++;
      String cancelledStr = row.getString("cancelled").trim().toLowerCase();
      
      if (cancelledStr.equals("true")) 
      {
        cancelledFlights++;
      } 
      else 
      {
        try 
        {
          int delay = row.getInt("minutes_late");
          
          if (delay > 0) 
          {
            delayedFlights++;
          }
          else
          {
            onTimeFlights++;
          }
        }
      catch(Exception e) { }
      }
    }
    println("Processed data for airport: " + airport + " on " + (filterDate != null ? filterDate : "all dates"));
    println("  Total Flights: " + totalFlights);
    println("  On Time: " + onTimeFlights);
    println("  Delayed: " + delayedFlights);
    println("  Cancelled: " + cancelledFlights);
    println("---------------------------------------");
  }
  
  boolean rowMatchesFilter(TableRow row, String airport)
  {
    if (!row.getString("origin").equalsIgnoreCase(airport)) return false;
    
    if (filterDate != null)
    {
      String sched = row.getString("scheduled_departure");
      
      if (sched == null || !sched.substring(0, 10).equals(filterDate)) return false;
    }
    return true;
  }
  
  String[] getUniqueAirports() 
  {
    if (table == null) return new String[0];
    ArrayList<String> unique = new ArrayList<String>();
    
    for (TableRow row : table.rows())
    {
      String orig = row.getString("origin").trim();
      
      if (!unique.contains(orig))
      {
        unique.add(orig);
      }
    }
    Collections.sort(unique);
    return unique.toArray(new String[unique.size()]);
  }
}

// Utility.pde
// Contains helper methods used throughout the sketch.

class Utility {

  // Returns a fitted text size for a single line of text.
  float getFittedTextSize(String text, float maxWidth, float defaultSize) {
    float ts = defaultSize;
    textSize(ts);
    while (ts > 5 && textWidth(text) > maxWidth) {
      ts -= 1;
      textSize(ts);
    }
    return ts;
  }
  
  // Returns a fitted text size for multiple lines by joining them.
  float getFittedTextSize(String[] lines, float maxWidth, float defaultSize) {
    String joined = join(lines, " ");
    return getFittedTextSize(joined, maxWidth, defaultSize);
  }
  
  // Formats a date string ("YYYY-MM-DD") into a more descriptive form.
  String formatDate(String date) {
    String[] parts = split(date, "-");
    if (parts.length != 3) return date;
    int year  = int(parts[0]);
    int month = int(parts[1]);
    int day   = int(parts[2]);
    return getOrdinal(day) + " of " + getMonthNameFull(month) + " " + year;
  }
  
  // Returns the ordinal (st, nd, rd, th) for a day.
  String getOrdinal(int day) {
    if (day >= 11 && day <= 13) return nf(day, 0) + "th";
    int lastDigit = day % 10;
    if (lastDigit == 1) return nf(day, 0) + "st";
    if (lastDigit == 2) return nf(day, 0) + "nd";
    if (lastDigit == 3) return nf(day, 0) + "rd";
    return nf(day, 0) + "th";
  }
  
  // Returns the full month name given a month number (1-12).
  String getMonthNameFull(int m) {
    String[] months = {"January", "February", "March", "April", "May", "June",
                       "July", "August", "September", "October", "November", "December"};
    if (m < 1 || m > 12) return "";
    return months[m-1];
  }
  
  // Extracts the airport name from a full origin string.
  String extractAirportName(String fullOrigin) {
    int openParen = fullOrigin.indexOf("(");
    if (openParen != -1) {
      return fullOrigin.substring(0, openParen).trim();
    }
    return fullOrigin;
  }
  
  // Extracts the location (inside the parenthesis) from a full origin string.
  String extractLocation(String fullOrigin) {
    int openParen  = fullOrigin.indexOf("(");
    int closeParen = fullOrigin.indexOf(")");
    if (openParen != -1 && closeParen != -1 && closeParen > openParen) {
      return fullOrigin.substring(openParen + 1, closeParen).trim();
    }
    return "";
  }
}

// --------------------------------------------------------------------------
// GraphSelectorMenu Class
// --------------------------------------------------------------------------

class GraphSelectorMenu extends Screen {
  String airport;
  ProcessData data;
  CalendarDisplay calendar;
  
  // inMenu == true means the graph selection menu is visible;
  // inMenu == false means a graph is being displayed.
  boolean inMenu = true;
  int selectedGraph = 0;
  
  PImage iconPie, iconLine, iconBar, iconGrouped, iconRadar, iconScatter, iconHistogram, iconBubble;
  
  int graphStartTime = 0;
  float animationProgress = 0;
  float animationDuration = 1000; // Animation lasts 1 second
  
  boolean annualData = true; 
  String lastSelectedDate = null;
  
  GraphSelectorMenu(String airport, ProcessData data) {
    this.airport = airport;
    this.data = data;
    generateIcons();
    calendar = new CalendarDisplay(width - 420, 80, 400, 280);
    calendar.month = 0;
    calendar.year = 2017;
    calendar.selectedDay = 1;
    data.filterDate = null;
  }
  
  void generateIcons() {
    iconPie     = createPieIcon();
    iconLine    = createLineIcon();
    iconBar     = createBarIcon();
    iconGrouped = createGroupedIcon();
    iconRadar   = createRadarIcon();
    iconScatter = createScatterIcon();
    iconHistogram = createHistogramIcon();
    iconBubble  = createBubbleIcon();
  }
  
  // --------------------------------------------------------------------------
  // Icon creation methods
  // --------------------------------------------------------------------------
  
  PImage createPieIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.noStroke();
    float totalAngle = TWO_PI;
    float start = -HALF_PI;
    float angleOnTime = totalAngle * 0.10;
    pg.fill(0, 200, 0);
    pg.arc(32, 32, 50, 50, start, start + angleOnTime);
    start += angleOnTime;
    float angleDelayed = totalAngle * 0.65;
    pg.fill(0, 0, 255);
    pg.arc(32, 32, 50, 50, start, start + angleDelayed);
    start += angleDelayed;
    float angleCancelled = totalAngle - angleOnTime - angleDelayed;
    pg.fill(255, 0, 0);
    pg.arc(32, 32, 50, 50, start, start + angleCancelled);
    pg.endDraw();
    return pg.get();
  }
  
  PImage createLineIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.stroke(0, 0, 255);
    pg.strokeWeight(3);
    pg.noFill();
    pg.beginShape();
    pg.vertex(8, 50);
    pg.vertex(20, 30);
    pg.vertex(32, 35);
    pg.vertex(44, 20);
    pg.vertex(56, 25);
    pg.endShape();
    pg.endDraw();
    return pg.get();
  }
  
  PImage createBarIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.fill(255, 140, 0);
    pg.noStroke();
    pg.rect(12, 30, 10, 22);
    pg.rect(26, 20, 10, 32);
    pg.rect(40, 10, 10, 42);
    pg.endDraw();
    return pg.get();
  }
  
  PImage createGroupedIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.noStroke();
    pg.fill(0, 0, 200);
    pg.rect(10, 30, 6, 24);
    pg.fill(200, 0, 0);
    pg.rect(18, 35, 6, 19);
    pg.fill(0, 0, 200);
    pg.rect(30, 20, 6, 34);
    pg.fill(200, 0, 0);
    pg.rect(38, 25, 6, 29);
    pg.endDraw();
    return pg.get();
  }
  
  PImage createRadarIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.translate(32, 32);
    pg.noFill();
    pg.stroke(0, 255, 0, 100);
    pg.strokeWeight(1);
    for (int r = 8; r <= 28; r += 8) {
      pg.ellipse(0, 0, r * 2, r * 2);
    }
    pg.noStroke();
    pg.fill(0, 255, 0, 50);
    float wedgeStart = -HALF_PI;
    float wedgeExtent = radians(30);
    pg.arc(0, 0, 56, 56, wedgeStart, wedgeStart + wedgeExtent, PIE);
    pg.fill(0, 255, 0, 180);
    int blips = 5;
    float maxR = 28;
    for (int i = 0; i < blips; i++) {
      float angle = random(TWO_PI);
      float rr = random(maxR);
      float bx = rr * cos(angle);
      float by = rr * sin(angle);
      pg.ellipse(bx, by, 3, 3);
    }
    pg.endDraw();
    return pg.get();
  }
  
  PImage createScatterIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.stroke(0);
    pg.strokeWeight(2);
    pg.noFill();
    pg.line(10, 54, 54, 54);
    pg.line(10, 54, 10, 10);
    pg.strokeWeight(1);
    pg.fill(0, 0, 255);
    for (int i = 0; i < 6; i++) {
      float px = random(15, 50);
      float py = random(15, 50);
      pg.ellipse(px, py, 5, 5);
    }
    pg.endDraw();
    return pg.get();
  }
  
  PImage createHistogramIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.stroke(0);
    pg.strokeWeight(2);
    pg.noFill();
    pg.line(10, 54, 54, 54);
    pg.line(10, 54, 10, 10);
    pg.strokeWeight(0);
    pg.fill(0, 0, 255);
    pg.rect(12, 34, 5, 20);
    pg.rect(20, 20, 5, 34);
    pg.rect(28, 25, 5, 29);
    pg.rect(36, 40, 5, 14);
    pg.rect(44, 15, 5, 39);
    pg.endDraw();
    return pg.get();
  }
  
  PImage createBubbleIcon() {
    PGraphics pg = createGraphics(64, 64);
    pg.beginDraw();
    pg.background(0, 0);
    pg.stroke(0);
    pg.strokeWeight(2);
    pg.noFill();
    pg.line(10, 54, 54, 54);
    pg.line(10, 54, 10, 10);
    pg.strokeWeight(1);
    pg.fill(0, 0, 255, 150);
    pg.ellipse(20, 40, 6, 6);
    pg.ellipse(30, 30, 12, 12);
    pg.ellipse(45, 25, 18, 18);
    pg.endDraw();
    return pg.get();
  }
  
  // --------------------------------------------------------------------------
  // UI Drawing Methods
  // --------------------------------------------------------------------------
  
  void draw() {
    if (inMenu) {
      background(0);
    } 
    else {
      background(255);
    }
    
    drawBackButton();
    
    // Retrieve airport info.
    String fullOrigin = airportLookup.get(airport);
    if (fullOrigin == null) fullOrigin = airport;
    String airportName = util.extractAirportName(fullOrigin);
    String location    = util.extractLocation(fullOrigin);
    
    if (inMenu) {
      float btnWidth = 380, btnHeight = 260, btnGapX = 25, btnGapY = 40;
      int cols = 4, rows = 2;
      float totalWidth  = cols * btnWidth + (cols - 1) * btnGapX;
      float totalHeight = rows * btnHeight + (rows - 1) * btnGapY;
      
      float startX = width / 2 - totalWidth / 2;
      float startY = height / 2 - totalHeight / 2;
      
      float headingBaseY = startY - 80;
      
      String mainHeading = "Graph Selection Menu";
      String subHeader = "Select a Graph for " + airportName + " (" + airport + ")";
      
      fill(255);
      
      textSize(28);
      textAlign(CENTER, TOP);
      text(mainHeading, width / 2, headingBaseY);
      headingBaseY += 35;
      
      float availableWidth = width - 250;
      float fs = util.getFittedTextSize(subHeader, availableWidth, 24);
      textSize(fs);
      text(subHeader, width / 2, headingBaseY);
      
      drawMenu();
    } else {
      int elapsed = millis() - graphStartTime;
      animationProgress = constrain(elapsed / animationDuration, 0, 1);
      
      String line1 = "";
      switch (selectedGraph) {
        case 0: line1 = "Flight Status Breakdown for " + airportName + " (" + airport + ")"; break;
        case 1: line1 = "Hourly Flight Counts for " + airportName + " (" + airport + ")"; break;
        case 2: line1 = "Top 5 Destinations from " + airportName + " (" + airport + ")"; break;
        case 3: line1 = "Airline Performance for " + airportName + " (" + airport + ")"; break;
        case 4: line1 = "Flight Counts (Radar) for " + airportName + " (" + airport + ")"; break;
        case 5: line1 = "Scatter: Hour vs. Delay for " + airportName + " (" + airport + ")"; break;
        case 6: line1 = "Histogram: Delay Distribution for " + airportName + " (" + airport + ")"; break;
        case 7: line1 = "Bubble: Hour vs. Avg Delay vs. Flight Count"; break;
      }
      String line2 = location.length() > 0 ? "Located in " + location : "";
      String line3 = data.filterDate == null ? "Full Annual Data for 2017" : "Daily Data for " + util.formatDate(data.filterDate);
      
      float rightMargin = 250;
      float availableWidth = width - rightMargin;
      float baseY = 15;
      float gap = 5;
      
      float fs1 = util.getFittedTextSize(line1, availableWidth, 24);
      textSize(fs1);
      textAlign(CENTER, TOP);
      text(line1, width / 2, baseY);
      baseY += fs1 + gap;
      
      if (line2.length() > 0) {
        float fs2 = util.getFittedTextSize(line2, availableWidth, 20);
        textSize(fs2);
        text(line2, width / 2, baseY);
        baseY += fs2 + gap;
      }
      
      float fs3 = util.getFittedTextSize(line3, availableWidth, 20);
      textSize(fs3);
      text(line3, width / 2, baseY);
      
      float gx = 150, gy = 150, gw = width - 300, gh = height - 300;
      if (data.totalFlights == 0) {
        fill(0);
        textSize(30);
        textAlign(CENTER, CENTER);
        text("No data available for this date", width / 2, height / 2);
      } else {
        switch (selectedGraph) {
          case 0: new PieChartScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
          case 1: new LineGraphScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
          case 2: new BarChartScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
          case 3: new GroupedBarChartScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
          case 4:
            boolean showMonthlyView = (data.filterDate == null);
            RadarChartScreen radar = new RadarChartScreen(airport, data, animationProgress, showMonthlyView);
            if (!showMonthlyView) {
              radar.setSelectedDate(data.filterDate);
            }
            radar.display(gx, gy, gw, gh);
            break;         
          case 5: new ScatterPlotScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
          case 6: new HistogramScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
          case 7: new BubbleChartScreen(airport, data, animationProgress).display(gx, gy, gw, gh); break;
        }
      }
    }
    
    drawDateSelector();
    drawAnnualToggle();
    
    calendar.x = width - calendar.w - 20;
    calendar.y = 80;
    hint(DISABLE_DEPTH_TEST);
    calendar.display();
    hint(ENABLE_DEPTH_TEST);
  }
  
  void drawMenu() {
    float btnWidth = 380;
    float btnHeight = 260;
    float btnGapX = 25;
    float btnGapY = 40;
    
    String[] labels = {
      "Pie Chart\n(Flight Status)",
      "Line Graph\n(Hourly Counts)",
      "Bar Chart\n(Top Destinations)",
      "Grouped Bar\n(Airline Performance)",
      "Radar Chart\n(Monthly Flights)",
      "Scatter Plot\n(Hour vs. Delay)",
      "Histogram\n(Delay Distribution)",
      "Bubble Chart\n(Hour & Count)"
    };
    
    PImage[] icons = {
      iconPie, iconLine, iconBar, iconGrouped,
      iconRadar, iconScatter, iconHistogram, iconBubble
    };
    
    int cols = 4;
    int rows = 2;
    float totalWidth  = cols * btnWidth + (cols - 1) * btnGapX;
    float totalHeight = rows * btnHeight + (rows - 1) * btnGapY;
    float startX = width / 2 - totalWidth / 2;
    float startY = height / 2 - totalHeight / 2;
    
    for (int i = 0; i < labels.length; i++) {
      int col = i % cols;
      int row = i / cols;
      float bx = startX + col * (btnWidth + btnGapX);
      float by = startY + row * (btnHeight + btnGapY);
      
      if (mouseX > bx && mouseX < bx + btnWidth && mouseY > by && mouseY < by + btnHeight) {
        fill(120, 170, 255);
      } else {
        fill(100, 150, 255);
      }
      rect(bx, by, btnWidth, btnHeight, 16);
      
      if (icons[i] != null) {
        imageMode(CENTER);
        image(icons[i], bx + btnWidth / 2, by + 100, 72, 72);
      }
      
      fill(255);
      textAlign(CENTER, TOP);
      textSize(20);
      text(labels[i], bx + btnWidth / 2, by + 160);
    }
  }
  
  void mousePressed() {
    if (mouseX >= 10 && mouseX <= 90 && mouseY >= 10 && mouseY <= 40) {
      if (inMenu) {
        screenManager.switchScreen(airportSelector);
      } else {
        data.filterDate = null;
        lastSelectedDate = null;
        calendar.month = 0;
        calendar.year = 2017;
        calendar.selectedDay = 1;
        inMenu = true;
        calendar.visible = false;
      }
      return;
    }
    
    if (!inMenu) {
      int annualBx = width - 430, annualBy = 10, annualBw = 200, annualBh = 40;
      if (mouseX >= annualBx && mouseX <= annualBx + annualBw && mouseY >= annualBy && mouseY <= annualBy + annualBh) {
        annualData = !annualData;
        if (annualData) {
          data.filterDate = null;
        } else {
          if (lastSelectedDate != null) {
            data.filterDate = lastSelectedDate;
          }
        }
        data.process(airport);
        return;
      }
    }
    
    if (!inMenu) {
      int bx = width - 220, by = 10, bw = 200, bh = 40;
      if (mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh) {
        calendar.toggle();
        return;
      }
    }
    
    if (calendar.visible) {
      if (calendar.mousePressed()) {
        lastSelectedDate = calendar.getSelectedDate();
        annualData = false;
        data.filterDate = lastSelectedDate;
        data.process(airport);
        calendar.visible = false;
      }
      return;
    }
    
    if (inMenu) {
      int cols = 4, rows = 2;
      float btnWidth = 380;
      float btnHeight = 260;
      float btnGapX = 25;
      float btnGapY = 40;
      float totalWidth  = cols * btnWidth + (cols - 1) * btnGapX;
      float totalHeight = rows * btnHeight + (rows - 1) * btnGapY;
      float startX = width / 2 - totalWidth / 2;
      float startY = height / 2 - totalHeight / 2;
      
      for (int i = 0; i < 8; i++) {
        int col = i % cols;
        int row = i / cols;
        float bx = startX + col * (btnWidth + btnGapX);
        float by = startY + row * (btnHeight + btnGapY);
        
        if (mouseX > bx && mouseX < bx + btnWidth && mouseY > by && mouseY < by + btnHeight) {
          selectedGraph = i;
          inMenu = false;
          graphStartTime = millis();
          animationProgress = 0;
          data.filterDate = null;
          lastSelectedDate = null;
          data.process(airport);
          break;
        }
      }
    }
  }
  
  void drawBackButton() {
    int bx = 10, by = 10, bw = 80, bh = 30;
    stroke(0);
    strokeWeight(1);
    if (mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh) fill(150);
    else fill(180);
    rect(bx, by, bw, bh, 5);
    fill(0);
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Back", bx + bw / 2, by + bh / 2);
  }
  
  void drawAnnualToggle() {
    if (inMenu) return;
    int bx = width - 430, by = 10, bw = 200, bh = 40;
    boolean hovered = (mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh);
    if (annualData) {
      if (hovered) fill(120, 170, 255);
      else fill(100, 150, 255);
    } else {
      if (hovered) fill(180);
      else fill(150);
    }
    stroke(0);
    rect(bx, by, bw, bh, 5);
    fill(0);
    textSize(18);
    textAlign(CENTER, CENTER);
    String label = annualData ? "Annual: On" : "Annual: Off";
    text(label, bx + bw / 2, by + bh / 2);
  }
  
  void drawDateSelector() {
    if (inMenu) return;
    int bx = width - 220, by = 10, bw = 200, bh = 40;
    boolean hovered = (mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh);
    if (hovered) fill(150);
    else fill(180);
    stroke(0);
    rect(bx, by, bw, bh, 5);
    fill(0);
    textSize(18);
    textAlign(CENTER, CENTER);
    text("Calendar", bx + bw / 2, by + bh / 2);
  }
  
  void keyPressed() {
     if (key == BACKSPACE) {
      // If a graph is being displayed, go back to the graph selection menu.
      if (!graphScreen.inMenu) {
        graphScreen.inMenu = true;
        return;
      }
      // If already in graph selection, go back to airport search.
      else {
        screenManager.switchScreen(airportSelector);
        graphScreen = null;
        return;
      }
    }
  }
}

void loadAirportDictionary(String[] rows) {
 
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

enum SortField {
  CODE,
  NAME,
  COUNTRY
}

enum SortOrder {
  ASC,
  DESC
}


class GroupedBarChartScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  GroupedBarChartScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    float marginLeft = 120, marginRight = 120;
    float marginTop = 100, marginBottom = 80;
    float plotX = x + marginLeft;
    float plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight;
    float plotH = h - marginTop - marginBottom;
    
    // Gather airline stats from data.
    HashMap<String, float[]> airlineStats = new HashMap<>();
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        String airline = row.getString("airline_name").trim();
        if (airline.equals("")) airline = "Unknown";
        float[] st = airlineStats.getOrDefault(airline, new float[]{0, 0, 0});
        if (row.getString("cancelled").equalsIgnoreCase("true")) {
          st[2]++;
        } else {
          try {
            int delay = row.getInt("minutes_late");
            if (delay < 0) delay = 0;
            st[0] += delay;
            st[1]++;
          } catch(Exception e) {}
        }
        airlineStats.put(airline, st);
      }
    }
    
    // Sort by number of flights, then by airline name.
    ArrayList<Map.Entry<String, float[]>> list = new ArrayList<>(airlineStats.entrySet());
    Collections.sort(list, (a, b) -> Float.compare(b.getValue()[1], a.getValue()[1]));
    int itemsToShow = min(10, list.size());
    list = new ArrayList<>(list.subList(0, itemsToShow));
    Collections.sort(list, (a, b) -> a.getKey().compareToIgnoreCase(b.getKey()));
    
    // Prepare arrays.
    ArrayList<String> airlines = new ArrayList<>();
    ArrayList<Float> avgDelays = new ArrayList<>();
    ArrayList<Float> cancelRates = new ArrayList<>();
    float maxAvgDelay = 1, maxCancelRate = 1;
    
    for (Map.Entry<String, float[]> e : list) {
      String airline = e.getKey();
      float[] st = e.getValue();
      float avgDelay = (st[1] > 0) ? st[0] / st[1] : 0;
      float cancelRate = (st[1] > 0) ? st[2] / st[1] : 0;
      airlines.add(airline);
      avgDelays.add(avgDelay);
      cancelRates.add(cancelRate);
      if (avgDelay > maxAvgDelay) maxAvgDelay = avgDelay;
      if (cancelRate > maxCancelRate) maxCancelRate = cancelRate;
    }
    
    // Draw left Y-axis (Avg Delay).
    stroke(0);
    line(plotX, plotY, plotX, plotY+plotH);
    textSize(16);
    textAlign(RIGHT, CENTER);
    int yTicks = 5;
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxAvgDelay);
      float ypos = map(i, 0, yTicks, plotY+plotH, plotY);
      line(plotX-5, ypos, plotX, ypos);
      text(nf(val, 0, 1), plotX-10, ypos);
    }
    
    // Add left y-axis label.
    pushMatrix();
    textSize(20);
    translate(plotX - 80, plotY + plotH/2);
    rotate(-HALF_PI);
    textAlign(CENTER, CENTER);
    text("Average Delay (minutes)", 0, 0);
    popMatrix();
    
    // Draw right Y-axis (Cancellation Rate).
    float rightX = plotX + plotW;
    stroke(0);
    line(rightX, plotY, rightX, plotY+plotH);
    textAlign(LEFT, CENTER);
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCancelRate);
      float ypos = map(i, 0, yTicks, plotY+plotH, plotY);
      line(rightX, ypos, rightX+5, ypos);
      text(nf(val*100, 0, 1)+"%", rightX+10, ypos);
    }
    
    // Add right y-axis label.
    pushMatrix();
    textSize(20);
    translate(rightX + 100, plotY + plotH/2);
    rotate(HALF_PI);
    textAlign(CENTER, CENTER);
    text("Cancellation Rate (%)", 0, 0);
    popMatrix();
    
    // Draw X-axis.
    stroke(0);
    line(plotX, plotY+plotH, plotX+plotW, plotY+plotH);
    textAlign(CENTER, TOP);
    
    // Calculate group width and barWidth.
    float groupWidth = plotW / itemsToShow;
    float barWidth = groupWidth / 3;
    
    // We'll draw the grouped bars first, so we can compute their boundaries to restrict text.
    for (int i = 0; i < itemsToShow; i++) {
      float groupX = plotX + i * groupWidth;
      float d = avgDelays.get(i);
      float c = cancelRates.get(i);
      float delayH = map(d, 0, maxAvgDelay, 0, plotH) * animationProgress;
      float cancelH = map(c, 0, maxCancelRate, 0, plotH) * animationProgress;
      
      float bx1 = groupX + groupWidth/2 - barWidth - 4; // left (blue) bar
      float by1 = plotY + plotH - delayH;
      fill(0, 0, 200);
      rect(bx1, by1, barWidth, delayH);
      fill(0);
      textAlign(CENTER, BOTTOM);
      textSize(14);
      text(nf(d, 0, 1), bx1 + barWidth/2, by1 - 2);
      
      float bx2 = groupX + groupWidth/2 + 4; // right (red) bar
      float by2 = plotY + plotH - cancelH;
      fill(200, 0, 0);
      rect(bx2, by2, barWidth, cancelH);
      fill(0);
      text(nf(c*100, 0, 1)+"%", bx2 + barWidth/2, by2 - 2);
    }
    
    // Now draw x-axis labels, restricting them between the bars.
    for (int i = 0; i < itemsToShow; i++) {
      float groupX = plotX + i * groupWidth;
      float tickX = groupX + groupWidth/2;
      // Draw tick mark on x-axis.
      line(tickX, plotY+plotH, tickX, plotY+plotH+5);
      
      // Identify boundaries:
      float blueLeft   = groupX + groupWidth/2 - barWidth - 4;   // left edge of blue bar
      float redLeft    = groupX + groupWidth/2 + 4;              // left edge of red bar
      float redRight   = redLeft + barWidth;                     // right edge of red bar
      
      // The total space available for the label is between blueLeft and redRight.
      float labelSpaceLeft  = blueLeft;
      float labelSpaceRight = redRight;
      float availableWidth  = labelSpaceRight - labelSpaceLeft;
      
      // Get the original airline label.
      String label = airlines.get(i);
      
      // Wrap the label so that no line exceeds 'availableWidth'.
      textSize(16);
      String wrappedLabel = wrapText(label, availableWidth);
      
      // Measure the widest line in the wrapped label to see how to center it.
      String[] labelLines = split(wrappedLabel, '\n');
      float widestLine = 0;
      for (String ln : labelLines) {
        float wLine = textWidth(ln);
        if (wLine > widestLine) {
          widestLine = wLine;
        }
      }
      
      // We'll attempt to center the label at tickX.
      float labelX = tickX;
      // But if it extends beyond the left boundary, we shift it right.
      if (labelX - widestLine/2 < labelSpaceLeft) {
        labelX = labelSpaceLeft + widestLine/2;
      }
      // Or if it extends beyond the right boundary, we shift it left.
      if (labelX + widestLine/2 > labelSpaceRight) {
        labelX = labelSpaceRight - widestLine/2;
      }
      
      // Draw the wrapped text line by line, top-aligned at (labelX, plotY+plotH+8).
      float textLineHeight = textAscent() + textDescent();
      float startY = plotY + plotH + 8;
      for (int lineIndex = 0; lineIndex < labelLines.length; lineIndex++) {
        float lineW = textWidth(labelLines[lineIndex]);
        // We'll center each line around labelX so it looks neat, 
        // or you could left-align if you prefer.
        float lineX = labelX;
        textAlign(CENTER, TOP);
        text(labelLines[lineIndex], lineX, startY + lineIndex * textLineHeight);
      }
    }
    
    // Draw legend.
    float legendX = plotX + 10;
    float legendY = plotY - 80;
    float boxSize = 20;
    noStroke();
    fill(0, 0, 200);
    rect(legendX, legendY, boxSize, boxSize);
    fill(0);
    textSize(16);
    textAlign(LEFT, CENTER);
    text("Avg Delay (min)", legendX + boxSize + 8, legendY + boxSize/2);
    fill(200, 0, 0);
    rect(legendX, legendY+25, boxSize, boxSize);
    fill(0);
    text("Cancellation Rate (%)", legendX + boxSize + 8, legendY + 25 + boxSize/2);
    
    // Chart titles.
    textAlign(CENTER, BOTTOM);
    textSize(20);
    text("Airlines", plotX + plotW/2, y + h - 8);
    textAlign(CENTER, TOP);
    textSize(24);
    text("Airline Performance", x + w/2, y - 20);
  }
  
  // Helper function to wrap text into multiple lines if its width exceeds maxWidth.
  // This ensures no single line in 'wrappedLabel' is wider than maxWidth.
  String wrapText(String txt, float maxWidth) {
    // Split the text into words.
    String[] words = splitTokens(txt, " ");
    String currentLine = "";
    String result = "";
    
    textSize(16); // Make sure textSize is set before measuring widths
    
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (currentLine.equals("")) {
        // First word on a line
        currentLine = word;
      } else {
        // Check if we can add another word without exceeding maxWidth
        String testLine = currentLine + " " + word;
        if (textWidth(testLine) > maxWidth) {
          // If adding the new word exceeds the maximum width, start a new line.
          if (result.equals("")) {
            result = currentLine;
          } else {
            result += "\n" + currentLine;
          }
          currentLine = word;  // this word goes on the new line
        } else {
          currentLine = testLine;
        }
      }
    }
    // Append any remaining words in currentLine.
    if (!currentLine.equals("")) {
      if (result.equals("")) {
        result = currentLine;
      } else {
        result += "\n" + currentLine;
      }
    }
    return result;
  }
}

// HistogramScreen.pde
// A class for drawing the histogram (Delay Distribution) screen.

class HistogramScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  HistogramScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    ArrayList<Integer> delays = new ArrayList<Integer>();
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        if (row.getString("cancelled").equalsIgnoreCase("true")) continue;
        int d = row.getInt("minutes_late");
        if (d < 0) d = 0;
        delays.add(d);
      }
    }
    
    if (delays.size() == 0) {
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(30);
      text("No delay data for histogram", x + w/2, y + h/2);
      return;
    }
    
    int maxDelay = 0;
    for (int d : delays) maxDelay = max(maxDelay, d);
    
    int binSize = 10;
    int numBins = ceil(maxDelay / float(binSize)) + 1;
    int[] bins = new int[numBins];
    for (int d : delays) {
      int binIndex = d / binSize;
      binIndex = constrain(binIndex, 0, numBins-1);
      bins[binIndex]++;
    }
    
    int maxCount = 0;
    for (int c : bins) maxCount = max(maxCount, c);
    
    float marginLeft = 60, marginRight = 30, marginTop = 40, marginBottom = 60;
    float plotX = x + marginLeft, plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight, plotH = h - marginTop - marginBottom;
    
    // Draw axes.
    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    line(plotX, plotY, plotX, plotY + plotH);
    
    float barWidth = plotW / numBins;
    textAlign(CENTER, BOTTOM);
    textSize(14);
    for (int i = 0; i < numBins; i++) {
      float barHeight = map(bins[i], 0, maxCount, 0, plotH) * animationProgress;
      float bx = plotX + i * barWidth;
      float by = plotY + plotH - barHeight;
      fill(100, 150, 255);
      noStroke();
      rect(bx, by, barWidth - 1, barHeight);
      fill(0);
      text(bins[i], bx + barWidth/2, by - 2);
    }
    
    // X-axis ticks and labels.
    textAlign(CENTER, TOP);
    for (int i = 0; i <= numBins; i++) {
      float bx = plotX + i * barWidth;
      line(bx, plotY + plotH, bx, plotY + plotH + 5);
      int rangeStart = i * binSize;
      text(rangeStart, bx, plotY + plotH + 8);
    }
    
    // Y-axis ticks.
    int yTicks = 5;
    textAlign(RIGHT, CENTER);
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCount);
      float ty = map(i, 0, yTicks, plotY + plotH, plotY);
      line(plotX - 5, ty, plotX, ty);
      text(int(val), plotX - 8, ty);
    }
    
    // Titles.
    textAlign(CENTER, TOP);
    textSize(22);
    text("Delay Distribution Histogram", x + w/2, y);
    textAlign(CENTER, BOTTOM);
    textSize(16);
    text("Minutes Late (binned)", plotX + plotW/2, y + h - 5);
    pushMatrix();
    translate(x + 15, plotY + plotH/2);
    rotate(-HALF_PI);
    text("Flight Count", 0, 0);
    popMatrix();
  }
}

class BubbleChartScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  BubbleChartScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    int[] counts = new int[24];
    int[] sumDelays = new int[24];
    
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        if (row.getString("cancelled").equalsIgnoreCase("true")) continue;
        String sched = row.getString("scheduled_departure");
        if (sched != null && sched.length() >= 13) {
          int hr = parseInt(sched.substring(11, 13));
          hr = constrain(hr, 0, 23);
          int d = row.getInt("minutes_late");
          if (d < 0) d = 0;
          counts[hr]++;
          sumDelays[hr] += d;
        }
      }
    }
    
    float[] avgDelay = new float[24];
    float maxDelay = 1;
    int maxCount = 0;
    for (int hr = 0; hr < 24; hr++) {
      if (counts[hr] > 0) {
        avgDelay[hr] = sumDelays[hr] / (float) counts[hr];
        maxDelay = max(maxDelay, avgDelay[hr]);
      }
      maxCount = max(maxCount, counts[hr]);
    }
    
    float marginLeft = 60, marginRight = 50, marginTop = 100, marginBottom = 70;
    float plotX = x + marginLeft, plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight, plotH = h - marginTop - marginBottom;
    
    // Draw axes.
    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    line(plotX, plotY, plotX, plotY + plotH);
    
    // X-axis labels.
    textSize(14);
    textAlign(CENTER, TOP);
    for (int hr = 0; hr <= 23; hr++) {
      float xx = map(hr, 0, 23, plotX, plotX + plotW);
      line(xx, plotY + plotH, xx, plotY + plotH + 5);
      text(hr, xx, plotY + plotH + 8);
    }
    
    // Y-axis ticks.
    int yTicks = 5;
    textAlign(RIGHT, CENTER);
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxDelay);
      float yy = map(i, 0, yTicks, plotY + plotH, plotY);
      line(plotX - 5, yy, plotX, yy);
      text(int(val), plotX - 8, yy);
    }
    
    // Titles.
    textAlign(CENTER, TOP);
    textSize(22);
    text("Bubble Chart: Hour vs. Avg Delay vs. Flight Count", x + w/2, y);
    textAlign(CENTER, BOTTOM);
    textSize(16);
    text("Scheduled Departure Hour", plotX + plotW/2, y + h - 5);
    pushMatrix();
    translate(x + 20, plotY + plotH/2);
    rotate(-HALF_PI);
    text("Avg Delay (minutes)", 0, 0);
    popMatrix();
    
    // Draw bubbles.
    noStroke();
    fill(100, 150, 255, 180);
    float maxBubbleRadius = 40;
    for (int hr = 0; hr < 24; hr++) {
      if (counts[hr] == 0) continue;
      float xx = map(hr, 0, 23, plotX, plotX + plotW);
      float yy = map(avgDelay[hr], 0, maxDelay, plotY + plotH, plotY);
      float bubbleR = map(counts[hr], 0, maxCount, 0, maxBubbleRadius) * animationProgress;
      ellipse(xx, yy, bubbleR * 2, bubbleR * 2);
      
      fill(0);
      textAlign(CENTER, CENTER);
      text(counts[hr], xx, yy);
      fill(100, 150, 255, 180);
    }
  }
}

// BarChartScreen.pde
// A class for drawing the bar chart (Top Destinations) screen.

class BarChartScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  BarChartScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    float marginLeft = 60, marginRight = 30;
    float marginTop = 80, marginBottom = 100;
    HashMap<String, Integer> destCounts = new HashMap<>();
    
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        String dest = row.getString("destination").trim();
        if (!dest.equals("")) {
          destCounts.put(dest, destCounts.getOrDefault(dest, 0) + 1);
        }
      }
    }
    ArrayList<Map.Entry<String, Integer>> destList = new ArrayList<>(destCounts.entrySet());
    Collections.sort(destList, (a, b) -> b.getValue().compareTo(a.getValue()));
    int itemsAvailable = destList.size();
    int itemsToShow = min(5, itemsAvailable);
    destList = new ArrayList<>(destList.subList(0, itemsToShow));
    
    // Sort alphabetically by full airport name (using a lookup if available).
    Collections.sort(destList, (a, b) -> {
      String nameA = airportLookup.getOrDefault(a.getKey(), a.getKey());
      String nameB = airportLookup.getOrDefault(b.getKey(), b.getKey());
      return nameA.compareToIgnoreCase(nameB);
    });
    
    float gap = 10;
    float plotW = w - marginLeft - marginRight;
    float plotH = h - marginTop - marginBottom;
    float barWidth = (plotW - gap*6) / 5.0;
    float plotX = x + marginLeft;
    float plotY = y + marginTop;
    
    // Draw axes.
    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    line(plotX, plotY, plotX, plotY + plotH);
    
    if (itemsAvailable < 5) {
      fill(255, 0, 0);
      textAlign(CENTER);
      textSize(18);
      text("Not enough destinations for a full top 5 list.", x + w / 2, y + 20);
    }
    
    int maxCount = 1;
    for (int i = 0; i < itemsToShow; i++) {
      maxCount = max(maxCount, destList.get(i).getValue());
    }
    
    float totalBarWidth = itemsToShow * barWidth + (itemsToShow - 1) * gap;
    float offsetX = (plotW - totalBarWidth) / 2;
    
    for (int i = 0; i < itemsToShow; i++) {
      Map.Entry<String, Integer> entry = destList.get(i);
      String code = entry.getKey();
      String fullLabel = airportLookup.get(code);
      if (fullLabel == null) fullLabel = code;
      int count = entry.getValue();
      
      float barHeight = map(count, 0, maxCount, 0, plotH) * animationProgress;
      float bx = plotX + offsetX + i*(barWidth + gap);
      float by = plotY + plotH - barHeight;
      
      fill(100, 150, 255);
      noStroke();
      rect(bx, by, barWidth, barHeight);
      
      fill(0);
      textSize(18);
      textAlign(CENTER, BOTTOM);
      text(count, bx + barWidth/2, by - 6);
      
      // Break the fullLabel into parts if needed.
      String line1 = fullLabel.contains("(")
          ? fullLabel.substring(0, fullLabel.indexOf("(")).trim()
          : fullLabel;
      String line2 = fullLabel.contains("(")
          ? fullLabel.substring(fullLabel.indexOf("("), fullLabel.indexOf(")") + 1).trim()
          : "";
      String[] labelLines = {line1, line2, code};
      float maxLabelWidth = barWidth + gap*2;
      float fitted = util.getFittedTextSize(labelLines, maxLabelWidth, 26);
      fitted = min(fitted, 24);
      textSize(fitted);
      textAlign(CENTER, TOP);
      for (int j = 0; j < labelLines.length; j++) {
        text(labelLines[j], bx + barWidth/2, plotY + plotH + 6 + j*(fitted + 2));
      }
    }
    
    // Draw Y-axis tick labels.
    textSize(16);
    textAlign(RIGHT, CENTER);
    int yTicks = 5;
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCount);
      float ypos = map(i, 0, yTicks, plotY + plotH, plotY);
      text(nf(round(val), 0), plotX - 8, ypos);
    }
    
    // Add chart titles.
    textAlign(CENTER, BOTTOM);
    textSize(22);
    text("Destination Airports", plotX + plotW/2, y + h);
    
    pushMatrix();
    translate(x + 5, plotY + plotH/2);
    rotate(-HALF_PI);
    textAlign(CENTER, TOP);
    text("Flight Count", 0, 0);
    popMatrix();
    
    textAlign(CENTER, TOP);
    textSize(22);
    text("Top 5 Destination Airports", x + w/2, y - 20);
  }
}
// ScatterPlotScreen.pde
// A class for drawing the scatter plot (Hour vs. Delay) screen.

class ScatterPlotScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  ScatterPlotScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    ArrayList<Float[]> points = new ArrayList<Float[]>();
    float maxDelay = 0;
    
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        if (row.getString("cancelled").equalsIgnoreCase("true")) continue;
        String sched = row.getString("scheduled_departure");
        if (sched != null && sched.length() >= 16) {
          String timePart = sched.substring(11, 16);
          String[] hhmm = split(timePart, ":");
          if (hhmm.length == 2) {
            int hr = parseInt(hhmm[0]);
            int mn = parseInt(hhmm[1]);
            float xVal = hr + mn/60.0;
            int d = row.getInt("minutes_late");
            if (d < 0) d = 0;
            maxDelay = max(maxDelay, d);
            points.add(new Float[]{ xVal, float(d) });
          }
        }
      }
    }
    
    if (points.size() == 0) {
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(30);
      text("No flight data for scatter plot", x + w/2, y + h/2);
      return;
    }
    
    float marginLeft = 60, marginRight = 30, marginTop = 50, marginBottom = 60;
    float plotX = x + marginLeft, plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight, plotH = h - marginTop - marginBottom;
    
    // Draw axes.
    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    line(plotX, plotY, plotX, plotY + plotH);
    
    // X-axis labels.
    textSize(16);
    textAlign(CENTER, TOP);
    for (int hr = 0; hr <= 23; hr++) {
      float xx = map(hr, 0, 24, plotX, plotX + plotW);
      line(xx, plotY + plotH, xx, plotY + plotH + 5);
      text(hr, xx, plotY + plotH + 8);
    }
    
    // Y-axis ticks.
    int yTicks = 5;
    textAlign(RIGHT, CENTER);
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxDelay);
      float yy = map(i, 0, yTicks, plotY + plotH, plotY);
      line(plotX - 5, yy, plotX, yy);
      text(int(val), plotX - 8, yy);
    }
    
    // Titles.
    textAlign(CENTER, TOP);
    textSize(22);
    text("Scatter: Departure Time vs. Delay", x + w/2, y);
    textAlign(CENTER, BOTTOM);
    textSize(18);
    text("Scheduled Departure (Hours)", plotX + plotW/2, y + h - 5);
    pushMatrix();
    translate(x + 15, plotY + plotH/2);
    rotate(-HALF_PI);
    text("Minutes Late", 0, 0);
    popMatrix();
    
    // Draw data points.
    noStroke();
    fill(0, 0, 255, 100);
    int totalPoints = points.size();
    int visiblePoints = int(totalPoints * animationProgress);
    for (int i = 0; i < visiblePoints; i++) {
      float xVal = points.get(i)[0];
      float dlay = points.get(i)[1];
      float xx = map(xVal, 0, 24, plotX, plotX + plotW);
      float yy = map(dlay, 0, maxDelay, plotY + plotH, plotY);
      ellipse(xx, yy, 5, 5);
    }
  }
}
class RadarChartScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  boolean showMonthly;
  String selectedDate; // NEW: selected date in "YYYY-MM-DD" format

  RadarChartScreen(String airport, ProcessData data, float animationProgress, boolean showMonthly) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
    this.showMonthly = showMonthly;
    this.selectedDate = null;
  }

  // Call this when a date is selected on the calendar
  void setSelectedDate(String date) {
    this.selectedDate = date;
    this.showMonthly = false;
  }

  // Optional: Call this to reset to monthly view
  void clearSelectedDate() {
    this.selectedDate = null;
    this.showMonthly = true;
  }

  void display(float x, float y, float w, float h) {
    float cx = x + w / 2;
    float cy = y + h / 2;
    float radius = min(w, h) * 0.35;

    int spokes = showMonthly ? 12 : 24;
    int[] counts = new int[spokes];
    int maxCount = 1;

    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        String sched = row.getString("scheduled_departure");
        if (sched == null || sched.length() < 13) continue;

        if (selectedDate != null && sched.startsWith(selectedDate)) {
          int hr = parseInt(sched.substring(11, 13));
          if (hr >= 0 && hr < 24) {
            counts[hr]++;
            maxCount = max(maxCount, counts[hr]);
          }
        } else if (selectedDate == null) {
          if (showMonthly && sched.length() >= 7) {
            int m = parseInt(sched.substring(5, 7)) - 1;
            if (m >= 0 && m < 12) {
              counts[m]++;
              maxCount = max(maxCount, counts[m]);
            }
          } else if (!showMonthly && sched.length() >= 13) {
            int hr = parseInt(sched.substring(11, 13));
            if (hr >= 0 && hr < 24) {
              counts[hr]++;
              maxCount = max(maxCount, counts[hr]);
            }
          }
        }
      }
    }

    int rings = 5;
    int displayMax = max(1, ceil(maxCount / 5.0) * 5);
    int[] ringVals = new int[rings];
    for (int i = 0; i < rings; i++) {
      ringVals[i] = round((i + 1) * (displayMax / (float) rings));
    }

    stroke(0);
    noFill();
    textSize(14);
    textAlign(LEFT, CENTER);
    for (int i = 0; i < rings; i++) {
      float rr = (i + 1) / (float) rings * radius;
      ellipse(cx, cy, rr * 2, rr * 2);
      fill(0);
      text(ringVals[i], cx + 5, cy - rr);
      noFill();
      stroke(0);
    }

    // Draw spokes
    for (int i = 0; i < spokes; i++) {
      float angle = -HALF_PI + i * (TWO_PI / spokes);
      float x2 = cx + radius * cos(angle);
      float y2 = cy + radius * sin(angle);
      stroke(0);
      line(cx, cy, x2, y2);
    }

    // Draw radar shape
    stroke(0, 0, 255);
    strokeWeight(2);
    fill(0, 0, 255, 40);
    beginShape();
    for (int i = 0; i < spokes; i++) {
      float angle = -HALF_PI + i * (TWO_PI / spokes);
      float value = map(counts[i], 0, displayMax, 0, radius) * animationProgress;
      float px = cx + value * cos(angle);
      float py = cy + value * sin(angle);
      vertex(px, py);
    }
    endShape(CLOSE);

    // Draw data points
    textAlign(CENTER, BOTTOM);
    textSize(14);
    for (int i = 0; i < spokes; i++) {
      int val = counts[i];
      float angle = -HALF_PI + i * (TWO_PI / spokes);
      float r = map(val, 0, displayMax, 0, radius) * animationProgress;
      float px = cx + r * cos(angle);
      float py = cy + r * sin(angle);
      fill(0, 0, 255);
      noStroke();
      ellipse(px, py, 6, 6);
      if (val > 0) {
        fill(0, 0, 255);
        text(val, px, py - 8);
      }
    }

    // Draw labels
    fill(0);
    textSize(14);
    textAlign(CENTER, CENTER);
    if (showMonthly) {
      String[] months = {
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      };
      for (int i = 0; i < 12; i++) {
        float angle = -HALF_PI + i * (TWO_PI / 12);
        float lx = cx + (radius + 30) * cos(angle);
        float ly = cy + (radius + 30) * sin(angle);
        text(months[i], lx, ly);
      }
    } else {
      for (int i = 0; i < 24; i++) {
        float angle = -HALF_PI + i * (TWO_PI / 24);
        float lx = cx + (radius + 25) * cos(angle);
        float ly = cy + (radius + 25) * sin(angle);
        String hh = nf(i, 2) + ":00";
        text(hh, lx, ly);
      }
    }
  }
}

// PieChartScreen.pde
// A class for drawing the Pie Chart graph screen.

class PieChartScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  PieChartScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    float cx = x + w/2;
    float cy = y + h/2;
    float dia = min(w, h) * 0.7;
    
    int onTime    = data.onTimeFlights;
    int delayed   = data.delayedFlights;
    int cancelled = data.cancelledFlights;
    int total     = max(1, onTime + delayed + cancelled);
    
    float angleOnTime    = TWO_PI * onTime / total;
    float angleDelayed   = TWO_PI * delayed / total;
    // Calculate angle for cancelled flights.
    float angleCancelled = TWO_PI - angleOnTime - angleDelayed;
    
    float anim = animationProgress;
    float startAngle = -HALF_PI;
    stroke(255);
    strokeWeight(2);
    
    fill(0, 200, 0);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleOnTime * anim);
    startAngle += angleOnTime * anim;
    
    fill(0, 0, 255);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleDelayed * anim);
    startAngle += angleDelayed * anim;
    
    fill(255, 0, 0);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleCancelled * anim);
    
    // Draw legend.
    float legendX = x + 30;
    float legendY = y + 30;
    float boxSize = 25;
    textAlign(LEFT, CENTER);
    textSize(18);
    noStroke();
    
    fill(0, 200, 0);
    rect(legendX, legendY, boxSize, boxSize);
    fill(0);
    text("On Time: " + onTime, legendX + boxSize + 10, legendY + boxSize/2);
    
    fill(0, 0, 255);
    rect(legendX, legendY + 35, boxSize, boxSize);
    fill(0);
    text("Delayed: " + delayed, legendX + boxSize + 10, legendY + 35 + boxSize/2);
    
    fill(255, 0, 0);
    rect(legendX, legendY + 70, boxSize, boxSize);
    fill(0);
    text("Cancelled: " + cancelled, legendX + boxSize + 10, legendY + 70 + boxSize/2);
  }
}

class LineGraphScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  LineGraphScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    // Margins around the plot area
    float marginLeft = 60, marginRight = 30, marginTop = 80, marginBottom = 50;
    
    // Compute the plotting region
    float plotX = x + marginLeft;
    float plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight;
    float plotH = h - marginTop - marginBottom;
    
    // Build hourly counts from data
    int[] hourCounts = new int[24];
    int maxCount = 1;
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        String sched = row.getString("scheduled_departure");
        if (sched != null && sched.length() >= 16) {
          String[] parts = split(sched, ' ');
          if (parts.length == 2) {
            int hr = constrain(parseInt(parts[1].substring(0, 2)), 0, 23);
            hourCounts[hr]++;
            if (hourCounts[hr] > maxCount) {
              maxCount = hourCounts[hr];
            }
          }
        }
      }
    }
    
    // Draw axes
    stroke(0);
    // X-axis
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    // Y-axis
    line(plotX, plotY, plotX, plotY + plotH);
    
    // Y-axis ticks and numeric labels using whole number increments.
    // Determine the best whole number step based on maxCount.
    textSize(16);
    textAlign(RIGHT, CENTER);
    
    int desiredTicks = 5;  // desired number of ticks along the y-axis
    // Calculate a tick increment that is at least 1
    int inc = max(1, (int)ceil(maxCount / (float)desiredTicks));
    // Round up maxCount to the nearest multiple of inc
    int tickMax = ((maxCount + inc - 1) / inc) * inc;
    int tickCount = tickMax / inc; // number of intervals
    
    for (int i = 0; i <= tickCount; i++) {
      int tickValue = i * inc;
      float ypos = map(tickValue, 0, tickMax, plotY + plotH, plotY);
      // Draw tick mark
      line(plotX - 5, ypos, plotX, ypos);
      // Draw whole-number label
      text(tickValue, plotX - 8, ypos);
    }
    
    // X-axis ticks and numeric labels
    textAlign(CENTER, TOP);
    for (int hr = 0; hr < 24; hr++) {
      float xpos = map(hr, 0, 23, plotX, plotX + plotW);
      line(xpos, plotY + plotH, xpos, plotY + plotH + 5);
      text(nf(hr, 2), xpos, plotY + plotH + 8);
    }
    
    // Extra spacing for the x-axis label
    textSize(20);
    textAlign(CENTER, TOP);
    text("Hour of Day", plotX + plotW / 2, plotY + plotH + 40);
    
    // Draw the y-axis label (rotated)
    pushMatrix();
      translate(x, y + h / 2);
      rotate(-HALF_PI);
      textAlign(CENTER, CENTER);
      textSize(18);
      text("Number of Flights", 0, 0);
    popMatrix();
    
    // Determine how many data points to show based on animation progress
    int visiblePoints = int(24 * animationProgress);
    visiblePoints = max(1, visiblePoints);
    
    // Compute x,y coordinates for each visible data point
    float[] xPoints = new float[visiblePoints];
    float[] yPoints = new float[visiblePoints];
    for (int i = 0; i < visiblePoints; i++) {
      xPoints[i] = map(i, 0, 23, plotX, plotX + plotW);
      yPoints[i] = map(hourCounts[i], 0, maxCount, plotY + plotH, plotY);
    }
    
    // Draw the two-tone fill under the line
    noStroke();
    for (int i = 0; i < visiblePoints - 1; i++) {
      // Alternate fill colors
      fill((i % 2 == 0) ? color(160, 190, 255) : color(100, 150, 255));
      beginShape();
        vertex(xPoints[i],   yPoints[i]);
        vertex(xPoints[i+1], yPoints[i+1]);
        vertex(xPoints[i+1], plotY + plotH);
        vertex(xPoints[i],   plotY + plotH);
      endShape(CLOSE);
    }
    
    // Draw the line on top
    noFill();
    stroke(0, 0, 255);
    strokeWeight(2);
    beginShape();
      for (int i = 0; i < visiblePoints; i++) {
        vertex(xPoints[i], yPoints[i]);
      }
    endShape();
    
    // Draw the data points with numeric labels.
    textSize(14);
    textAlign(CENTER, BOTTOM);
    for (int i = 0; i < visiblePoints; i++) {
      fill(0, 0, 255);
      noStroke();
      ellipse(xPoints[i], yPoints[i], 6, 6);
      fill(0);
      if (i == 0) {
        text(hourCounts[i], xPoints[i] + 15, yPoints[i] - 8);
      } else {
        text(hourCounts[i], xPoints[i], yPoints[i] - 8);
      }
    }
    
    // Graph Title at the top
    textAlign(CENTER, TOP);
    textSize(24);
    text("Hourly Flight Counts", x + w / 2, y);
  }
}
