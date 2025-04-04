//-------------------------------------------------
// AirportSelector class
//-------------------------------------------------
class AirportSelector {
  String[] airports;
  int topIndex = 0;
  int itemsToShow = 10;
  float listWidth, itemHeight, listSliderGap, sliderWidth, sliderKnobHeight;
  float listX, listY, sliderX, sliderY, sliderHeight;
  boolean dragging = false;
  float sliderPos;
  String searchQuery = "";
  boolean searchActive = false;
  float searchW, searchH, searchX, searchY;
  String searchError = "";

  AirportSelector(String[] airports) {
    this.airports = airports;
    listWidth = 500;
    itemHeight = 40;
    listSliderGap = 20;
    sliderWidth = 20;
    sliderKnobHeight = 35;
    float totalElementWidth = listWidth + listSliderGap + sliderWidth;
    listX = (width - totalElementWidth) / 2;
    listY = 180;
    sliderX = listX + listWidth + listSliderGap;
    sliderY = listY;
    sliderHeight = itemsToShow * itemHeight;
    sliderPos = 0;
    searchW = listWidth;
    searchH = 45;
    searchX = listX;
    searchY = 100;
  }

  void display() {
    // Title
    fill(0);
    textSize(28);
    textAlign(CENTER, CENTER);
    text("Select an Airport", width/2, 60);

    // Draw search bar
    if (searchActive) {
        stroke(100, 150, 255);
        strokeWeight(2);
    } else {
       stroke(150);
       strokeWeight(1);
    }
    fill(255);
    rect(searchX, searchY, searchW, searchH, 5);
    noStroke();
    fill(searchQuery.isEmpty() ? 150 : 0);
    textSize(16);
    textAlign(LEFT, CENTER);
    String displayText = searchQuery.isEmpty() ? "Search by code or name..." : searchQuery;
    if (searchActive && frameCount % 60 < 30) {
      displayText += "|";
    }
    text(displayText, searchX + 10, searchY + searchH/2);

    // --- Draw List and Slider ---
    ArrayList<String> filtered = getFilteredList();
     if (!searchError.isEmpty()) {
      fill(255, 0, 0);
      textSize(14);
      textAlign(CENTER, BOTTOM);
      text(searchError, listX + listWidth/2, listY - 10);
    } else if (filtered.isEmpty() && !searchQuery.isEmpty()) {
       fill(100);
       textAlign(CENTER, CENTER);
       textSize(16);
       text("No matching airports found.", listX + listWidth/2, listY + sliderHeight/2);
    }

    // Draw list items
    textAlign(CENTER, CENTER);
    textSize(16);
    int displayCount = min(itemsToShow, filtered.size());
    for (int i = 0; i < displayCount; i++) {
      int index = topIndex + i;
      if (index < filtered.size()) {
        float currentItemY = listY + i * itemHeight;
        boolean isHovered = (mouseX > listX && mouseX < listX + listWidth && mouseY > currentItemY && mouseY < currentItemY + itemHeight);

        if (isHovered) {
          fill(200, 220, 255);
          stroke(100, 150, 255);
          strokeWeight(1);
        } else {
          fill(240);
          noStroke();
        }
        rect(listX, currentItemY, listWidth, itemHeight, 5);
        fill(0);
        String code = filtered.get(index);
        String fullName = airportNamesMap.getOrDefault(code, "Unknown Airport");
        text(code + " - " + fullName, listX + listWidth/2, currentItemY + itemHeight/2);
      }
    }
    noStroke();

    // Draw Slider (only if needed)
    if (filtered.size() > itemsToShow) {
      // Slider track
      fill(220);
      rect(sliderX, sliderY, sliderWidth, sliderHeight, 5);

      // Calculate knob position
      float availableTrackHeight = sliderHeight - sliderKnobHeight;
      float knobY = sliderY;
      int maxTopIndex = max(0, filtered.size() - itemsToShow);
      if (maxTopIndex > 0) {
         knobY = sliderY + ((float)topIndex / maxTopIndex) * availableTrackHeight;
      }
      knobY = constrain(knobY, sliderY, sliderY + availableTrackHeight);

      // Slider knob appearance
      boolean knobHover = (mouseX > sliderX && mouseX < sliderX + sliderWidth && mouseY > knobY && mouseY < knobY + sliderKnobHeight);
      if (dragging || knobHover) {
        fill(100, 150, 255);
      } else {
        fill(160);
      }
      rect(sliderX, knobY, sliderWidth, sliderKnobHeight, 5);
    }
  }

