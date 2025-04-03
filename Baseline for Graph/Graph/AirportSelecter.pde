//==================================================
// AirportSelector class: Centered, Bigger, Smoother Slider
//==================================================
class AirportSelector {
  String[] airports;
  int topIndex = 0;      // Index of the first airport to display

  // --- Sizing and Positioning (ADJUST THESE) ---
  int itemsToShow = 8;    // Number of items visible at once (adjust based on itemHeight and screen)
  float listWidth = 400;  // Wider list
  float itemHeight = 45;  // Taller items
  float listSliderGap = 25; // Space between list and slider
  float sliderWidth = 25;   // Wider slider bar
  float sliderKnobHeight = 40; // Taller slider knob

  float listX, listY;       // Calculated in constructor
  float sliderX, sliderY, sliderHeight; // Calculated in constructor

  // --- Slider Interaction ---
  boolean dragging = false;
  float sliderPos; // normalized 0..1 (0 = top, 1 = bottom)


  AirportSelector(String[] airports) {
    this.airports = airports;
    // Sort airports alphabetically for easier selection
    Arrays.sort(this.airports);

    // --- Calculate Centered Positions ---
    float totalElementWidth = listWidth + listSliderGap + sliderWidth;
    listX = (width - totalElementWidth) / 2;
    listY = 120; // Start list further down to accommodate larger title

    sliderX = listX + listWidth + listSliderGap;
    sliderY = listY;

    // Calculate slider height based on list items shown
    sliderHeight = itemsToShow * itemHeight;

    sliderPos = 0; // Initial slider position at the top
  }

  void display() {
    // --- Title ---
    fill(0);
    textSize(28); // Larger title
    textAlign(CENTER, CENTER);
    text("Select an Airport", width / 2, 60); // Position title higher up

    // --- Draw the Airport List ---
    textAlign(CENTER, CENTER); // Set text alignment once for list items
    textSize(18); // Font size for list items

    for (int i = 0; i < itemsToShow; i++) {
      int index = topIndex + i;
      if (index < airports.length) {
        float currentItemY = listY + i * itemHeight;

        // Hover effect
        if (mouseX > listX && mouseX < listX + listWidth && mouseY > currentItemY && mouseY < currentItemY + itemHeight) {
           fill(120, 170, 255); // Brighter blue on hover
           stroke(50, 80, 150); // Subtle border on hover
           strokeWeight(1);
        } else {
           fill(100, 150, 255); // Standard blue
           noStroke();          // No border otherwise
        }

        rect(listX, currentItemY, listWidth, itemHeight, 8); // Slightly more rounded corners

        // Text
        fill(255); // White text
        text(airports[index], listX + listWidth / 2, currentItemY + itemHeight / 2);
      }
    }
    noStroke(); // Reset stroke

    // --- Draw Slider (only if needed) ---
    if (airports.length > itemsToShow) {
        // Draw slider background track
        fill(210); // Lighter track color
        rect(sliderX, sliderY, sliderWidth, sliderHeight, 5); // Rounded track

        // Draw slider knob
        // Calculate knob's Y position based on normalized sliderPos
        // Ensure the knob doesn't go past the bottom of the track
        float availableTrackHeight = sliderHeight - sliderKnobHeight;
        float knobY = sliderY + sliderPos * availableTrackHeight;

        // Knob hover/dragging effect
        if (dragging || (mouseX > sliderX && mouseX < sliderX + sliderWidth && mouseY > knobY && mouseY < knobY + sliderKnobHeight)) {
             fill(80); // Darker knob when active/hovered
        } else {
             fill(120); // Normal knob color
        }
        rect(sliderX, knobY, sliderWidth, sliderKnobHeight, 5); // Rounded knob
    }
  }

  // --- Mouse Handling Methods ---

  // Returns the airport string if an item was clicked, otherwise null.
  // (Takes mouseX, mouseY as arguments now for clarity)
  String handleMousePressed(float mx, float my) {
    // Check clicks within the visible list area
    if (mx > listX && mx < listX + listWidth && my > listY && my < listY + itemsToShow * itemHeight) {
      int itemIndex = floor((my - listY) / itemHeight); // Use floor to get index
      // Ensure calculated index is within the bounds of items actually shown
      if (itemIndex >= 0 && itemIndex < itemsToShow) {
          int index = topIndex + itemIndex;
          // Final check if this index is valid within the airports array
          if (index >= 0 && index < airports.length) {
            println("Selected: " + airports[index]); // Debug print
            return airports[index];
          }
       }
    }
    return null;
  }

  // Renamed for clarity
  void handleSliderMousePressed(float mx, float my) {
    if (airports.length <= itemsToShow) return; // No slider interaction if not visible

    // Check click on the knob OR the track for jump-scroll
    if (mx > sliderX && mx < sliderX + sliderWidth && my > sliderY && my < sliderY + sliderHeight) {
       dragging = true;
       updateSlider(my); // Update position immediately on click
    }
  }

  // Renamed for clarity
  void handleSliderMouseDragged(float mx, float my) {
     if (airports.length <= itemsToShow) return;
     if (dragging) {
       updateSlider(my);
     }
  }

  // Renamed for clarity
  void handleSliderMouseReleased() {
     dragging = false;
  }

  // Calculates sliderPos (0-1) and updates topIndex smoothly
  void updateSlider(float my) {
    if (airports.length <= itemsToShow) return; // Should not happen if called correctly, but safe check

    // Calculate the raw position based on mouse Y relative to the slider track
    // We want the *center* of the knob to align with the mouse click, roughly
    float targetY = my - sliderY - (sliderKnobHeight / 2);

    // Calculate the available track space for the knob's top position
    float availableTrackHeight = sliderHeight - sliderKnobHeight;

    // Prevent division by zero if sliderHeight equals sliderKnobHeight (unlikely)
    if (availableTrackHeight <= 0) {
        sliderPos = 0;
    } else {
       // Map the target Y onto the normalized slider position (0 to 1)
       sliderPos = targetY / availableTrackHeight;
    }

    // Constrain the normalized position between 0 and 1
    sliderPos = constrain(sliderPos, 0, 1);

    // Calculate the corresponding topIndex for the list display
    int maxTopIndex = max(0, airports.length - itemsToShow);
    // Use round() for smoother mapping, especially near the ends
    topIndex = round(sliderPos * maxTopIndex);
    // Ensure topIndex stays within valid bounds after rounding
    topIndex = constrain(topIndex, 0, maxTopIndex);

    // Debug print (optional)
    // println("SliderPos: " + sliderPos + ", TopIndex: " + topIndex);
  }
}
