import processing.sound.*; 

float altitudeOffset = 500;
float earthRadius = 200;
int numAirplanes = 2;

// Global constant for Y-axis
final PVector Y_AXIS = new PVector(0, 1, 0);

// Precompute constant rotation matrices
final PMatrix3D EARTH_ROTATION_DELTA = getUnRotationMatrix(0.001, Y_AXIS);
final PMatrix3D STAR_INERTIA_DELTA   = getUnRotationMatrix(0.0003, Y_AXIS);

// Global variables to control shooting stars.
boolean globalShootingStarActiveMenu = false;
int globalNextShootingStarTimeMenu = 0;

PImage flightHubLogo;

class MainMenuScreen extends Screen {

  // New variables for hover sound
  SoundFile hoverSound;
  boolean wasHoveringButton = false;
  
  // Reference to the main PApplet
  PApplet parent;
  
  EarthMenu earth;
  ArrayList<AirplaneMenu> airplanes; 

  // Global variables for stars.
  // (star arrays and numbers defined outside or elsewhere remain unchanged)
  
  PImage flightHubLogo;

  MainMenuScreen(PApplet parent) {
    this.parent = parent;
    audio.loop();
    flightHubLogo = parent.loadImage("Flighthub Logo.png");

    // Load the hover sound (ensure "audio4.mp3" is in your data folder)
    hoverSound = new SoundFile(parent, "audio4.mp3");

    parent.noStroke();
    
    // Initialize stars with different radii for depth
    for (int i = 0; i < numStars; i++) {
      stars[i] = new Star(1000, 2500);
    }
    for (int i = 0; i < numMoreStars; i++) {
      moreStars[i] = new Star(1500, 3000);
    }
    for (int i = 0; i < numEvenMoreStars; i++) {
      evenMoreStars[i] = new Star(2000, 3500);
    }
    
    // Initialize the Earth model.
    earth = new EarthMenu("Earth.obj", "Surface4k.png");
    
    // Initialize the airplanes list and add airplanes.
    // The airplanes are now placed on a sphere 3 units larger than the Earth model's radius.
    airplanes = new ArrayList<AirplaneMenu>();
    for (int i = 0; i < numAirplanes; i++) {
      airplanes.add(new AirplaneMenu(earthRadius + 3, "Airplane.obj", "AirplaneTexture.png"));
    }
  }
  
  void draw() {
    parent.background(0);
    
    // Draw stars from the various star arrays.
    Star[][] starArrays = { stars, moreStars, evenMoreStars };
    for (Star[] starArray : starArrays) {
      for (Star star : starArray) {
        star.update();
        star.display();
      }
    }
    
    // Draw UI on top so transparency works.
    parent.hint(PConstants.DISABLE_DEPTH_TEST);
    drawUI();
    imageMode(CORNER);
    noTint();
    parent.image(flightHubLogo, 800, -250, 1200, 900);
    parent.hint(PConstants.ENABLE_DEPTH_TEST);
    
    // Draw the Earth and airplanes.
    parent.pushMatrix();
    earth.slowRotate();
    parent.translate(0, parent.height);
    parent.scale(1.5);
    earth.display();
    
    // Update and display each airplane.
    for (AirplaneMenu a : airplanes) {
      a.update();
      a.display();
    }
    parent.popMatrix();
  }
  
  void drawHoverButton(float x, float y, float w, float h, String label, float baseTextSize) {
    boolean hover = (parent.mouseX >= x && parent.mouseX <= x + w && parent.mouseY >= y && parent.mouseY <= y + h);
    float scaleFactor = hover ? 1.1 : 1.0;
    
    float currentW = w * scaleFactor;
    float currentH = h * scaleFactor;
    // Adjust x and y so that the button grows/shrinks from its center.
    float currentX = x - (currentW - w) / 2;
    float currentY = y - (currentH - h) / 2;
    
    parent.fill(128, 128, 128, 50);
    parent.stroke(135, 206, 235, 150);
    parent.rect(currentX, currentY, currentW, currentH, 10);
    
    parent.fill(255);
    parent.textSize(baseTextSize * scaleFactor);
    parent.textAlign(PConstants.CENTER, PConstants.CENTER);
    parent.text(label, currentX + currentW / 2, currentY + currentH / 2);
  }
  
