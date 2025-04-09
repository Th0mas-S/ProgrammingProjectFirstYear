class Slider {
  int x, y, sliderLength;
  int trackWidth;
  int knobWidth, knobHeight;
  float xS, yS;
  float cornerRadius;  // Used for both track and knob
  boolean mouseDown, hover;

  Slider(int xIn, int yIn, int length) {
    x = xIn - 10;
    y = yIn;
    sliderLength = length;
    knobWidth = 30;
    knobHeight = 60;
    // Increase corner radius for smoother curves on both track and knob.
    cornerRadius = 12;  // Adjust as needed
    trackWidth = knobWidth;
    xS = x;
    yS = y;
    mouseDown = false;
    hover = false;
  }

  // Check if the mouse is over the knob.
  boolean mouseOver() {
    return (mouseX >= xS && mouseX <= xS + knobWidth &&
            mouseY >= yS && mouseY <= yS + knobHeight);
  }

  // Activate dragging if the mouse is pressed over the knob.
  void sliderPressed() {
    if (mouseOver()) {
      mouseDown = true;
    }
  }

  // Release the slider.
  void sliderReleased() {
    mouseDown = false;
  }

  // Update the knob position if dragged, clamping within the track boundaries.
  void move() {
    if (mouseDown) {
      yS = mouseY - knobHeight / 2.0;
    }
    yS = constrain(yS, y, y + sliderLength - knobHeight);
  }

  // Return a percentage (0 to 0.9999) indicating how far down the slider the knob is.
  float getPercent() {
    float number = yS - y;
    float percent = number / (sliderLength - knobHeight);
    if (percent > 0.9999) {
      return 0.9999;
    }
    return percent;
  }

  // Adjust the knob's position based on the scroll wheel's direction.
  // A positive scroll value moves the knob down, while a negative value moves it up.
  void scroll(float direction) {
    //float sensitivity = 10.0;  // Adjust this value to fine-tune the scroll speed.
    //yS += direction * sensitivity;
    
    yS += direction / arrayIndex.size() * 1000;
    yS = constrain(yS, y, y + sliderLength - knobHeight -0.0565);
    //println("yS: "+yS+" / y: "+y+" / sl-kh:"+(sliderLength - knobHeight));
  }

  // Draw the slider on the screen.
  void draw() {
    move();
    strokeWeight(2);
    
    // Draw the slider's track with smooth rounded corners.
    fill(190);
    stroke(30);
    rect(x, y, trackWidth, sliderLength, cornerRadius);
    
    // Draw the slider's knob with smooth rounded corners.
    fill(120);
    if (hover) {
      stroke(255);
    } else {
      stroke(0);
    }
    hint(DISABLE_DEPTH_TEST);
    rect(xS, yS, knobWidth, knobHeight, cornerRadius);
    hint(ENABLE_DEPTH_TEST);
  }
}
