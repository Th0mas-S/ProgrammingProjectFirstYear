class TimeSlider {
  float x, y, w, h;
  float value;
  boolean dragging;
  boolean autoPlaying;
  boolean wasAutoPlaying;
  boolean pauseClicked;
  long lastUpdateTime;
  float speedMultiplier;
  
  SliderButtons sliderButtons;
  
  TimeSlider(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    value = 0;
    dragging = false;
    autoPlaying = false;
    wasAutoPlaying = false;
    pauseClicked = false;
    lastUpdateTime = millis();
    speedMultiplier = 1.0;
    // Set up the singular toggle button (play/pause), fast-forward, and back button:
    float buttonsX = 370;
    float toggleY = 10; // Y for the singular toggle button
    float buttonSize = 60;
    float buttonGap = 10;
    float[] speeds = {1.0, 2.0, 4.0, 12.0, 30.0, 0.5};
    sliderButtons = new SliderButtons(buttonsX, toggleY, buttonSize, buttonGap, speeds);
  }
  
  void update() {
    if (dragging) {
      value = map(constrain(mouseX, x, x + w), x, x + w, 0, 1439);
    }
    if (autoPlaying) {
      float delta = millis() - lastUpdateTime;
      value += (delta / 500.0) * speedMultiplier;
      // If the value reaches or exceeds 1439, cap it and pause auto-playing.
      if (value >= 1439) {
        value = 1439;
        autoPlaying = false;
      }
      lastUpdateTime = millis();
    } else {
      lastUpdateTime = millis();
    }
  }
  
  void display() {
    fill(200);
    noStroke();
    rect(x, y-15, w, h, 5);
    float handleX = map(value, 0, 1439, x, x + w);
    float handleY = y + h / 2 - 45;
    float handleWidth = 20;
    float handleHeight = 60;
    
    boolean overHandle = dist(mouseX, mouseY, handleX, y + h / 2) < 20;
    
    if (dragging) {
      fill(100, 150, 255);
    } else {
      fill(128);
    }
    
    if (dragging || overHandle) {
      stroke(255);
      strokeWeight(2);
    } else {
      noStroke();
    }
    
    rect(handleX - handleWidth / 2, handleY, handleWidth, handleHeight);
    
    float timeBoxWidth = 80;
    float timeBoxHeight = 40;
    float timeBoxX = handleX - timeBoxWidth / 2;
    float timeBoxY = y + h + 10;
    fill(50);
    stroke(255);
    strokeWeight(1);
    rect(timeBoxX, timeBoxY, timeBoxWidth, timeBoxHeight, 5);
    noStroke();
    textAlign(CENTER, CENTER);
    fill(255);
    textSize(20);
    text(minutesToTimeString(int(value)), timeBoxX + timeBoxWidth / 2, timeBoxY + timeBoxHeight / 2);
    
    // When dragging the slider, show the previous auto-play state.
    // Otherwise, show the current auto-playing state.
    sliderButtons.isPlaying = dragging ? wasAutoPlaying : autoPlaying;
    
    sliderButtons.display();
  }
  
  void mousePressed() {
    float handleX = map(value, 0, 1439, x, x + w);
    float handleRadius = 20;
    
    // Check if the handle is grabbed.
    if (dist(mouseX, mouseY, handleX, y + h / 2) < handleRadius) {
      wasAutoPlaying = autoPlaying;
      dragging = true;
      autoPlaying = false;
      return;
    }
    
    // Check if clicking on the slider track (outside the handle).
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
      value = map(mouseX, x, x + w, 0, 1439);
      dragging = false;
      autoPlaying = false;
      wasAutoPlaying = false;
      return;
    }
    
    float buttonsX = sliderButtons.buttonsX;
    float buttonSize = sliderButtons.buttonSize;
    
    // Toggle play/pause button hitbox.
    float toggleY = sliderButtons.playY;  // singular toggle button's Y coordinate
    if (mouseX >= buttonsX && mouseX <= buttonsX + buttonSize &&
        mouseY >= toggleY && mouseY <= toggleY + buttonSize) {
      // If paused at 23:59, reset and start auto-playing.
      if (!autoPlaying && value >= 1439) {
        value = 0;
        autoPlaying = true;
        pauseClicked = false;
      } else {
        autoPlaying = !autoPlaying;
        dragging = false;
        pauseClicked = !autoPlaying;
      }
      lastUpdateTime = millis();
      return;
    }
    
    // Fast-Forward button hitbox.
    float ffButtonY = sliderButtons.ffY;
    if (mouseX >= buttonsX && mouseX <= buttonsX + buttonSize &&
        mouseY >= ffButtonY && mouseY <= ffButtonY + buttonSize) {
      sliderButtons.updateSpeed();
      speedMultiplier = sliderButtons.speedMultiplier;
      return;
    }
    
    // Back button hitbox (located just beneath the fast-forward button).
    //float backButtonY = sliderButtons.backY;
    //if (mouseX >= buttonsX && mouseX <= buttonsX + buttonSize &&
    //    mouseY >= backButtonY && mouseY <= backButtonY + buttonSize) {
    //  screenManager.switchScreen(mainMenuScreen);
    //  return;
    //}
  }
  
  void mouseReleased() {
    dragging = false;
    if (!pauseClicked && wasAutoPlaying) {
      autoPlaying = true;
      lastUpdateTime = millis();
    }
    wasAutoPlaying = false;
    pauseClicked = false;
  }
  
  String minutesToTimeString(int minutes) {
    int hh = minutes / 60;
    int mm = minutes % 60;
    return nf(hh, 2) + ":" + nf(mm, 2);
  }
}
