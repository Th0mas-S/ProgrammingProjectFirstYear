class Slider {
  int x, y, sliderLength;
  int trackWidth;
  int knobWidth, knobHeight;
  float xS, yS, number;
  float cornerRadius;
  boolean mouseDown, hover;

  Slider(int xIn, int yIn, int length) {
    x = xIn - 20;
    y = yIn;
    sliderLength = length;
    knobWidth = 30;
    knobHeight = 60;
    cornerRadius = 4;
    trackWidth = knobWidth;
    xS = x;
    yS = y;
    mouseDown = false;
    hover = false;
  }

  boolean mouseOver() {
    return (mouseX >= xS && mouseX <= xS + knobWidth &&
            mouseY >= yS && mouseY <= yS + knobHeight);
  }

  void sliderPressed() {
    if (mouseOver()) {
      mouseDown = true;
    }
  }

  void sliderReleased() {
    mouseDown = false;
  }

  void move() {
    if (mouseDown) {
      yS = mouseY - knobHeight / 2.0;
    }
    if (yS < y) {
      yS = y;
    }
    if (yS > y + sliderLength - knobHeight) {
      yS = y + sliderLength - knobHeight;
    }
  }

  float getPercent() {
    number = yS - y;
    float percent = number / (sliderLength - knobHeight);
    if (percent > 0.9999) {
      return 0.9999;
    }
    return percent;
  }

  void scroll(float direction) {
    yS += direction / arrayIndex.size() * 1000;
    if (yS < y) {
      yS = y;
    }
    if (yS > y + sliderLength - knobHeight) {
      yS = y + sliderLength - knobHeight;
    }
  }

  void draw() {
    move();
    strokeWeight(2);
    fill(190);
    stroke(30);
    rect(x, y, trackWidth, sliderLength);
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
