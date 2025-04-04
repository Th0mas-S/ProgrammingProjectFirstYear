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

  // Global variables for stars
  //int numStars = 300;
  //int numMoreStars = 200;
  //int numEvenMoreStars = 1000;
  
  //Star[] stars = new Star[numStars];
  //Star[] moreStars = new Star[numMoreStars];
  //Star[] evenMoreStars = new Star[numEvenMoreStars];

  // Modified constructor to accept a PApplet reference
  MainMenuScreen(PApplet parent) {
    this.parent = parent;
    audio.loop();
    flightHubLogo = parent.loadImage("Flighthub Logo.png");

    // Load the hover sound (make sure "audio4.mp3" is in your data folder)
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
    
    // Initialize the Earth model (ensure "Earth.obj" and "Surface2k.png" are in the data folder)
    earth = new EarthMenu("Earth.obj", "Surface4k.png");
    
    // Initialize the airplanes list and add airplanes
    airplanes = new ArrayList<AirplaneMenu>();
    for (int i = 0; i < numAirplanes; i++) {
      airplanes.add(new AirplaneMenu(earthRadius, "Airplane.obj", "AirplaneTexture.png"));
    }
  
  }
  
  void draw() {
    parent.background(0);
    
    // Draw stars (using an array of star arrays to reduce duplicate loops)
    Star[][] starArrays = { stars, moreStars, evenMoreStars };
    for (Star[] starArray : starArrays) {
      for (Star star : starArray) {
        star.update();
        star.display();
      }
    }
    
    // Draw UI on top for transperency to work.
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
  
  // these are member variables, i put them down here for now because they are relevant to the drawUI function
  float buttonWidth = 700;
  float buttonHeight = 80;
  float gap = 70;
  // The following values are calculated based on parent's dimensions in drawUI:
  // float startX = parent.width - (buttonWidth - 10);
  // float startY = parent.height / 2.5;
  // float secondButtonY = startY + buttonHeight + gap;
  // float thirdButtonY = secondButtonY + buttonHeight + gap;
  // float fourthButtonY = thirdButtonY + buttonHeight + gap;
  // float creditsWidth = buttonWidth / 2 - 50;
  // float exitX = startX * 1.275 - 10;
  // float exitWidth = buttonWidth / 2 + 20;
  
  void drawUI() {
    // Calculate button positions based on parent's dimensions
    float startX = parent.width - (buttonWidth - 10);
    float startY = parent.height / 2.5f;
    float secondButtonY = startY + buttonHeight + gap;
    float thirdButtonY = secondButtonY + buttonHeight + gap;
    float fourthButtonY = thirdButtonY + buttonHeight + gap;
    float creditsWidth = buttonWidth / 2 - 50;
    float exitX = startX * 1.275f - 10;
    float exitWidth = buttonWidth / 2 + 20;
    
    // --- NEW CODE TO DETECT HOVER AND PLAY SOUND ---
    // Check if the mouse is over any button
    boolean currentlyHovering = 
      isMouseOverRect(startX, startY, buttonWidth, buttonHeight) ||
      isMouseOverRect(startX, secondButtonY, buttonWidth, buttonHeight) ||
      isMouseOverRect(startX, thirdButtonY, buttonWidth, buttonHeight) ||
      isMouseOverRect(startX, fourthButtonY, creditsWidth, buttonHeight - 30) ||
      isMouseOverRect(exitX, fourthButtonY, exitWidth, buttonHeight - 30);
      
    // If the mouse just entered a button, play the hover sound
    if (currentlyHovering && !wasHoveringButton) {
      hoverSound.play();
    }
    // Update flag for next frame
    wasHoveringButton = currentlyHovering;
    // --------------------------------------------------
    
    // Draw the title.
    //parent.textAlign(PConstants.CENTER, PConstants.CENTER);
    //parent.textSize(50);
    //parent.fill(255);
    //parent.text("FLIGHTHUB", parent.width - 400, parent.height / 2 - 250);
    
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
    // Calculate button positions based on parent's dimensions
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
    } else if(isMouseOverRect(exitX, fourthButtonY, exitWidth, buttonHeight - 30)) {
      parent.exit();
    }
  }
}
