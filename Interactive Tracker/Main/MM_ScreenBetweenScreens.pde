import processing.core.PApplet;
import processing.sound.*;

class ScreenBetweenScreens extends Screen {
  

  PApplet parent;


  int numStars = 5000;
  Star[] stars;

  // Minimal rotation matrix for star drift.
  PMatrix3D STAR_INERTIA_DELTA;


  SoundFile hoverSound;
  boolean wasHoveringButton = false;

  // Button sizes and positions
  float buttonWidth = 700;
  float buttonHeight = 80;
  float gap = 70;
  float flightsBtnY;
  float airportBtnY;
  float buttonX;


  ScreenBetweenScreens(PApplet parent) {

    this.parent = parent;


    stars = new Star[numStars];


    STAR_INERTIA_DELTA = new PMatrix3D();
    STAR_INERTIA_DELTA.rotateY(0.001);


    for (int i = 0; i < numStars; i++) {
      stars[i] = new Star(500, 3000); 
    }


    hoverSound = new SoundFile(parent, "audio4.mp3");

 
    buttonX = parent.width/2 - buttonWidth/2;
    flightsBtnY = parent.height/2 - buttonHeight - 10;  
    airportBtnY    = flightsBtnY + buttonHeight + gap;   

    parent.textSize(20);
  }

  void draw() {

    parent.background(0);


    for (int i = 0; i < numStars; i++) {
      stars[i].update();
      stars[i].display();
    }

    // Translucent overlay
    parent.noStroke();
    parent.fill(0, 150);
    parent.rect(0, 0, parent.width, parent.height);

    // Draw our two hover buttons
    drawHoverButton(buttonX, flightsBtnY, buttonWidth, buttonHeight, "Flights", 40);
    drawHoverButton(buttonX, airportsBtnY,    buttonWidth, buttonHeight, "Airports",    40);

    // Check hover state
    boolean currentlyHovering =
      isMouseOverRect(buttonX, flightsBtnY, buttonWidth, buttonHeight) ||
      isMouseOverRect(buttonX, airportBtnY,    buttonWidth, buttonHeight);

    // If the mouse just entered a button area, play the hover sound once.
    if (currentlyHovering && !wasHoveringButton) {
      hoverSound.play();
    }
    wasHoveringButton = currentlyHovering;
  }

  // Helper to check if mouse is over a rectangle
  boolean isMouseOverRect(float x, float y, float w, float h) {
    return parent.mouseX > x && parent.mouseX < x + w &&
           parent.mouseY > y && parent.mouseY < y + h;
  }

 
  void drawHoverButton(float x, float y, float w, float h, String label, float baseTextSize) {
    boolean hover = isMouseOverRect(x, y, w, h);
    float scaleFactor = hover ? 1.1 : 1.0;

    float currentW = w * scaleFactor;
    float currentH = h * scaleFactor;
    float currentX = x - (currentW - w) / 2;
    float currentY = y - (currentH - h) / 2;

    parent.stroke(135, 206, 235, 150);
    parent.fill(128, 128, 128, 50);
    parent.rect(currentX, currentY, currentW, currentH, 10);

    parent.fill(255);
    parent.textSize(baseTextSize * scaleFactor);
    parent.textAlign(PApplet.CENTER, PApplet.CENTER);
    parent.text(label, currentX + currentW / 2, currentY + currentH / 2);
  }

  @Override
  void mousePressed() {
    // flights button
    if (isMouseOverRect(buttonX, flightsBtnY, buttonWidth, buttonHeight)) {
      screenManager.switchScreen(flightsScreen);
    }
    // Airports button
    else if (isMouseOverRect(buttonX, airportBtnY, buttonWidth, buttonHeight)) {;
    }
  }
}
