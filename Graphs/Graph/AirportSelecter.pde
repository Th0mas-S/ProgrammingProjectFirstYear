//==================================================
// AirportSelector class: displays the list of airports with a slider.
class AirportSelector {
  String[] airports;
  int topIndex = 0;      // Index of the first airport to display
  int itemsToShow = 8;   // Number of items visible at once
  float listWidth = 400;
  float itemHeight = 45;
  float listSliderGap = 25;
  float sliderWidth = 25;
  float sliderKnobHeight = 40;
  float listX, listY;
  float sliderX, sliderY, sliderHeight;
  boolean dragging = false;
  float sliderPos; // normalized 0..1

  AirportSelector(String[] airports) {
    this.airports = airports;
    // Airports already sorted in getUniqueAirports()
    float totalElementWidth = listWidth + listSliderGap + sliderWidth;
    listX = (width - totalElementWidth) / 2;
    listY = 120;
    sliderX = listX + listWidth + listSliderGap;
    sliderY = listY;
    sliderHeight = itemsToShow * itemHeight;
    sliderPos = 0;
  }

  void display() {
    fill(0);
    textSize(28);
    textAlign(CENTER, CENTER);
    text("Select an Airport", width / 2, 60);

    textAlign(CENTER, CENTER);
    textSize(18);
    for (int i = 0; i < itemsToShow; i++) {
      int index = topIndex + i;
      if (index < airports.length) {
        float currentItemY = listY + i * itemHeight;
        if (mouseX > listX && mouseX < listX + listWidth && mouseY > currentItemY && mouseY < currentItemY + itemHeight) {
           fill(120, 170, 255);
           stroke(50, 80, 150);
           strokeWeight(1);
        } else {
           fill(100, 150, 255);
           noStroke();
        }
        rect(listX, currentItemY, listWidth, itemHeight, 8);
        fill(255);
        text(airports[index], listX + listWidth / 2, currentItemY + itemHeight / 2);
      }
    }
    noStroke();

    if (airports.length > itemsToShow) {
        fill(210);
        rect(sliderX, sliderY, sliderWidth, sliderHeight, 5);
        float availableTrackHeight = sliderHeight - sliderKnobHeight;
        float knobY = sliderY + sliderPos * availableTrackHeight;
        if (dragging || (mouseX > sliderX && mouseX < sliderX + sliderWidth && mouseY > knobY && mouseY < knobY + sliderKnobHeight)) {
             fill(80);
        } else {
             fill(120);
        }
        rect(sliderX, knobY, sliderWidth, sliderKnobHeight, 5);
    }
  }

  // Returns the airport string if clicked, otherwise null.
  String handleMousePressed(float mx, float my) {
    if (mx > listX && mx < listX + listWidth && my > listY && my < listY + itemsToShow * itemHeight) {
      int itemIndex = floor((my - listY) / itemHeight);
      int index = topIndex + itemIndex;
      if (index >= 0 && index < airports.length) {
        println("Selected: " + airports[index]);
        return airports[index];
      }
    }
    return null;
  }

  void handleSliderMousePressed(float mx, float my) {
    if (airports.length <= itemsToShow) return;
    if (mx > sliderX && mx < sliderX + sliderWidth && my > sliderY && my < sliderY + sliderHeight) {
       dragging = true;
       updateSlider(my);
    }
  }

  void handleSliderMouseDragged(float mx, float my) {
     if (airports.length <= itemsToShow) return;
     if (dragging) {
       updateSlider(my);
     }
  }

  void handleSliderMouseReleased() {
     dragging = false;
  }

  void updateSlider(float my) {
    if (airports.length <= itemsToShow) return;
    float targetY = my - sliderY - (sliderKnobHeight / 2);
    float availableTrackHeight = sliderHeight - sliderKnobHeight;
    if (availableTrackHeight <= 0) {
        sliderPos = 0;
    } else {
       sliderPos = targetY / availableTrackHeight;
    }
    sliderPos = constrain(sliderPos, 0, 1);
    int maxTopIndex = max(0, airports.length - itemsToShow);
    topIndex = round(sliderPos * maxTopIndex);
    topIndex = constrain(topIndex, 0, maxTopIndex);
  }
}
