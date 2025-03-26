import processing.sound.*; 

SoundFile audio; 

// Global constant for Y-axis
final PVector Y_AXIS = new PVector(0, 1, 0);

// Precompute constant rotation matrices
final PMatrix3D EARTH_ROTATION_DELTA = getRotationMatrix(0.001, Y_AXIS);
final PMatrix3D STAR_INERTIA_DELTA   = getRotationMatrix(0.0003, Y_AXIS);



// Global variables for stars
int numStars = 300;
int numMoreStars = 200;
int numEvenMoreStars = 1000;
  int x = 0;

Star[] stars = new Star[numStars];
Star[] moreStars = new Star[numMoreStars];
Star[] evenMoreStars = new Star[numEvenMoreStars];

Earth earth;
ArrayList<Airplane> airplanes; 

float altitudeOffset = 500;
float earthRadius = 200;
int numAirplanes = 2;

void setup() {
  audio = new SoundFile(this, "audio2.mp3");
  audio.loop();
  
  fullScreen(P3D);
  noStroke();
  
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
  earth = new Earth("Earth.obj", "Surface2k.png");
  
  // Initialize the airplanes list and add airplanes
  airplanes = new ArrayList<Airplane>();
  for (int i = 0; i < numAirplanes; i++) {
    airplanes.add(new Airplane(earthRadius, "Airplane.obj", "AirplaneTexture.png"));
  }
}

void draw() {
  background(0);
  
  // Draw stars (using an array of star arrays to reduce duplicate loops)
  Star[][] starArrays = { stars, moreStars, evenMoreStars };
  for (Star[] starArray : starArrays) {
    for (Star star : starArray) {
      star.update();
      star.display();
    }
  }
  
  // Draw UI on top for transperency to work.
  hint(DISABLE_DEPTH_TEST);
  drawUI();
  hint(ENABLE_DEPTH_TEST);
  
  
  // Draw the Earth and airplanes.
  pushMatrix();
    earth.slowRotate();
    translate(0, height);
    scale(1.5);
    earth.display();
    
    // Update and display each airplane.
    for (Airplane a : airplanes) {
      a.update();
      a.display();
    }
  popMatrix();
}


void drawHoverButton(float x, float y, float w, float h, String label, float baseTextSize) {
  boolean hover = (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
  float scaleFactor = hover ? 1.1 : 1.0;
  
  float currentW = w * scaleFactor;
  float currentH = h * scaleFactor;
  // Adjust x and y so that the button grows/shrinks from its center.
  float currentX = x - (currentW - w) / 2;
  float currentY = y - (currentH - h) / 2;
  
  fill(128, 128, 128, 50);
  stroke(135, 206, 235, 150);
  rect(currentX, currentY, currentW, currentH, 10);
  
  fill(255);
  textSize(baseTextSize * scaleFactor);
  textAlign(CENTER, CENTER);
  text(label, currentX + currentW / 2, currentY + currentH / 2);
}

void drawUI() {
  // Draw the title.
  textAlign(CENTER, CENTER);
  textSize(50);
  fill(255);
  text("FLIGHTHUB", width - 400, height / 2 - 250);
  
  float buttonWidth = 700;
  float buttonHeight = 80;
  float gap = 70;
  float startX = width - (buttonWidth - 10);
  float startY = height / 2.5;
 
  drawHoverButton(startX, startY, buttonWidth, buttonHeight, "Globe", 40);
  
  float secondButtonY = startY + buttonHeight + gap;
  drawHoverButton(startX, secondButtonY, buttonWidth, buttonHeight, "Heatmap", 40);
  
  float thirdButtonY = secondButtonY + buttonHeight + gap;
  drawHoverButton(startX, thirdButtonY, buttonWidth, buttonHeight, "Directory", 40);
  
  float fourthButtonY = thirdButtonY + buttonHeight + gap;
  float creditsWidth = buttonWidth / 2 - 50;
  drawHoverButton(startX, fourthButtonY, creditsWidth, buttonHeight - 30, "Credits", 40);
  
  float exitX = startX * 1.275 - 10;
  float exitWidth = buttonWidth / 2 + 20;
  drawHoverButton(exitX, fourthButtonY, exitWidth, buttonHeight - 30, "Exit", 40);
}

// Global variables to control shooting stars.
boolean globalShootingStarActive = false;
int globalNextShootingStarTime = 0;

//Rotation Matrix
PMatrix3D getRotationMatrix(float angle, PVector axis) {
  float c = cos(angle);
  float s = -sin(angle);
  float t = 1 - c;
  float x = axis.x, y = axis.y, z = axis.z;
  return new PMatrix3D(
    t * x * x + c,      t * x * y - s * z,  t * x * z + s * y, 0,
    t * x * y + s * z,  t * y * y + c,      t * y * z - s * x, 0,
    t * x * z - s * y,  t * y * z + s * x,  t * z * z + c,     0,
    0,                  0,                  0,                 1
  );
}
