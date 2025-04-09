
import java.text.Normalizer;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Map;


// --------------------------------------------------------------------------
// AirportSelectorMenu Class
// --------------------------------------------------------------------------

final int SEARCH_CHAR_LIMIT = 70;  

class AirportSelectorMenu extends Screen {
  String[] airports;
  int topIndex = 0;
  int itemsToShow = 6;
  float listWidth = 0.5 * width;
  float itemHeight = 80;
  float listSliderGap = 30;
  float sliderWidth = 30;
  float sliderKnobHeight = 60;  // Slider knob height
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
  
  int displayStart = 0;
  
  StringLookup airportLookup;
  
  PImage logo;  // The FlightHub logo
  
  SortField sortField = SortField.CODE;  
  SortOrder sortOrder = SortOrder.ASC;
  
  // Sort menu dimensions (the dropdown will appear below the sort button)
  float sortMenuW, sortMenuH = 55, sortMenuX, sortMenuY;
  boolean sortMenuOpen = false;
  Option[] sortOptions;
  float optionHeight = 40;
  
  // Fields for the combined control (sort button + search bar)
  float sortButtonX, sortButtonWidth;
  float searchBarX, searchBarWidth;
  
  // Field to store the Y position of the combined control.
  float controlYPos;
  
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
    
    // Initialize sort options.
    sortOptions = new Option[6];
    sortOptions[0] = new Option(SortField.CODE,    SortOrder.ASC,  "Code (A–Z)");
    sortOptions[1] = new Option(SortField.CODE,    SortOrder.DESC, "Code (Z–A)");
    sortOptions[2] = new Option(SortField.NAME,    SortOrder.ASC,  "Airport (A–Z)");
    sortOptions[3] = new Option(SortField.NAME,    SortOrder.DESC, "Airport (Z–A)");
    sortOptions[4] = new Option(SortField.COUNTRY, SortOrder.ASC,  "Country (A–Z)");
    sortOptions[5] = new Option(SortField.COUNTRY, SortOrder.DESC, "Country (Z–A)");
  }
  
  void setCaretIndex(int newIndex) {
    caretIndex = constrain(newIndex, 0, searchQuery.length());
  
    float textPaddingLeft = 16;
    float textPaddingRight = 60; 
    float textAreaWidth = searchBarWidth - textPaddingLeft - textPaddingRight;
    
    String fullText = searchQuery;
    int desiredStart = caretIndex;
    
    while (desiredStart > 0 && textWidth(fullText.substring(desiredStart - 1, caretIndex)) < textAreaWidth) {
      desiredStart--;
    }
    displayStart = desiredStart;
  }
  
  void recalcLayout() {
    // Offset to shift the entire UI down.
    float yOffset = 100;
    
    listWidth = 0.5 * width;  
    itemHeight = 80;
    float totalElementWidth = listWidth + listSliderGap + sliderWidth;
    listX = (width - totalElementWidth) / 2;
    listY = (height / 2 - (itemsToShow * itemHeight) / 2) + yOffset;
    
    sliderX = listX + listWidth + listSliderGap;
    sliderY = listY;
    sliderHeight = itemsToShow * itemHeight;
    
    // The combined control (sort button + search bar) sits above the list.
    float controlHeight = 55;
    float controlY = listY - controlHeight - 20;
    
    // Set a 10:1 ratio: sort button takes 1/11 of listWidth and search bar the remaining 10/11.
    sortButtonWidth = 1.5 * listWidth / 11.0f;
    searchBarWidth = listWidth - sortButtonWidth;
    
    // Position the sort button at the left edge of the list.
    sortButtonX = listX;
    // Place the search bar immediately to the right of the sort button.
    searchBarX = sortButtonX + sortButtonWidth;
    
    // Set the sort menu to align with the sort button.
    sortMenuW = sortButtonWidth;
    sortMenuX = sortButtonX;
    sortMenuY = controlY;
    
    // Save the control Y position for drawing the combined control.
    controlYPos = controlY;
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
  display();
  menu.draw();
  back.draw();

    // Draw stars from the various star arrays.
  Star[][] starArrays = { stars, moreStars, evenMoreStars };
  for (Star[] starArray : starArrays) {
    for (Star star : starArray) {
      star.update();
      star.display();
    }
  }
}

