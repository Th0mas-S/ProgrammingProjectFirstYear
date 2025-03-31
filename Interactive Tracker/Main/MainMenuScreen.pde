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


class MainMenuScreen extends Screen {

  
  // Global variables for stars
  //int numStars = 300;
  //int numMoreStars = 200;
  //int numEvenMoreStars = 1000;
  
  //Star[] stars = new Star[numStars];
  //Star[] moreStars = new Star[numMoreStars];
  //Star[] evenMoreStars = new Star[numEvenMoreStars];
  
  EarthMenu earth;
  ArrayList<AirplaneMenu> airplanes; 

  MainMenuScreen() {
    audio.loop();

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
    earth = new EarthMenu("Earth.obj", "Surface2k.png");
    
    // Initialize the airplanes list and add airplanes
    airplanes = new ArrayList<AirplaneMenu>();
    for (int i = 0; i < numAirplanes; i++) {
      airplanes.add(new AirplaneMenu(earthRadius, "Airplane.obj", "AirplaneTexture.png"));
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
    for (AirplaneMenu a : airplanes) {
      a.update();
      a.display();
    }

  popMatrix();
  
  pushMatrix();
    hint(DISABLE_DEPTH_TEST);  // Disable depth testing so the logo draws on top
    int logoX = 800;  
    int logoY = -250;  
    imageMode(CORNER);
    image(flightHubLogo, logoX, logoY, 1200, 900);
    hint(ENABLE_DEPTH_TEST);
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


 // these are member variables, i put them down here for now because they are relevant to the drawUI function
  float buttonWidth = 700;
  float buttonHeight = 80;
  float gap = 70;
  float startX = width - (buttonWidth - 10);
  float startY = height / 2.5;
  float secondButtonY = startY + buttonHeight + gap;
  float thirdButtonY = secondButtonY + buttonHeight + gap;
  float fourthButtonY = thirdButtonY + buttonHeight + gap;
  float creditsWidth = buttonWidth / 2 - 50;
  
  float exitX = startX * 1.275 - 10;
  float exitWidth = buttonWidth / 2 + 20;

void drawUI() {
  // Draw the title.

  //textAlign(CENTER, CENTER);
  //textSize(50);
  //fill(255);
  //text("FLIGHTHUB", width - 400, height / 2 - 250);

  drawHoverButton(startX, startY, buttonWidth, buttonHeight, "Globe", 40);
  
  drawHoverButton(startX, secondButtonY, buttonWidth, buttonHeight, "Heatmap", 40);
  
  drawHoverButton(startX, thirdButtonY, buttonWidth, buttonHeight, "Directory", 40);
  
  drawHoverButton(startX, fourthButtonY, creditsWidth, buttonHeight - 30, "Credits", 40);
  
  drawHoverButton(exitX, fourthButtonY, exitWidth, buttonHeight - 30, "Exit", 40);
}
  
  boolean isMouseOverRect(float x, float y, float w, float h) {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
  
  void mousePressed() {
    if(isMouseOverRect(startX, startY, buttonWidth, buttonHeight))
    {
      screenManager.switchScreen(earthScreenTracker);
    } else if (isMouseOverRect(startX, secondButtonY, buttonWidth, buttonHeight)) {
      screenManager.switchScreen(heatMapScreen);
    } else if(isMouseOverRect(startX, thirdButtonY, buttonWidth, buttonHeight)) {
      // switch screen to directory
    } else if(isMouseOverRect(startX, fourthButtonY, creditsWidth, buttonHeight - 30)){
      // switch screen to credits
    } else if(isMouseOverRect(exitX, fourthButtonY, exitWidth, buttonHeight - 30)) {
      exit();
    }
  }
}

class AirplaneMenu {
  PShape shape;
  PImage texture;
  
  float sphereRadius;
  float lastUpdateTime;
  boolean moving = true;
  PVector currentPos;
  PVector lastScreenPos;
  float angle;
  float orbitSpeed = 0.35;
  float tiltAngle;
  
  AirplaneMenu(float sphereRadius, String shapeFile, String textureFile) {
    shape = loadShape(shapeFile);
    texture = loadImage(textureFile);
    shape.setTexture(texture);
    
    this.sphereRadius = sphereRadius;
    boolean spawnTop = random(1) < 0.5;
    angle = PI/2;
    tiltAngle = spawnTop ? 3 * PI/2 : PI/2;
    
    currentPos = new PVector();
    update();
    
    lastUpdateTime = millis();
    lastScreenPos = new PVector();
  }
  
  void update() {
    if (!moving) return;
    
    float now = millis();
    float dt = (now - lastUpdateTime) / 1000.0;
    lastUpdateTime = now;
    
    angle += orbitSpeed * dt;
    if (angle >= TWO_PI) {
      angle = random(TWO_PI);
      tiltAngle = random(TWO_PI);
    }
    
    float offset = 20 * sin(angle * 2.0);
    float r = sphereRadius + offset + altitudeOffset - 6;
    
    float baseX = r * cos(angle);
    float baseZ = r * sin(angle);
    
    float finalX = baseX;
    float finalY = - baseZ * sin(tiltAngle);
    float finalZ = baseZ * cos(tiltAngle);
    
    currentPos.set(finalX, finalY, finalZ);
  }
  
  void display() {
    pushMatrix();
    translate(currentPos.x, currentPos.y, currentPos.z);
      
      float futureAngle = angle + 0.01;
      float offsetFuture = 20 * sin(futureAngle * 2.0);
      float rFuture = sphereRadius + offsetFuture + altitudeOffset;
      float baseX_future = rFuture * cos(futureAngle);
      float baseZ_future = rFuture * sin(futureAngle);
      float finalX_future = baseX_future;
      float finalY_future = - baseZ_future * sin(tiltAngle);
      float finalZ_future = baseZ_future * cos(tiltAngle);
      PVector futurePos = new PVector(finalX_future, finalY_future, finalZ_future);
      
      PVector tangent = PVector.sub(futurePos, currentPos);
      PVector up = currentPos.copy().normalize();
      
      PVector forward = tangent.copy();
      float dot = forward.dot(up);
      forward.sub(PVector.mult(up, dot));
      if (forward.mag() < 0.0001) {
        forward.set(0, 0, 1);
      } else {
        forward.normalize();
      }
      
      PVector right = up.cross(forward, null).normalize();
      
      PMatrix3D m = new PMatrix3D(
        right.x, up.x, forward.x, 0,
        right.y, up.y, forward.y, 0,
        right.z, up.z, forward.z, 0,
        0,       0,    0,         1
      );
      applyMatrix(m);
      
      float sx = screenX(0, 0, 0);
      float sy = screenY(0, 0, 0);
      lastScreenPos.set(sx, sy, 0);

      scale(15);
      shape(shape);
    popMatrix();
  }
}

class EarthMenu {
  PShape shape;
  PImage texture;
  PMatrix3D rotationMatrix;
  
  EarthMenu(String shapeFile, String textureFile) {
    shape = loadShape(shapeFile);
    texture = loadImage(textureFile);
    shape.setTexture(texture);
    rotationMatrix = new PMatrix3D();
  }
  

  void slowRotate() {
    rotationMatrix.preApply(EARTH_ROTATION_DELTA);
  }
  
  // Apply the current rotation and draw the Earth.
  void display() {
    applyMatrix(rotationMatrix);
    shape(shape);
  }
}

PMatrix3D getUnRotationMatrix(float angle, PVector axis) {
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
