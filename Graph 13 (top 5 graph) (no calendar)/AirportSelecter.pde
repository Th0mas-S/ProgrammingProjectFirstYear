// AirportSelector.pde
// Handles displaying, searching, and selecting airports.
// The sort menu is positioned to the left of the airport list.
// Each drop-down item now has rounded corners to match the menu header.

import java.util.ArrayList;
import java.util.Collections;
import java.text.Normalizer;
import java.util.Comparator;

// Define enums for sort field and order
enum SortField {
  CODE,
  NAME,
  COUNTRY
}

enum SortOrder {
  ASC,
  DESC
}

class AirportSelector {
  String[] airports;
  int topIndex = 0;
  int itemsToShow = 6;
  
  float listWidth = 1000;
  float itemHeight = 80;
  float listSliderGap = 30;
  float sliderWidth = 30;
  float sliderKnobHeight = 60;
  float listX, listY;
  float sliderX, sliderY, sliderHeight;
  
  boolean dragging = false;
  float sliderPos;
  
  String searchQuery = "";
  boolean searchFocused = false;
  int lastBlinkTime = 0;
  boolean showCaret = true;
  int caretIndex = 0;
  int selectionStart = 0;
  int selectionEnd = 0;
  boolean selectingText = false;
  
  StringLookup airportLookup;
  
  // Default sort mode changed to Airport Code (A-Z)
  SortField sortField = SortField.CODE;  
  SortOrder sortOrder = SortOrder.ASC;
  // Drop-down sort menu layout (positioned to the left of the airport list)
  float sortMenuW, sortMenuH, sortMenuX, sortMenuY;
  boolean sortMenuOpen = false;          // Whether the drop-down is open
  // Define drop-down options: each is a pair [SortField, SortOrder]
  Option[] sortOptions;
  float optionHeight = 40;  // For readability
  
  // Helper class for a sort option
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
  
