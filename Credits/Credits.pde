import processing.core.PApplet;
import processing.sound.*; 

class Credits extends Screen {
  // Global variables for shooting stars (used by Star class)
  boolean globalShootingStarActive = false;
  int globalNextShootingStarTime = 0;
  PMatrix3D STAR_INERTIA_DELTA;
  
  PApplet parent;
  SoundFile audio; 
  ArrayList<Star> stars;
  String[] credits = {
    "CREDITS",
    "",
    "FHOMAS",
    "DOT",
    "Atticussy",
    "Aiwanabreakfree",
    "Jacinda",
    "A man",
    "Bently",
    "",
    "Press any key to restart credits."
  };
  
  // Credits vertical offset
  float creditsY;
  
  // -- Logo Variables --
  PImage flightHubLogo;
  int logoStartTime;       // Start time of the program (for tracking 3 seconds)
  float logoScale = 0.5;   // Initial (smaller) scale for the logo
  boolean shrinking = false; // Whether the logo is currently shrinking
  
  // Back button dimensions and position.
  int backButtonX = 20;
  int backButtonY = 20;
  int backButtonWidth = 100;
  int backButtonHeight = 40;
  
  void settings() {
    size(1920,1055,P3D);  // Run in full screen mode using P3D renderer.
  }
  
  void setup() {
    audio = new SoundFile(this, "audio.mp3");
    audio.loop();
    // Initialize the inertia rotation matrix for stars.
    STAR_INERTIA_DELTA = new PMatrix3D();
    STAR_INERTIA_DELTA.rotateX(0.0005);
    STAR_INERTIA_DELTA.rotateY(0.001);
  
    // Create an array of stars with a large radius range so they fill the entire screen.
    stars = new ArrayList<Star>();
    float maxDimension = max(width, height);
    for (int i = 0; i < 200; i++) {
      stars.add(new Star(0, maxDimension * 1.2));
    }
    
    // Setup credits starting position.
    creditsY = height;
    textAlign(CENTER);
    textSize(48);  
    fill(255);
  
    // Load the FlightHub logo image (ensure "FlighthubLogo.png" is in the "data" folder).
    flightHubLogo = loadImage("image.png");
    
    // Center images by default.
    imageMode(CENTER);
  
    // Record the start time.
    logoStartTime = millis();
  }
  
  void draw() {
    background(0);
  
    // 1) Update and display the star background.
    for (Star s : stars) {
      s.update();
      s.display();
    }
  
    // 2) Handle the logo display and shrinking.
    displayLogo();
  
    // 3) Display the credits concurrently once the logo starts shrinking.
    if (shrinking) {
      displayCredits();
    }
    
    // 4) Draw the back button on top.
    drawBackButton();
  }
  
  // ---------------------------------------------------------------------
  // Logo display logic
  // ---------------------------------------------------------------------
  void displayLogo() {
    if (!shrinking || (shrinking && logoScale > 0.01)) {
      pushMatrix();
        translate(width / 2, height / 2);
        
        // After 3 seconds, start the shrinking process.
        if (!shrinking && millis() - logoStartTime > 3000) {
          shrinking = true;
        }
        
        // If in the shrinking phase, slow down the shrink by a factor of 0.99.
        if (shrinking) {
          logoScale *= 0.99;
          if (logoScale < 0.01) {
            logoScale = 0;
          }
        }
        
        // Draw the logo at the current scale.
        image(flightHubLogo, 0, 0, flightHubLogo.width * logoScale, flightHubLogo.height * logoScale);
      popMatrix();
    }
  }
  
  // ---------------------------------------------------------------------
  // Scrolling Star Wars–style credits
  // ---------------------------------------------------------------------
  void displayCredits() {
    pushMatrix();
      translate(width / 2, creditsY);
      rotateX(radians(35));
      
      for (int i = 0; i < credits.length; i++) {
        text(credits[i], 0, i * 60);
      }
    popMatrix();
  
    creditsY -= 1; 
    if (creditsY < -credits.length * 60) {
      creditsY = height;
    }
  }
  
  // ---------------------------------------------------------------------
  // Draw the back button in the top left corner.
  // ---------------------------------------------------------------------
  void drawBackButton() {
    // Draw button background.
    fill(255, 0, 0);
    noStroke();
    rect(backButtonX, backButtonY, backButtonWidth, backButtonHeight, 5);
    
    // Draw button label.
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(20);
    text("Back", backButtonX + backButtonWidth/2, backButtonY + backButtonHeight/2);
  }
  
  // ---------------------------------------------------------------------
  // Detect mouse clicks for the back button.
  // ---------------------------------------------------------------------
  void mousePressed() {
    // Check if mouse is inside the back button area.
    if (mouseX >= backButtonX && mouseX <= backButtonX + backButtonWidth &&
        mouseY >= backButtonY && mouseY <= backButtonY + backButtonHeight) {
      backButtonPressed();
    }
  }
  
  // ---------------------------------------------------------------------
  // Action to perform when the back button is pressed.
  // Modify this method to change screens or perform another action.
  // ---------------------------------------------------------------------
  void backButtonPressed() {
    println("Back button pressed");
    // For example: switch to the previous screen.
    // parent.setScreen(new MainMenuScreen());
  }
  
  void keyPressed() {
    // Reset the credits position on any key press.
    creditsY = height;
  }
}
