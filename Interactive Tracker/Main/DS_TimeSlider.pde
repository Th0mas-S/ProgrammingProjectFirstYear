class SliderDirectory {
  float x, y, w, h;
  float value;
  boolean dragging;
  boolean autoPlaying;
  boolean wasAutoPlaying;
  boolean pauseClicked;
  long lastUpdateTime;
  float speedMultiplier;
  int startTime, endTime;

  SliderButtonsDirectory sliderButtons;

  SliderDirectory(float x, float y, float w, float h, int startTime, int endTime) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.startTime = startTime;
    this.endTime = endTime;
    value = startTime;
    dragging = false;
    autoPlaying = false;
    wasAutoPlaying = false;
    pauseClicked = false;
    lastUpdateTime = millis();
    speedMultiplier = 1.0;
    float buttonsX = 370;
    float toggleY = 10;
    float buttonSize = 60;
    float buttonGap = 10;
    float[] speeds = {1.0, 2.0, 4.0, 12.0, 30.0, 0.5};
    sliderButtons = new SliderButtonsDirectory(buttonsX, toggleY, buttonSize, buttonGap, speeds);
  }

  void update() {
    if (dragging) {
      value = map(constrain(mouseX, x, x + w), x, x + w, startTime, endTime);
    }
    if (autoPlaying) {
      float delta = millis() - lastUpdateTime;
      value += (delta / 500.0) * speedMultiplier;
      if (value >= endTime) {
        value = endTime;
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
    rect(x, y, w, h, 5);
    float handleX = map(value, startTime, endTime, x, x + w);
    float handleY = y + h / 2 - 30;
    float handleWidth = 20;
    float handleHeight = 60;

    boolean overHandle = dist(mouseX, mouseY, handleX, y + h / 2) < 20;
    fill(dragging ? color(100, 150, 255) : 128);
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

    int totalMinutes = (int) value;
    int wrappedMinutes = totalMinutes % 1440;
    int hh = wrappedMinutes / 60;
    int mm = wrappedMinutes % 60;
    String mainTime = nf(hh, 2) + ":" + nf(mm, 2);
    int dayOffset = totalMinutes / 1440;

    textSize(20);
    float centerX = timeBoxX + timeBoxWidth / 2;
    float centerY = timeBoxY + timeBoxHeight / 2;
    text(mainTime, centerX, centerY);

    if (dayOffset > 0) {
      textSize(14);
      float offsetX = textWidth(mainTime) / 2 + 13;  // Shifted more right
      float offsetY = -2;  // Shifted slightly down
      text("+" + dayOffset, centerX + offsetX, centerY + offsetY);
    }

    sliderButtons.isPlaying = dragging ? wasAutoPlaying : autoPlaying;
    sliderButtons.display();
  }

  void mousePressed() {
    float handleX = map(value, startTime, endTime, x, x + w);
    float handleRadius = 20;
    if (dist(mouseX, mouseY, handleX, y + h / 2) < handleRadius) {
      wasAutoPlaying = autoPlaying;
      dragging = true;
      autoPlaying = false;
      return;
    }
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
      value = map(mouseX, x, x + w, startTime, endTime);
      dragging = false;
      autoPlaying = false;
      wasAutoPlaying = false;
      return;
    }
    float buttonsX = sliderButtons.buttonsX;
    float buttonSize = sliderButtons.buttonSize;
    float toggleY = sliderButtons.playY;
    if (mouseX >= buttonsX && mouseX <= buttonsX + buttonSize && mouseY >= toggleY && mouseY <= toggleY + buttonSize) {
      if (!autoPlaying && value >= endTime) {
        value = startTime;
        autoPlaying = true;
        if (screenManager.currentScreen instanceof EarthScreenDirectory) {
          EarthScreenDirectory screen = (EarthScreenDirectory) screenManager.currentScreen;
          if (screen.airplane != null) {
            screen.airplane.hasArrived = false;
            screen.airplane.currentPos = screen.airplane.start.copy();
          }
        }
      } else {
        autoPlaying = !autoPlaying;
        dragging = false;
        pauseClicked = !autoPlaying;
      }
      lastUpdateTime = millis();
      return;
    }
    float ffButtonY = sliderButtons.ffY;
    if (mouseX >= buttonsX && mouseX <= buttonsX + buttonSize && mouseY >= ffButtonY && mouseY <= ffButtonY + buttonSize) {
      sliderButtons.updateSpeed();
      speedMultiplier = sliderButtons.speedMultiplier;
      return;
    }
    float backButtonY = sliderButtons.backY;
    if (mouseX >= buttonsX && mouseX <= buttonsX + buttonSize && mouseY >= backButtonY && mouseY <= backButtonY + buttonSize) {
      screenManager.switchScreen(mainMenuScreen);
      return;
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
}