void display() {
  recalcLayout();
  
  // Blink caret every 500ms.
  if (millis() - lastBlinkTime > 500) {
    showCaret = !showCaret;
    lastBlinkTime = millis();
  }
  
  float controlHeight = 55;
  float controlY = controlYPos; // top Y for both sort button and search bar
  
  // Determine hover status for each control.
  boolean hoverSort = (mouseX > sortButtonX && mouseX < sortButtonX + sortButtonWidth &&
                         mouseY > controlY && mouseY < controlY + controlHeight);
  boolean hoverSearch = (mouseX > searchBarX && mouseX < searchBarX + searchBarWidth &&
                           mouseY > controlY && mouseY < controlY + controlHeight);
  
  // Draw the FlightHub logo above the combined control.
  if (logo != null) {
    float desiredLogoWidth = listWidth * 0.75;
    float aspect = (float) logo.height / logo.width;
    float desiredLogoHeight = desiredLogoWidth * aspect;
    float marginAboveControl = -140;
    float centerX = width / 2;
    float centerY = controlY - marginAboveControl - (desiredLogoHeight / 2);
    imageMode(CENTER);
    image(logo, centerX, centerY, desiredLogoWidth, desiredLogoHeight);
  }
  
  // --- Conditional layering: Draw the non-hovered control first so the hovered one is on top.
  if (hoverSort && !hoverSearch) {
    drawSearchBarBubble();
    drawSortButtonBubble();
  } else if (hoverSearch && !hoverSort) {
    drawSortButtonBubble();
    drawSearchBarBubble();
  } else {
    drawSortButtonBubble();
    drawSearchBarBubble();
  }
  
  // Draw the airport list.
  drawAirportList();
  
  // Draw the sort menu on top.
  drawSortMenu();
}

// --------------------------------------------------------------------------
// Helper function to draw the sort button (bubble style).
void drawSortButtonBubble() {
  float controlHeight = 55;
  float controlY = controlYPos;
  
  // --- Draw the sort button ---
  fill(255);
  // Change stroke color if the sort menu is open or if the sort button is hovered.
  if (sortMenuOpen || (mouseX > sortButtonX && mouseX < sortButtonX + sortButtonWidth &&
      mouseY > controlY && mouseY < controlY + controlHeight)) {
    stroke(color(0, 120, 255));
  } else {
    stroke(150);
  }
  strokeWeight(2);
  // Fully rounded bubble: all sides with radius 10.
  rect(sortButtonX, controlY, sortButtonWidth, controlHeight, 10);
  
  // --- Draw the label in the sort button ---
  fill(0);
  textSize(20);
  textAlign(CENTER, CENTER);
  String currentOption = "";
  if (sortField == SortField.CODE) {
    currentOption = (sortOrder == SortOrder.ASC) ? "Code A–Z" : "Code Z–A";
  } else if (sortField == SortField.NAME) {
    currentOption = (sortOrder == SortOrder.ASC) ? "Name A–Z" : "Name Z–A";
  } else if (sortField == SortField.COUNTRY) {
    currentOption = (sortOrder == SortOrder.ASC) ? "Country A–Z" : "Country Z–A";
  }
  text(currentOption, sortButtonX + sortButtonWidth / 2, controlY + controlHeight / 2);
}

