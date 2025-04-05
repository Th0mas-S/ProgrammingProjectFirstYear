// AirportSelector.pde
// Handles displaying, searching, and selecting airports

import java.util.ArrayList;
import java.util.Collections;
import java.text.Normalizer;

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
  
  AirportSelector(String[] airports, StringLookup lookup) {
    this.airports = airports;
    this.airportLookup = lookup;
    
    float totalElementWidth = listWidth + listSliderGap + sliderWidth;
    listX = (width - totalElementWidth) / 2;
    listY = height / 2 - (itemsToShow * itemHeight) / 2;
    sliderX = listX + listWidth + listSliderGap;
    sliderY = listY;
    sliderHeight = itemsToShow * itemHeight;
    sliderPos = 0;
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
    if (millis() - lastBlinkTime > 500) {
      showCaret = !showCaret;
      lastBlinkTime = millis();
    }
    
    fill(0);
    textSize(40);
    textAlign(CENTER, CENTER);
    text("Select an Airport", width/2, listY - 100);
    
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
    
    if (searchFocused && textAlpha == 255 && showCaret) {
      String beforeCaret = searchQuery.substring(0, caretIndex);
      float caretX = listX + 16 + textWidth(beforeCaret);
      stroke(0);
      strokeWeight(2);
      line(caretX, searchBarY + 10, caretX, searchBarY + searchBarHeight - 10);
    }
    
    if (!searchQuery.isEmpty()) {
      fill(200);
      noStroke();
      ellipse(clearButtonX + clearButtonSize/2, clearButtonY + clearButtonSize/2, clearButtonSize, clearButtonSize);
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(16);
      text("X", clearButtonX + clearButtonSize/2, clearButtonY + clearButtonSize/2);
    }
    
    String[] filteredAirports = getFilteredAirports();
    topIndex = constrain(topIndex, 0, max(0, filteredAirports.length - itemsToShow));
    
    textAlign(CENTER, CENTER);
    textSize(24);
    for (int i = 0; i < itemsToShow; i++) {
      int index = topIndex + i;
      if (index < filteredAirports.length) {
        float currentItemY = listY + i * itemHeight;
        if (mouseX > listX && mouseX < listX + listWidth &&
            mouseY > currentItemY && mouseY < currentItemY + itemHeight) {
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
        // Lookup full name from airportLookup
        String fullName = airportLookup.get(code);
        if (fullName == null) fullName = code;
        text(fullName + " / " + code, listX + listWidth/2, currentItemY + itemHeight/2);
      }
    }
    
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
  
  String handleMousePressed(float mx, float my) {
    float searchBarHeight = 55;
    float searchBarY = listY - searchBarHeight - 20;
    float clearX = listX + listWidth - 28 - 10;
    float clearY = searchBarY + (searchBarHeight - 28)/2;
    
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
      return null;
    } else {
      searchFocused = false;
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
  
  String[] getFilteredAirports() {
    if (searchQuery == null || searchQuery.trim().isEmpty()) return airports;
    ArrayList<String> filtered = new ArrayList<String>();
    String query = normalize(searchQuery);
    for (String code : airports) {
      String fullName = airportLookup.get(code);
      if (fullName == null) fullName = code;
      String combined = fullName + " / " + code;
      String normalized = normalize(combined);
      if (normalized.contains(query)) {
        filtered.add(code);
      }
    }
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
