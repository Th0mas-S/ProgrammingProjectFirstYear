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
    float buttonsX = 370;
    float playY = 10;
    float buttonSize = 60;
    float buttonGap = 10;
    float[] speeds = {1.0, 2.0, 4.0, 12.0, 30.0, 0.5};
    sliderButtons = new SliderButtons(buttonsX, playY, buttonSize, buttonGap, speeds);
  }
  
  void update() {
    if (dragging) {
      value = map(constrain(mouseX, x, x + w), x, x + w, 0, 1439);
    }
    if (autoPlaying) {
      float delta = millis() - lastUpdateTime;
      value += (delta / 500.0) * speedMultiplier;
      if (value > 1439) {
        value = value - 1440;
      }
      lastUpdateTime = millis();
    } else {
      lastUpdateTime = millis();
    }
  }
  
  void display() {
    fill(200);
    noStroke();
    rect(x, y, w, h, 5);
    float handleX = map(value, 0, 1439, x, x + w);
    float handleY = y + h / 2 - 30;
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
    float timeBoxY = y + h + 25;
    fill(50);
    stroke(255);
    strokeWeight(1);
    rect(timeBoxX, timeBoxY, timeBoxWidth, timeBoxHeight, 5);
    noStroke();
    textAlign(CENTER, CENTER);
    fill(255);
    textSize(20);
    text(minutesToTimeString(int(value)), timeBoxX + timeBoxWidth / 2, timeBoxY + timeBoxHeight / 2);
    
    if (dragging) {
      if (wasAutoPlaying) {
        sliderButtons.isPlaying = true;
      } else {
        sliderButtons.isPlaying = false;
      }
    } else {
      if (autoPlaying) {
        sliderButtons.isPlaying = true;
      } else {
        sliderButtons.isPlaying = false;
      }
    }
    
    sliderButtons.display();
  }
  
  void mousePressed() {
    float handleX = map(value, 0, 1439, x, x + w);
    float handleRadius = 20;

    if (dist(mouseX, mouseY, handleX, y + h / 2) < handleRadius) {
      wasAutoPlaying = autoPlaying;
      dragging = true;
      autoPlaying = false;
      return;
    }

    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
      value = map(mouseX, x, x + w, 0, 1439);
      dragging = false;
      autoPlaying = false;
      wasAutoPlaying = false;
      return;
    }

    float buttonSize = 60;
    float buttonGap = 10;
    float buttonsX = 370;
    float playButtonY = 10;
    float pauseButtonY = playButtonY + buttonSize + buttonGap;
    float ffButtonY = pauseButtonY + buttonSize + buttonGap;
  
    if (mouseX >= buttonsX && mouseX <= buttonsX + buttonSize &&
        mouseY >= playButtonY && mouseY <= playButtonY + buttonSize) {
      autoPlaying = true;
      dragging = false;
      pauseClicked = false;
      lastUpdateTime = millis();
    }

    if (mouseX >= buttonsX && mouseX <= buttonsX + buttonSize &&
        mouseY >= pauseButtonY && mouseY <= pauseButtonY + buttonSize) {
      autoPlaying = false;
      dragging = false;
      pauseClicked = true;
    }

    if (mouseX >= buttonsX && mouseX <= buttonsX + buttonSize &&
        mouseY >= ffButtonY && mouseY <= ffButtonY + buttonSize) {
      sliderButtons.updateSpeed();
      speedMultiplier = sliderButtons.speedMultiplier;
    }
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