  AirportSelector(String[] airports, StringLookup lookup) {
    this.airports = airports;
    this.airportLookup = lookup;
    
    float totalElementWidth = listWidth + listSliderGap + sliderWidth;
    // Center the list horizontally
    listX = (width - totalElementWidth) / 2;
    listY = height / 2 - (itemsToShow * itemHeight) / 2;
    sliderX = listX + listWidth + listSliderGap;
    sliderY = listY;
    sliderHeight = itemsToShow * itemHeight;
    sliderPos = 0;
    
    // Setup search bar (above the list)
    float searchBarHeight = 55;
    float searchBarY = listY - searchBarHeight - 20;
    
    // Sort menu dimensions
    sortMenuW = 280;
    sortMenuH = 55;
    // Position the sort menu to the LEFT of the airport list
    sortMenuX = listX - sortMenuW - 10;
    sortMenuY = searchBarY; // align with the search bar's vertical position
    
    // Initialize the drop-down options with new labels
    sortOptions = new Option[6];
    sortOptions[0] = new Option(SortField.CODE,    SortOrder.ASC,  "Airport Code (A–Z)");
    sortOptions[1] = new Option(SortField.CODE,    SortOrder.DESC, "Airport Code (Z–A)");
    sortOptions[2] = new Option(SortField.NAME,    SortOrder.ASC,  "Airport Name (A–Z)");
    sortOptions[3] = new Option(SortField.NAME,    SortOrder.DESC, "Airport Name (Z–A)");
    sortOptions[4] = new Option(SortField.COUNTRY, SortOrder.ASC,  "Country Name (A–Z)");
    sortOptions[5] = new Option(SortField.COUNTRY, SortOrder.DESC, "Country Name (Z–A)");
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
  
  void display() {
    // Handle caret blinking
    if (millis() - lastBlinkTime > 500) {
      showCaret = !showCaret;
      lastBlinkTime = millis();
    }
    
    // Draw title
    fill(0);
    textSize(40);
    textAlign(CENTER, CENTER);
    text("Select an Airport", width/2, listY - 100);
    
    // Draw search bar
    float searchBarHeight = 55;
    float searchBarY = listY - searchBarHeight - 20;
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
    String displayText = searchQuery.isEmpty() ? "Search airports..." : searchQuery;
    int textAlpha = searchQuery.isEmpty() ? 120 : 255;
    fill(0, textAlpha);
    text(displayText, listX + 16, searchBarY + searchBarHeight/2);
    
    // Selection highlight in search text
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
    
    // Caret
    if (searchFocused && textAlpha == 255 && showCaret) {
      String beforeCaret = searchQuery.substring(0, caretIndex);
      float caretX = listX + 16 + textWidth(beforeCaret);
      stroke(0);
      strokeWeight(2);
      line(caretX, searchBarY + 10, caretX, searchBarY + searchBarHeight - 10);
    }
    
    // Clear button
    if (!searchQuery.isEmpty()) {
      fill(200);
      noStroke();
      ellipse(clearButtonX + clearButtonSize/2, clearButtonY + clearButtonSize/2, clearButtonSize, clearButtonSize);
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(16);
      text("X", clearButtonX + clearButtonSize/2, clearButtonY + clearButtonSize/2);
    }
    
    // Draw the airport list
    drawAirportList();
    
    // Draw the drop-down sort menu last (so it appears on top)
    drawSortMenu();
  }
  
  void drawAirportList() {
    String[] filteredAirports = getFilteredAirports();
    topIndex = constrain(topIndex, 0, max(0, filteredAirports.length - itemsToShow));
    
    textAlign(CENTER, CENTER);
    textSize(24);
    for (int i = 0; i < itemsToShow; i++) {
      int index = topIndex + i;
      float currentItemY = listY + i * itemHeight;
      
      // If mouse is over the sort menu, skip tile highlight
      boolean overMenu = false;
      if (mouseX > sortMenuX && mouseX < sortMenuX + sortMenuW &&
          mouseY > sortMenuY && mouseY < sortMenuY + sortMenuH) {
        overMenu = true;
      }
      // If the menu is open, also check that region
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
        text(fullName + " / " + code, listX + listWidth/2, currentItemY + itemHeight/2);
      }
    }
    
    // Slider
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
  
  // Draws the sort menu header + drop-down items (if open) with rounded corners.
  void drawSortMenu() {
    // Draw header (rounded)
    fill(255);
    stroke(150);
    strokeWeight(2);
    rect(sortMenuX, sortMenuY, sortMenuW, sortMenuH, 10);
    
    fill(0);
    textSize(20);
    textAlign(LEFT, CENTER);
    text("Sort by:", sortMenuX + 10, sortMenuY + sortMenuH/2);
    
    String currentOption = "";
    if (sortField == SortField.CODE) {
      currentOption = (sortOrder == SortOrder.ASC) ? "Airport Code (A–Z)" : "Airport Code (Z–A)";
    } else if (sortField == SortField.NAME) {
      currentOption = (sortOrder == SortOrder.ASC) ? "Airport Name (A–Z)" : "Airport Name (Z–A)";
    } else if (sortField == SortField.COUNTRY) {
      currentOption = (sortOrder == SortOrder.ASC) ? "Country Name (A–Z)" : "Country Name (Z–A)";
    }
    
    textAlign(RIGHT, CENTER);
    text(currentOption, sortMenuX + sortMenuW - 10, sortMenuY + sortMenuH/2);
    
    // If drop-down is open, draw each item as a rounded rectangle
    if (sortMenuOpen) {
      float totalOptionsHeight = sortOptions.length * optionHeight;
      for (int i = 0; i < sortOptions.length; i++) {
        float optionY = sortMenuY + sortMenuH + i * optionHeight;
        
        // Check hover
        boolean hovered = (mouseX > sortMenuX && mouseX < sortMenuX + sortMenuW &&
                           mouseY > optionY && mouseY < optionY + optionHeight);
        if (hovered) {
          fill(200);
        } else {
          fill(255);
        }
        stroke(150);
        strokeWeight(2);
        rect(sortMenuX, optionY, sortMenuW, optionHeight, 10); // Rounded corners
        
        fill(0);
        textSize(18);
        textAlign(LEFT, CENTER);
        text(sortOptions[i].label, sortMenuX + 10, optionY + optionHeight/2);
      }
    }
  }
  
  // Handle mouse pressed events.
  String handleMousePressed(float mx, float my) {
    float searchBarHeight = 55;
    float searchBarY = listY - searchBarHeight - 20;
    float clearX = listX + listWidth - 28 - 10;
    float clearY = searchBarY + (searchBarHeight - 28)/2;
    
    // Clear button
    if (!searchQuery.isEmpty()) {
      if (mx > clearX && mx < clearX + 28 && my > clearY && my < clearY + 28) {
        searchQuery = "";
        caretIndex = 0;
        clearSelection();
        resetScroll();
        return null;
      }
    }
    
    // Click in search bar area
    if (mx > listX && mx < listX + listWidth && my > searchBarY && my < searchBarY + searchBarHeight) {
      searchFocused = true;
      float relativeX = mx - (listX + 16);
      caretIndex = getCaretFromX(relativeX);
      selectionStart = selectionEnd = caretIndex;
      selectingText = true;
      // Also close sort menu
      sortMenuOpen = false;
      return null;
    } else {
      searchFocused = false;
    }
    
    // Check if click is within the sort menu header
    if (mx > sortMenuX && mx < sortMenuX + sortMenuW &&
        my > sortMenuY && my < sortMenuY + sortMenuH) {
      sortMenuOpen = !sortMenuOpen;
      return null;
    }
    
    // If drop-down is open, check if an option is clicked
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
    
    // Check for airport selection
    String[] filteredAirports = getFilteredAirports();
    if (mx > listX && mx < listX + listWidth && my > listY && my < listY + itemsToShow * itemHeight) {
      int itemIndex = floor((my - listY) / itemHeight);
      int index = topIndex + itemIndex;
      if (index >= 0 && index < filteredAirports.length) {
        println("Selected: " + filteredAirports[index]);
        return filteredAirports[index];
      }
    }
    
    // Elsewhere => close the menu
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
  
  void handleSliderMouseDragged(float mx, float my) {
    if (dragging) {
      updateSlider(my);
    }
  }
  
  void handleSliderMouseReleased() {
    dragging = false;
    selectingText = false;
  }
  
  void updateSlider(float my) {
    String[] filteredAirports = getFilteredAirports();
    if (filteredAirports.length <= itemsToShow) return;
    float targetY = my - sliderY - (sliderKnobHeight/2);
    float availableTrackHeight = sliderHeight - sliderKnobHeight;
    sliderPos = (availableTrackHeight <= 0) ? 0 : targetY / availableTrackHeight;
    sliderPos = constrain(sliderPos, 0, 1);
    int maxTopIndex = max(0, filteredAirports.length - itemsToShow);
    topIndex = round(sliderPos * maxTopIndex);
    topIndex = constrain(topIndex, 0, maxTopIndex);
  }
  
  // Returns the filtered and sorted list of airport codes.
  String[] getFilteredAirports() {
    ArrayList<String> filtered = new ArrayList<String>();
    String q = normalize(searchQuery);
    for (String code : airports) {
      String label = airportLookup.get(code);  // e.g. "Annaba Airport (Annaba, Algeria)"
      if (label == null) label = code;
      String combined = label + " / " + code; 
      if (normalize(combined).contains(q)) {
        filtered.add(code);
      }
    }
    
    // Sort the filtered list using a custom comparator.
    Collections.sort(filtered, new Comparator<String>() {
      public int compare(String c1, String c2) {
        String label1 = airportLookup.get(c1);
        String label2 = airportLookup.get(c2);
        if (label1 == null) label1 = c1;
        if (label2 == null) label2 = c2;
        
        // For CODE sorting
        String code1 = c1;
        String code2 = c2;
        
        // For NAME sorting (take text before "(" if available)
        String name1 = label1;
        String name2 = label2;
        if (name1.contains("(")) name1 = name1.substring(0, name1.indexOf("(")).trim();
        if (name2.contains("(")) name2 = name2.substring(0, name2.indexOf("(")).trim();
        
        // For COUNTRY sorting (extract country from text inside parentheses)
        String country1 = "";
        String country2 = "";
        int open1 = label1.indexOf("(");
        int close1 = label1.indexOf(")");
        if (open1 >= 0 && close1 > open1) {
          String inside1 = label1.substring(open1+1, close1).trim();
          int commaPos = inside1.lastIndexOf(",");
          if (commaPos >= 0 && commaPos < inside1.length()-1) {
            country1 = inside1.substring(commaPos+1).trim();
          } else {
            country1 = inside1;
          }
        }
        int open2 = label2.indexOf("(");
        int close2 = label2.indexOf(")");
        if (open2 >= 0 && close2 > open2) {
          String inside2 = label2.substring(open2+1, close2).trim();
          int commaPos = inside2.lastIndexOf(",");
          if (commaPos >= 0 && commaPos < inside2.length()-1) {
            country2 = inside2.substring(commaPos+1).trim();
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
    
    return filtered.toArray(new String[0]);
  }
  
  String normalize(String text) {
    return Normalizer.normalize(text, Normalizer.Form.NFD)
                     .replaceAll("\\p{M}", "")
                     .toLowerCase()
                     .trim()
                     .replaceAll("\\s+", " ");
  }
}