 String handleMousePressed(float mx, float my) {
    // Check search bar click
    if (mx > searchX && mx < searchX + searchW && my > searchY && my < searchY + searchH) {
      searchActive = true;
      return null;
    } else {
      searchActive = false; // Deactivate search if clicking elsewhere
    }

    // Check list item click
    ArrayList<String> filtered = getFilteredList();
    if (mx > listX && mx < listX + listWidth && my > listY && my < listY + min(itemsToShow, filtered.size()) * itemHeight) {
      int itemIndex = floor((my - listY) / itemHeight);
      int index = topIndex + itemIndex;
      if (index >= 0 && index < filtered.size()) {
        println("Selected: " + filtered.get(index));
        searchQuery = ""; // Clear search on selection
        searchActive = false;
        return filtered.get(index);
      }
    }
    return null;
  }


  void handleSliderMousePressed(float mx, float my) {
    ArrayList<String> filtered = getFilteredList();
    if (filtered.size() <= itemsToShow) return;

    int maxTopIndex = max(0, filtered.size() - itemsToShow);
    float availableTrackHeight = sliderHeight - sliderKnobHeight;
    float currentKnobY = sliderY;
    if (maxTopIndex > 0) {
       currentKnobY = sliderY + ((float)topIndex / maxTopIndex) * availableTrackHeight;
    }
     currentKnobY = constrain(currentKnobY, sliderY, sliderY + availableTrackHeight);

    // Check click on the knob itself
    if (mx > sliderX && mx < sliderX + sliderWidth && my >= currentKnobY && my <= currentKnobY + sliderKnobHeight) {
      dragging = true;
    }
    // Check click on the slider track (but not the knob) -> jump knob
    else if (mx > sliderX && mx < sliderX + sliderWidth && my >= sliderY && my <= sliderY + sliderHeight) {
      updateSlider(my); // Jump knob to click position
      dragging = true; // Allow dragging immediately after jumping
    }
  }

  void handleSliderMouseDragged(float mx, float my) {
    ArrayList<String> filtered = getFilteredList();
    if (filtered.size() <= itemsToShow) return;
    if (dragging) {
      updateSlider(my);
    }
  }

  void handleSliderMouseReleased() {
    dragging = false;
  }

 void updateSlider(float my) {
    ArrayList<String> filtered = getFilteredList();
    if (filtered.size() <= itemsToShow) return;

    float targetY = my - sliderY - (sliderKnobHeight / 2);
    float availableTrackHeight = sliderHeight - sliderKnobHeight;
    sliderPos = 0;
     if (availableTrackHeight > 0) {
        sliderPos = targetY / availableTrackHeight;
     }
    sliderPos = constrain(sliderPos, 0, 1);

    int maxTopIndex = max(0, filtered.size() - itemsToShow);
    topIndex = round(sliderPos * maxTopIndex);
    topIndex = constrain(topIndex, 0, maxTopIndex);
  }

  void updateScrollIndex(float e) {
    ArrayList<String> filtered = getFilteredList();
    if (filtered.size() <= itemsToShow) return;
    int maxTopIndex = max(0, filtered.size() - itemsToShow);

    if (e < 0) { // Scroll up
      topIndex = max(0, topIndex - 1);
    } else if (e > 0) { // Scroll down
      topIndex = min(maxTopIndex, topIndex + 1);
    }

    // Update slider position based on new topIndex
    sliderPos = maxTopIndex > 0 ? (float)topIndex / maxTopIndex : 0;
  }

 void updateSearch(String key) {
    if (searchActive) {
      if (key.equals("\b")) { // Handle backspace
        if (searchQuery.length() > 0) {
          searchQuery = searchQuery.substring(0, searchQuery.length()-1);
        }
      } else if (key.equals("\n") || key.equals("\r")) { // Handle Enter/Return
        searchActive = false; // Deactivate search on enter
      } else {
         char k = key.charAt(0);
          if (Character.isLetterOrDigit(k) || Character.isWhitespace(k) || k == '-' || k == '(' || k == ')') {
           searchQuery += key;
         }
      }
      topIndex = 0;
      sliderPos = 0;
      searchError = "";
      ArrayList<String> tempFiltered = getFilteredList();
      if (tempFiltered.isEmpty() && !searchQuery.isEmpty()) {
          searchError = "No matching airports found.";
      }
    }
  }

  ArrayList<String> getFilteredList() {
    ArrayList<String> filtered = new ArrayList<String>();
    String queryLower = searchQuery.toLowerCase().trim();

    if (queryLower.isEmpty()) {
       return new ArrayList<String>(java.util.Arrays.asList(airports));
    }

    for (String code : airports) {
      String fullName = airportNamesMap.getOrDefault(code, "").toLowerCase();
      String codeLower = code.toLowerCase();

      if (codeLower.contains(queryLower) || fullName.contains(queryLower)) {
        filtered.add(code);
      }
    }
    return filtered;
  }
}