// --------------------------------------------------------------------------
// Helper function to draw the search bar (bubble style).
void drawSearchBarBubble() {
  float controlHeight = 55;
  float controlY = controlYPos;
  // Dimensions for the clear button.
  float clearButtonSize = 28;
  float clearButtonX = searchBarX + searchBarWidth - clearButtonSize - 10;
  float clearButtonY = controlY + (controlHeight - clearButtonSize) / 2;
  
  // --- Draw the search bar background ---
  fill(255);
  // Use a highlighted stroke if the search bar is focused or hovered.
  if (searchFocused || (mouseX > searchBarX && mouseX < searchBarX + searchBarWidth &&
      mouseY > controlY && mouseY < controlY + controlHeight)) {
    stroke(color(0, 120, 255));
  } else {
    stroke(150);
  }
  strokeWeight(2);
  // Fully rounded bubble: all sides with radius 10.
  rect(searchBarX, controlY, searchBarWidth, controlHeight, 10);
  
  // --- Draw the search text ---
  textAlign(LEFT, CENTER);
  textSize(24);
  
  String fullText;
  int textAlpha;
  if (searchQuery.isEmpty() && !searchFocused) {
    fullText = "Search airports...";
    textAlpha = 120;
  } else {
    fullText = searchQuery;
    textAlpha = 255;
  }
  fill(0, textAlpha);
  
  // Ensure the visible text fits within the search bar.
  String visibleText = fullText.substring(displayStart);
  while (visibleText.length() > 0 && textWidth(visibleText) > searchBarWidth - 60) {
    visibleText = visibleText.substring(1);
    displayStart++;
  }
  
  float textPadding = 16;
  float textX = searchBarX + textPadding;
  float textY = controlY + controlHeight / 2;
  text(visibleText, textX, textY);
  
  // --- Draw text selection highlight if any ---
  if (searchFocused && selectionStart != selectionEnd) {
    int selStart = min(selectionStart, selectionEnd);
    int selEnd = max(selectionStart, selectionEnd);
    
    int highlightStart = max(selStart, displayStart);
    int highlightEnd = min(selEnd, fullText.length());
    if (highlightEnd > highlightStart) {
      String beforeSelection = fullText.substring(displayStart, highlightStart);
      float highlightX = textX + textWidth(beforeSelection);
      
      String selectionString = fullText.substring(highlightStart, highlightEnd);
      float selectionWidth = textWidth(selectionString);
      
      float highlightY = controlY + 10;
      float highlightH = controlHeight - 20;
      
      noStroke();
      fill(200, 220, 255, 150);
      rect(highlightX, highlightY, selectionWidth, highlightH, 10);
    }
  }
  
  // --- Draw the caret if focused ---
  if (searchFocused && textAlpha == 255 && showCaret) {
    float caretOffset = 0;
    if (caretIndex > displayStart) {
      String caretSub = fullText.substring(displayStart, caretIndex);
      caretOffset = textWidth(caretSub);
    }
    float caretX = searchBarX + textPadding + caretOffset;
    stroke(0);
    strokeWeight(2);
    line(caretX, controlY + 10, caretX, controlY + controlHeight - 10);
  }
  
  // --- Draw the clear ("X") button if there is text ---
  if (!searchQuery.isEmpty()) {
    fill(200);
    noStroke();
    ellipse(clearButtonX + clearButtonSize / 2, clearButtonY + clearButtonSize / 2,
            clearButtonSize, clearButtonSize);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(16);
    text("X", clearButtonX + clearButtonSize / 2, clearButtonY + clearButtonSize / 2);
  }
}

void drawTiles() {
  String[] filteredAirports = getFilteredAirports();
  // Ensure topIndex is within a valid range.
  topIndex = constrain(topIndex, 0, max(0, filteredAirports.length - itemsToShow));
  
  textAlign(CENTER, CENTER);
  
  for (int i = 0; i < itemsToShow; i++) {
    int index = topIndex + i;
    float currentItemY = listY + i * itemHeight;

    // Check if mouse is over the tile
    boolean tileHovered = mouseX > listX && mouseX < listX + listWidth &&
                          mouseY > currentItemY && mouseY < currentItemY + itemHeight;

    // Check if the sort menu is open and overlaps this tile area
    boolean isOverSortMenu = sortMenuOpen &&
                             mouseX > sortMenuX && mouseX < sortMenuX + sortMenuW &&
                             mouseY > sortMenuY && mouseY < sortMenuY + sortMenuH + sortOptions.length * optionHeight;

    // If the sort menu is covering the tile, cancel the hover
    if (isOverSortMenu) {
      tileHovered = false;
    }

    if (index < filteredAirports.length) {
      if (tileHovered) {
        fill(120, 170, 255);  // Hover fill.
        stroke(50, 80, 150);  // Hover stroke.
        strokeWeight(1.5);
      } else {
        fill(100, 150, 255);  // Normal fill.
        noStroke();
      }
      
      rect(listX, currentItemY, listWidth, itemHeight, 12);
      
      // Prepare and draw the text label.
      String code = filteredAirports[index];
      String fullName = airportLookup.get(code);
      if (fullName == null) fullName = code;
      String label = fullName + " / " + code;
      
      float fontSize = 24;
      textSize(fontSize);
      while (textWidth(label) > listWidth - 20 && fontSize > 12) {
        fontSize--;
        textSize(fontSize);
      }
      fill(255);
      text(label, listX + listWidth / 2, currentItemY + itemHeight / 2);
    }
  }
}

void drawSliderMask() {
  noStroke();
  fill(0);  // Change if your background isn't pure black.
  rect(sliderX, sliderY, sliderWidth, sliderHeight);
}

