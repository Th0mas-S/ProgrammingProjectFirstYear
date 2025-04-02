class AirportSelector {
  String[] airports;
  int topIndex = 0;       // Index of the first airport to display
  int itemsToShow = 5;    // Number of items visible at once
  float listX = 50, listY = 100, listWidth = 300, itemHeight = 40;
  
  // Slider properties (vertical slider)
  float sliderX, sliderY, sliderWidth, sliderHeight;
  boolean dragging = false;
  float sliderPos; // normalized 0..1
  
  AirportSelector(String[] airports) {
    this.airports = airports;
    // Set slider position to the right of the list.
    sliderX = listX + listWidth + 20;
    sliderY = listY;
    sliderWidth = 20;
    sliderHeight = itemsToShow * itemHeight;
    sliderPos = 0;
  }
  
  void display() {
    // Title
    fill(0);
    textSize(20);
    textAlign(CENTER);
    text("Select an Airport", width/2, 40);
    
    // Draw the airport list (only itemsToShow at a time)
    for (int i = 0; i < itemsToShow; i++) {
      int index = topIndex + i;
      if(index < airports.length) {
        float y = listY + i * itemHeight;
        fill(100, 150, 255);
        rect(listX, y, listWidth, itemHeight, 5);
        fill(255);
        textSize(18);
        textAlign(CENTER, CENTER);
        text(airports[index], listX + listWidth/2, y + itemHeight/2);
      }
    }
    
    // Draw slider background
    fill(200);
    rect(sliderX, sliderY, sliderWidth, sliderHeight);
    // Draw slider knob
    float knobHeight = 30;
    float knobY = sliderY + sliderPos * (sliderHeight - knobHeight);
    fill(100);
    rect(sliderX, knobY, sliderWidth, knobHeight);
  }
  
  // Returns the airport string if an item was clicked, otherwise null.
  String handleMousePressed() {
    if(mouseX > listX && mouseX < listX + listWidth && mouseY > listY && mouseY < listY + itemsToShow * itemHeight) {
      int itemIndex = int((mouseY - listY) / itemHeight);
      int index = topIndex + itemIndex;
      if(index < airports.length) {
        return airports[index];
      }
    }
    return null;
  }
  
  // Slider interaction
  void mousePressed() {
    if(mouseX > sliderX && mouseX < sliderX + sliderWidth && mouseY > sliderY && mouseY < sliderY + sliderHeight) {
      dragging = true;
      updateSlider(mouseY);
    }
  }
  
  void mouseDragged() {
    if(dragging) {
      updateSlider(mouseY);
    }
  }
  
  void mouseReleased() {
    dragging = false;
  }
  
  void updateSlider(float my) {
    float knobHeight = 30;
    // Constrain the knob's top position within the slider.
    float newPos = constrain(my - sliderY - knobHeight/2, 0, sliderHeight - knobHeight);
    sliderPos = newPos / (sliderHeight - knobHeight);
    // Calculate topIndex based on sliderPos.
    int maxTop = max(0, airports.length - itemsToShow);
    topIndex = int(sliderPos * maxTop);
  }
}
