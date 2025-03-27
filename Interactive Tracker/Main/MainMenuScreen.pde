import processing.sound.*; 

float altitudeOffset = 500;
float earthRadius = 200;
int numAirplanes = 2;


// Global constant for Y-axis
final PVector Y_AXIS = new PVector(0, 1, 0);

// Precompute constant rotation matrices
final PMatrix3D EARTH_ROTATION_DELTA = getRotationMatrix(0.001, Y_AXIS);
final PMatrix3D STAR_INERTIA_DELTA   = getRotationMatrix(0.0003, Y_AXIS);

// Global variables to control shooting stars.
boolean globalShootingStarActiveMenu = false;
int globalNextShootingStarTimeMenu = 0;


class MainMenuScreen extends Screen {

  
  // Global variables for stars
  int numStars = 300;
  int numMoreStars = 200;
  int numEvenMoreStars = 1000;
  
  StarMenu[] stars = new StarMenu[numStars];
  StarMenu[] moreStars = new StarMenu[numMoreStars];
  StarMenu[] evenMoreStars = new StarMenu[numEvenMoreStars];
  
  EarthMenu earth;
  ArrayList<AirplaneMenu> airplanes; 
  

  MainMenuScreen() {
  audio.loop();

  noStroke();
  
  // Initialize stars with different radii for depth
  for (int i = 0; i < numStars; i++) {
    stars[i] = new StarMenu(1000, 2500);
  }
  for (int i = 0; i < numMoreStars; i++) {
    moreStars[i] = new StarMenu(1500, 3000);
  }
  for (int i = 0; i < numEvenMoreStars; i++) {
    evenMoreStars[i] = new StarMenu(2000, 3500);
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
  StarMenu[][] starArrays = { stars, moreStars, evenMoreStars };
  for (StarMenu[] starArray : starArrays) {
    for (StarMenu star : starArray) {
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
  textAlign(CENTER, CENTER);
  textSize(50);
  fill(255);
  text("FLIGHTHUB", width - 400, height / 2 - 250);
  

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

class StarMenu {
  float x, y, z;
  float origX, origY, origZ;
  
  //Shooting star animation
  float startX, startY, startZ;
  float dx, dy, dz;
  float shootProgress = 0.0;
  float fadeAlpha = 255;
  
  float minSpeed = 0.01;
  float maxSpeed = 0.05;
  float currentSpeed = 0.05;
  
  int state = 0;
  boolean blink;
  boolean isShooting = false;
  int starColor;
  
  PMatrix3D rotationMatrix;
  
  StarMenu(float minRadius, float maxRadius) {
    float theta = random(TWO_PI);
    float phi = random(PI);
    float radius = random(minRadius, maxRadius);
    x = radius * sin(phi) * cos(theta);
    y = radius * sin(phi) * sin(theta);
    z = radius * cos(phi);
    
    origX = x;
    origY = y;
    origZ = z;
    
    rotationMatrix = new PMatrix3D();
    
    if (random(50) < 1) {
      float chance = random(1);
      if (chance < 0.3333) {
        starColor = color(178, 219, 234);
      } else if (chance < 0.5333) {
        starColor = color(255, 255, 0);
      } else if (chance < 0.7333) {
        starColor = color(255, 165, 0);
      } else if (chance < 0.8667) {
        starColor = color(255, 243, 229);
      } else {
        starColor = color(255, 192, 203);
      }
    } else {
      starColor = color(255);
    }
  }
  
  void update() {
    blink = (random(1) < 0.0002);
    // Use precomputed inertia rotation matrix.
    rotationMatrix.preApply(STAR_INERTIA_DELTA);
    
    int currentTime = millis();
    if (state == 0) {
      if (!globalShootingStarActiveMenu && currentTime >= globalNextShootingStarTimeMenu) {
        if (random(1) < 0.9) {
          state = 1;
          isShooting = true;
          shootProgress = 0.0;
          fadeAlpha = 255;
          currentSpeed = random(minSpeed, maxSpeed);
          startX = origX;
          startY = origY;
          startZ = origZ;
          float shootDistance = random(500, 5000);
          float thetaShoot = random(TWO_PI);
          float phiShoot = random(PI);
          dx = shootDistance * sin(phiShoot) * cos(thetaShoot);
          dy = shootDistance * sin(phiShoot) * sin(thetaShoot);
          dz = shootDistance * cos(phiShoot);
          globalShootingStarActiveMenu = true;
        } else {
          globalNextShootingStarTimeMenu = currentTime + 1000;
        }
      }
    }
    
    if (isShooting) {
      if (state == 1) {
        shootProgress += currentSpeed;
        x = origX + shootProgress * dx;
        y = origY + shootProgress * dy;
        z = origZ + shootProgress * dz;
        if (shootProgress >= 1.0) {
          state = 2;
        }
      } else if (state == 2) {
        shootProgress += currentSpeed;
        x = origX + shootProgress * dx;
        y = origY + shootProgress * dy;
        z = origZ + shootProgress * dz;
        fadeAlpha -= 10;
        if (fadeAlpha <= 0) {
          fadeAlpha = 0;
          state = 0;
          isShooting = false;
          globalShootingStarActiveMenu = false;
          globalNextShootingStarTimeMenu = currentTime + 1000;
          x = origX;
          y = origY;
          z = origZ;
        }
      }
    }
  }
  
  void display() {
    if (blink) return;
    pushMatrix();
      // Center the coordinate system.
      translate(width/2, height/2, 0);
      applyMatrix(rotationMatrix);
      
      if (isShooting) {
        if (state == 1 || state == 2) {
          float totalDistance = sqrt(dx*dx + dy*dy + dz*dz);
          float currentDistance = shootProgress * totalDistance;
          float maxTrailLength = 200;
          float trailFraction = (currentDistance > maxTrailLength) ? (currentDistance - maxTrailLength) / currentDistance : 0;
          float trailStartX = lerp(origX, x, trailFraction);
          float trailStartY = lerp(origY, y, trailFraction);
          float trailStartZ = lerp(origZ, z, trailFraction);
          
          int steps = 20;
          for (int i = 0; i < steps; i++) {
            float t1 = i / float(steps);
            float t2 = (i + 1) / float(steps);
            float xi1 = lerp(trailStartX, x, t1);
            float yi1 = lerp(trailStartY, y, t1);
            float zi1 = lerp(trailStartZ, z, t1);
            float xi2 = lerp(trailStartX, x, t2);
            float yi2 = lerp(trailStartY, y, t2);
            float zi2 = lerp(trailStartZ, z, t2);
            stroke(255, int(fadeAlpha * t2));
            strokeWeight(2);
            line(xi1, yi1, zi1, xi2, yi2, zi2);
          }
          stroke(255, fadeAlpha);
          strokeWeight(3);
          point(x, y, z);
        }
      } else {
        translate(x, y, z);
        stroke(starColor);
        strokeWeight(2);
        point(0, 0);
      }
    popMatrix();
  }
}