void drawSlider() {
  String[] filteredAirports = getFilteredAirports();
  if (filteredAirports.length <= itemsToShow) return;
  
  fill(210);
  rect(sliderX, sliderY, sliderWidth, sliderHeight, 6);
  
  float availableTrackHeight = sliderHeight - sliderKnobHeight;
  float knobY = sliderY + sliderPos * availableTrackHeight;
  
  boolean sliderHovered = (mouseX > sliderX && mouseX < sliderX + sliderWidth &&
                           mouseY > knobY && mouseY < knobY + sliderKnobHeight);
  
  if (dragging || sliderHovered) {
    fill(80);  // Knob hover/drag style.
  } else {
    fill(120); // Normal knob style.
  }

  rect(sliderX, knobY, sliderWidth, sliderKnobHeight, 6);
}

// Combined drawing function that calls the separate methods.
void drawAirportList() {
  recalcLayout();
  
  drawTiles();
  
  drawSliderMask();
  
  drawSlider();
}
  
void drawSortMenu() {
  // Only draw the sort menu if it is open.
  if (!sortMenuOpen) return;
  
  // Disable depth test to ensure the sort menu draws over everything.
  hint(DISABLE_DEPTH_TEST);
  
  fill(255);
  stroke(150);
  strokeWeight(2);
  rect(sortMenuX, sortMenuY, sortMenuW, sortMenuH, 10);
  
  fill(0);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Sort by:", sortMenuX + sortMenuW / 2, sortMenuY + sortMenuH / 2);
  
  // Draw sort options.z
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
  // Re-enable depth test after drawing the sort menu.
  hint(ENABLE_DEPTH_TEST);
}
  
  
  void mousePressed() {
    String selected = airportSelector.handleMousePressed(mouseX, mouseY);
    airportSelector.handleSliderMousePressed(mouseX, mouseY);
    menu.returnPressed();
    back.backPressed();
    
    if (selected != null) {
      processData.filterDate = null;
      if (graphScreen != null) graphScreen.lastSelectedDate = null;
      
      processData.process(selected);
      graphScreen = new GraphSelectorMenu(selected, processData);
      screenManager.switchScreen(graphScreen);
    }
  }
  
  //String handleMousePressed(float mx, float my) {
  //  float searchBarHeight = 55;
  //  float searchBarY = listY - searchBarHeight - 20;
  //  float clearX = listX + listWidth - 28 - 10;
  //  float clearY = searchBarY + (searchBarHeight - 28) / 2;
    
  //  if (!searchQuery.isEmpty()) {
  //    if (mx > clearX && mx < clearX + 28 && my > clearY && my < clearY + 28) {
  //      searchQuery = "";
  //      caretIndex = 0;
  //      clearSelection();
  //      resetScroll();
  //      return null;
  //    }
  //  }
    
  //  if (mx > listX && mx < listX + listWidth && my > searchBarY && my < searchBarY + searchBarHeight) {
  //    searchFocused = true;
  //    float relativeX = mx - (listX + 16);
  //    caretIndex = getCaretFromX(relativeX);
  //    selectionStart = selectionEnd = caretIndex;
  //    selectingText = true;
  //    sortMenuOpen = false;
  //    return null;
  //  } else {
  //    searchFocused = false;
  //  }
    
  //  if (mx > sortMenuX && mx < sortMenuX + sortMenuW &&
  //      my > sortMenuY && my < sortMenuY + sortMenuH) {
  //    sortMenuOpen = !sortMenuOpen;
  //    return null;
  //  }
    
  //  if (sortMenuOpen) {
  //    for (int i = 0; i < sortOptions.length; i++) {
  //      float optionY = sortMenuY + sortMenuH + i * optionHeight;
  //      if (mx > sortMenuX && mx < sortMenuX + sortMenuW &&
  //          my > optionY && my < optionY + optionHeight) {
  //        sortField = sortOptions[i].field;
  //        sortOrder = sortOptions[i].order;
  //        sortMenuOpen = false;
  //        return null;
  //      }
  //    }

 String handleMousePressed(float mx, float my) {
  float controlHeight = 55;
  float controlY = controlYPos;
  
  // First check the clear button in the search bar.
  float clearX = searchBarX + searchBarWidth - 28 - 10;
  float clearY = controlY + (controlHeight - 28) / 2;
  
  if (!searchQuery.isEmpty()) {
    if (mx > clearX && mx < clearX + 28 && my > clearY && my < clearY + 28) {
      searchQuery = "";
      setCaretIndex(0);
      clearSelection();
      resetScroll();
      heldKey = 0;
      keyBeingHeld = false;
      return null;
    }
  }
  
  // If clicking within the search bar.
  if (mx > searchBarX && mx < searchBarX + searchBarWidth && my > controlY && my < controlY + controlHeight) {
    searchFocused = true;
    textAlign(LEFT, CENTER);
    textSize(24);
  
    float textStartX = searchBarX + 16;
    float offsetX = mx - textStartX;
  
    String fullText = (searchQuery.isEmpty() && !searchFocused) ? "Search airports..." : searchQuery;
  
    int effectiveDisplayStart = displayStart;
    String visibleText = fullText.substring(effectiveDisplayStart);
  
    int pos = effectiveDisplayStart;
    float cumulativeWidth = 0;
    for (int i = effectiveDisplayStart; i < fullText.length(); i++) {
      float cw = textWidth(fullText.charAt(i) + "");
      if (cumulativeWidth + cw / 2 >= offsetX) {
        pos = i;
        break;
      }
      cumulativeWidth += cw;
      pos = i + 1;
    }
    
    setCaretIndex(pos);
    selectionStart = caretIndex;
    selectionEnd = caretIndex;
    selectingText = false;
    // Close sort menu if it was open.
    sortMenuOpen = false;
    return null;
  } else {
    searchFocused = false;
  }
  
  // If clicking the sort button.
  if (mx > sortButtonX && mx < sortButtonX + sortButtonWidth &&
      my > controlY && my < controlY + controlHeight) {
    sortMenuOpen = !sortMenuOpen;
    return null;
  }
  
  // If sort menu is open, handle option selection.
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
  }
  
  // Handle airport tile selection.
  String[] filteredAirports = getFilteredAirports();
  if (mx > listX && mx < listX + listWidth && my > listY && my < listY + itemsToShow * itemHeight) {
    int itemIndex = floor((my - listY) / itemHeight);
    int index = topIndex + itemIndex;
    if (index >= 0 && index < filteredAirports.length) {
      println("Selected: " + filteredAirports[index]);
      // Previously, the sort menu selection was reset here.
      // Removing the reset so that the current sort option remains.
      sortMenuOpen = false;
      return filteredAirports[index];
    }
  }
  
  sortMenuOpen = false;
  return null;
}
  
  // Mouse dragging in the search bar for text selection.
  void handleMouseDraggedInSearch(float mx) {
    if (searchFocused) {
      selectingText = true;
      textAlign(LEFT, CENTER);
      textSize(24);
      float textStartX = searchBarX + 16;
      float offsetX = mx - textStartX;
      int effectiveDisplayStart = displayStart;
      String fullText = searchQuery;
      int newPos = effectiveDisplayStart;
      float cumulativeWidth = 0;
      for (int i = effectiveDisplayStart; i < fullText.length(); i++) {
        float cw = textWidth(fullText.charAt(i) + "");
        if (cumulativeWidth + cw / 2 >= offsetX) {
          newPos = i;
          break;
        }
        cumulativeWidth += cw;
        newPos = i + 1;
      }
      setCaretIndex(newPos);
      selectionEnd = caretIndex;
    }
  }
  
  void handleSliderMousePressed(float mx, float my) {
    String[] filteredAirports = getFilteredAirports();
    if (filteredAirports.length <= itemsToShow) return;
    float availableTrackHeight = sliderHeight - sliderKnobHeight;
    float knobY = sliderY + sliderPos * availableTrackHeight;
    if (mx > sliderX && mx < sliderX + sliderWidth && my > knobY && my < knobY + sliderKnobHeight) {
      dragging = true;
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
  // Check if mouse is over the airport list area.
  boolean overList = (mouseX > listX && mouseX < listX + listWidth &&
                      mouseY > listY && mouseY < listY + itemsToShow * itemHeight);
  // Check if mouse is over the slider area.
  boolean overSlider = (mouseX > sliderX && mouseX < sliderX + sliderWidth &&
                        mouseY > sliderY && mouseY < sliderY + sliderHeight);

  // Only scroll if the mouse is over one of these areas.
  if (!(overList || overSlider)) {
    return; // Do not handle scrolling if not hovering over the list or slider.
  }
  
  float e = event.getCount();
  String[] filtered = getFilteredAirports();
  int maxTopIndex = max(0, filtered.length - itemsToShow);
  
  topIndex += (int)e;
  topIndex = constrain(topIndex, 0, maxTopIndex);
  sliderPos = (maxTopIndex == 0) ? 0 : topIndex / (float)maxTopIndex;
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
