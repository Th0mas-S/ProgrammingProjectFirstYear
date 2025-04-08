class SliderButtonsDirectory {
  float buttonsX, playY, ffY, backY;
  float buttonSize, buttonGap;
  int speedIndex;
  float speedMultiplier;
  float[] speeds;
  boolean isPlaying;
  
  SliderButtonsDirectory(float buttonsX, float playY, float buttonSize, float buttonGap, float[] speeds) {
    this.buttonsX = buttonsX;
    this.buttonSize = buttonSize;
    this.buttonGap = buttonGap;
    this.playY = playY;
    this.ffY = playY + buttonSize + buttonGap;
    this.backY = ffY + buttonSize + buttonGap;
    this.speeds = speeds;
    speedIndex = 0;
    speedMultiplier = speeds[0];
    isPlaying = false;
  }
  
  void display() {
    // Toggle Play/Pause Button.
    boolean toggleHover = (mouseX >= buttonsX && mouseX <= buttonsX + buttonSize &&
                           mouseY >= playY && mouseY <= playY + buttonSize);
    if (toggleHover) {
      stroke(255);
      strokeWeight(2);
    } else {
      noStroke();
    }
    if (!isPlaying) {
      fill(150);
    } else {
      fill(100, 150, 255);
    }
    rect(buttonsX, playY, buttonSize, buttonSize, 5);
    noStroke();
    fill(255);
    if (!isPlaying) {
      float pt1x = buttonsX + 15;
      float pt1y = playY + 15;
      float pt2x = buttonsX + 15;
      float pt2y = playY + buttonSize - 15;
      float pt3x = buttonsX + buttonSize - 15;
      float pt3y = playY + buttonSize / 2;
      triangle(pt1x, pt1y, pt2x, pt2y, pt3x, pt3y);
    } else {
      float barWidth = 12;
      float barHeight = 30;
      float barY = playY + (buttonSize - barHeight) / 2;
      rect(buttonsX + 15, barY, barWidth, barHeight);
      rect(buttonsX + buttonSize - 15 - barWidth, barY, barWidth, barHeight);
    }
    
    // Fast-Forward Button.
    boolean ffHover = (mouseX >= buttonsX && mouseX <= buttonsX + buttonSize &&
                        mouseY >= ffY && mouseY <= ffY + buttonSize);
    if (ffHover) {
      stroke(255);
      strokeWeight(2);
    } else {
      noStroke();
    }
    if (speedMultiplier != 1.0) {
      fill(100, 150, 255);
    } else {
      fill(150);
    }
    rect(buttonsX, ffY, buttonSize, buttonSize, 5);
    noStroke();
    fill(255);
    float f1x = buttonsX + 10;
    float f1y = ffY + 10;
    float f2x = buttonsX + 10;
    float f2y = ffY + buttonSize - 10;
    float f3x = buttonsX + buttonSize / 2 + 2;
    float f3y = ffY + buttonSize / 2;
    triangle(f1x, f1y, f2x, f2y, f3x, f3y);
    float f4x = buttonsX + buttonSize / 2 - 2;
    float f4y = ffY + 10;
    float f5x = buttonsX + buttonSize / 2 - 2;
    float f5y = ffY + buttonSize - 10;
    float f6x = buttonsX + buttonSize - 10;
    float f6y = ffY + buttonSize / 2;
    triangle(f4x, f4y, f5x, f5y, f6x, f6y);
    
    // Display speed multiplier on the fast-forward button.
    String speedText = "x" + nf(speedMultiplier, 0, 1);
    pushStyle();
      textAlign(RIGHT, BOTTOM);
      textSize(18);
      fill(0);
      text(speedText, buttonsX + buttonSize - 5, ffY + buttonSize - 5);
    popStyle();
  }
  
  void updateSpeed() {
    speedIndex = (speedIndex + 1) % speeds.length;
    speedMultiplier = speeds[speedIndex];
  }
}
