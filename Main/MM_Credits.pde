import processing.core.PApplet;
import processing.sound.*; 

class CreditsScreen extends Screen {
  // Global variables for shooting stars (used by Star class)
  boolean globalShootingStarActive = false;
  int globalNextShootingStarTime = 0;
  PMatrix3D STAR_INERTIA_DELTA;
  
  PApplet parent;
  SoundFile creditsAudio; // This plays "audio5.mp3" for the credits screen.
  SoundFile mainMenuAudio; // Reference to the main menu audio ("audio3.mp3")
  
  ArrayList<Star> stars;
  String[] credits = {
    "CREDITS",
    "",
    "Aiwan",
    "Aman",
    "Atticus",
    "Ben",
    "Darragh",
    "Jason",
    "Thomas",
  };
  
  // Credits vertical offset.
  float creditsY;
  
  // -- Logo Variables --
  int logoStartTime;       // Start time for tracking 3 seconds
  float logoScale = 0.5;   // Initial (smaller) scale for the logo
  boolean shrinking = false; // Whether the logo is currently shrinking
  
  // New variable for logo opacity
  float logoOpacity;
  // Define a minimum scale at which the image stops shrinking.
  final float MIN_LOGO_SCALE = 0.01f;
  
  // Flag to trigger reset before drawing anything on the screen.
  boolean firstFrame = true;
  
  // Constructor now takes an extra parameter for the main menu audio.
  CreditsScreen(PApplet parent, SoundFile mainMenuAudio) {
    this.parent = parent;
    this.mainMenuAudio = mainMenuAudio;
    
    // Load the credits audio ("audio5.mp3") but don't start it until resetScreen() is called.
    creditsAudio = new SoundFile(parent, "audio5.mp3");
    
    // Initialize the inertia rotation matrix for stars.
    STAR_INERTIA_DELTA = new PMatrix3D();
    STAR_INERTIA_DELTA.rotateX(0.0005);
    STAR_INERTIA_DELTA.rotateY(0.001);
  
    // Create an array of stars with a large radius range so they fill the entire screen.
    stars = new ArrayList<Star>();
    float maxDimension = max(parent.width, parent.height);
    for (int i = 0; i < 200; i++) {
      stars.add(new Star(0, maxDimension * 1.2));
    }
    
    // Setup credits starting position.
    creditsY = parent.height;
    parent.textAlign(PConstants.CENTER);
    parent.textSize(48);  
    parent.fill(255);
    
    // Record the start time.
    logoStartTime = parent.millis();
  }
  
  void draw() {
    // Reset the screen state before drawing on the first frame.
    if (firstFrame) {
      resetScreen();
      firstFrame = false;
    }
    
    parent.background(0);
  
    // 1) Update and display the star background.
    for (Star s : stars) {
      s.update();
      s.display();
    }
  
    // 2) Handle the logo display and shrinking/fading.
    displayLogo();
  
    // 3) Display the credits once the logo starts shrinking.
    if (shrinking) {
      displayCredits();
    }
  }
  
  // ---------------------------------------------------------------------
  // Logo display logic.
  // ---------------------------------------------------------------------
  void displayLogo() {
    // Modify the condition so that we continue drawing if the logo is still visible.
    if (!shrinking || (shrinking && (logoScale > MIN_LOGO_SCALE || logoOpacity > 0))) {
      parent.pushMatrix();
        parent.translate(parent.width / 2, parent.height / 2);
        
        // After 3 seconds, start the shrinking process.
        if (!shrinking && parent.millis() - logoStartTime > 3000) {
          shrinking = true;
        }
        
        // If in the shrinking phase, either shrink or fade out.
        if (shrinking) {
          if (logoScale > MIN_LOGO_SCALE) {
            // Continue shrinking the logo.
            logoScale *= 0.99;
            if (logoScale < MIN_LOGO_SCALE) {
              logoScale = MIN_LOGO_SCALE;
            }
          } else {
            // Once the logo has reached its minimum scale, fade it out.
            logoOpacity -= 5;  // Adjust decrement to control fade-out speed.
            if (logoOpacity < 0) {
              logoOpacity = 0;
            }
            // Apply tint with the current opacity.
            parent.tint(255, logoOpacity);
          }
        }
        
        // Draw the logo. If fading, the logo remains at the minimum scale.
        parent.imageMode(PConstants.CENTER);
        float currentScale = (logoScale > MIN_LOGO_SCALE) ? logoScale : MIN_LOGO_SCALE;
        parent.image(flightHubLogoCredits, 0, 0, flightHubLogoCredits.width * currentScale, flightHubLogoCredits.height * currentScale);
        parent.imageMode(PConstants.CORNER);
        parent.noTint();
      parent.popMatrix();
    }
  }
  
  // ---------------------------------------------------------------------
  // Scrolling Star Wars–style credits.
  // ---------------------------------------------------------------------
  void displayCredits() {
    parent.pushMatrix();
      parent.translate(parent.width / 2, creditsY);
      parent.rotateX(PApplet.radians(35));
      
      for (int i = 0; i < credits.length; i++) {
        parent.text(credits[i], 0, i * 60);
      }
    parent.popMatrix();
  
    creditsY -= 1; 
    // When the last credit scrolls off the top...
    if (creditsY < -credits.length * 37) {
      // Stop the credits audio if it is playing.
      if (creditsAudio.isPlaying()) {
        creditsAudio.stop();
      }
      // Start the main menu audio (audio3) if it is not already playing.
      if (!mainMenuAudio.isPlaying()) {
        mainMenuAudio.loop();
      }
      
      // Prepare for the next time the credits screen is shown.
      firstFrame = true;
      // Switch back to the main menu screen.
      screenManager.switchScreen(mainMenuScreen);
    }
  }
  
  // ---------------------------------------------------------------------
  // Reset screen state to its initial values and start credits audio.
  // ---------------------------------------------------------------------
  void resetScreen() {
    creditsY = parent.height;
    logoScale = 0.5;
    shrinking = false;
    logoStartTime = parent.millis();
    logoOpacity = 255;  // Reset the opacity to full when starting over.
    
    // Start playing the credits audio only when the credits screen is active.
    if (!creditsAudio.isPlaying()) {
      creditsAudio.loop();
    }
  }
}