  // Button dimensions and positioning variables.
  float buttonWidth = 700;
  float buttonHeight = 80;
  float gap = 70;
  
  void drawUI() {
    // Calculate button positions based on parent's dimensions.
    float startX = parent.width - (buttonWidth - 10);
    float startY = parent.height / 2.5f;
    float secondButtonY = startY + buttonHeight + gap;
    float thirdButtonY = secondButtonY + buttonHeight + gap;
    float fourthButtonY = thirdButtonY + buttonHeight + gap;
    float creditsWidth = buttonWidth / 2 - 50;
    float exitX = startX * 1.275f - 10;
    float exitWidth = buttonWidth / 2 + 20;
    
    // Check for hover state and play sound if needed.
    boolean currentlyHovering = 
      isMouseOverRect(startX, startY, buttonWidth, buttonHeight) ||
      isMouseOverRect(startX, secondButtonY, buttonWidth, buttonHeight) ||
      isMouseOverRect(startX, thirdButtonY, buttonWidth, buttonHeight) ||
      isMouseOverRect(startX, fourthButtonY, creditsWidth, buttonHeight - 30) ||
      isMouseOverRect(exitX, fourthButtonY, exitWidth, buttonHeight - 30);
      
    if (currentlyHovering && !wasHoveringButton) {
      hoverSound.play();
    }
    wasHoveringButton = currentlyHovering;
    
    // Draw the buttons.
    drawHoverButton(startX, startY, buttonWidth, buttonHeight, "Globe", 40);
    drawHoverButton(startX, secondButtonY, buttonWidth, buttonHeight, "Heatmap", 40);
    drawHoverButton(startX, thirdButtonY, buttonWidth, buttonHeight, "Directory", 40);
    drawHoverButton(startX, fourthButtonY, creditsWidth, buttonHeight - 30, "Credits", 40);
    drawHoverButton(exitX, fourthButtonY, exitWidth, buttonHeight - 30, "Exit", 40);
  }
  
  boolean isMouseOverRect(float x, float y, float w, float h) {
    return parent.mouseX > x && parent.mouseX < x + w && parent.mouseY > y && parent.mouseY < y + h;
  }
  
  void mousePressed() {
    // Calculate button positions.
    float startX = parent.width - (buttonWidth - 10);
    float startY = parent.height / 2.5f;
    float secondButtonY = startY + buttonHeight + gap;
    float thirdButtonY = secondButtonY + buttonHeight + gap;
    float fourthButtonY = thirdButtonY + buttonHeight + gap;
    float creditsWidth = buttonWidth / 2 - 50;
    float exitX = startX * 1.275f - 10;
    float exitWidth = buttonWidth / 2 + 20;
    
    if(isMouseOverRect(startX, startY, buttonWidth, buttonHeight)) {
      screenManager.switchScreen(earthScreenTracker);
    } else if (isMouseOverRect(startX, secondButtonY, buttonWidth, buttonHeight)) {
      screenManager.switchScreen(heatMapScreen);
    } else if(isMouseOverRect(startX, thirdButtonY, buttonWidth, buttonHeight)) {
      screenManager.switchScreen(screenBetweenScreens);
    } else if(isMouseOverRect(startX, fourthButtonY, creditsWidth, buttonHeight - 30)){
      screenManager.switchScreen(creditsScreen);
      audio.stop();
      screenManager.switchScreen(creditsScreen);
    } else if(isMouseOverRect(exitX, fourthButtonY, exitWidth, buttonHeight - 30)) {
      parent.exit();
    }
  }
}
