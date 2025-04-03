import processing.core.PApplet;
import processing.sound.*;

class ScreenBetweenScreens extends Screen {
  
  // Reference to the main sketch (the PApplet).
  PApplet parent;

  // Number of stars and the star array.
  int numStars = 5000;
  Star[] stars;

  // Minimal rotation matrix for star drift.
  PMatrix3D STAR_INERTIA_DELTA;

  // Hover sound logic
  SoundFile hoverSound;
  boolean wasHoveringButton = false;

  // Button sizes and positions
  float buttonWidth = 700;
  float buttonHeight = 80;
  float gap = 70;
  float directoryBtnY;
  float graphsBtnY;
  float buttonX;

  // ─────────────────────────────────────────────────────────────────────────────────
  // Constructor now accepts a PApplet (your main sketch) instead of using `this`.
  // ─────────────────────────────────────────────────────────────────────────────────
  ScreenBetweenScreens(PApplet parent) {
    // Save the PApplet reference.
    this.parent = parent;

    // Prepare the star array.
    stars = new Star[numStars];

    // Minimal star rotation for drift.
    STAR_INERTIA_DELTA = new PMatrix3D();
    STAR_INERTIA_DELTA.rotateY(0.001);

    // Initialize each Star far out.
    for (int i = 0; i < numStars; i++) {
      stars[i] = new Star(500, 3000); 
    }

    // Load the hover sound using the main sketch reference.
    hoverSound = new SoundFile(parent, "audio4.mp3");

    // Compute button positions with the parent's dimensions.
    buttonX = parent.width/2 - buttonWidth/2;
    directoryBtnY = parent.height/2 - buttonHeight - 10;  // Directory above center
    graphsBtnY    = directoryBtnY + buttonHeight + gap;   // Graphs below Directory

    parent.textSize(20);
  }

  @Override
  void draw() {
    // Use parent to do drawing calls.
    parent.background(0);

    // Update and display each star.
    for (int i = 0; i < numStars; i++) {
      stars[i].update();
      stars[i].display();
    }

    // Translucent overlay
    parent.noStroke();
    parent.fill(0, 150);
    parent.rect(0, 0, parent.width, parent.height);

    // Draw our two hover buttons
    drawHoverButton(buttonX, directoryBtnY, buttonWidth, buttonHeight, "Directory", 40);
    drawHoverButton(buttonX, graphsBtnY,    buttonWidth, buttonHeight, "Graphs",    40);

    // Check hover state
    boolean currentlyHovering =
      isMouseOverRect(buttonX, directoryBtnY, buttonWidth, buttonHeight) ||
      isMouseOverRect(buttonX, graphsBtnY,    buttonWidth, buttonHeight);

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

  // Helper that replicates the “grow/shrink on hover” style
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
    // Directory button
    if (isMouseOverRect(buttonX, directoryBtnY, buttonWidth, buttonHeight)) {
      screenManager.switchScreen(directoryScreen);
    }
    // Graphs button
    else if (isMouseOverRect(buttonX, graphsBtnY, buttonWidth, buttonHeight)) {
      parent.println("Graphs button clicked (placeholder)!");
      // Example:
      // screenManager.switchScreen(heatMapScreen);
    }
  }

  // Unused event overrides
  @Override
  void mouseDragged() { }
  @Override
  void mouseReleased() { }
  @Override
  void mouseMoved() { }
  @Override
  void mouseWheel(MouseEvent event) { }
  @Override
  void keyPressed() { }
}
