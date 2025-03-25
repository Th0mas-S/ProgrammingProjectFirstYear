
int numStars = 300;
int numMoreStars = 200;
int numEvenMoreStars = 1000;
// Global controls for shooting stars.
boolean globalShootingStarActive = false;
int globalNextShootingStarTime = 0;
Star[] stars = new Star[numStars];
Star[] moreStars = new Star[numMoreStars];
Star[] evenMoreStars = new Star[numEvenMoreStars];

// Star class for generating stars in the 3D environment
class Star {
  float x, y, z;               // current position
  float origX, origY, origZ;   // original position for resetting
  
  // For shooting star animation:
  float startX, startY, startZ;  // starting point for current cycle (same as orig)
  float dx, dy, dz;            // displacement vector for current cycle
  float shootProgress = 0.0;   // normalized progress (can exceed 1.0 in fading phase)
  float fadeAlpha = 255;       // overall alpha for fading effect
  
  // Speed control: a random speed is chosen for each cycle.
  float minSpeed = 0.01;       // Minimum speed (adjust as desired)
  float maxSpeed = 0.05;       // Maximum speed (adjust as desired)
  float currentSpeed = 0.05;   // Current speed for the cycle, will be randomized
  
  // States for shooting star cycle:
  // 0 = waiting, 1 = moving (shooting), 2 = fading while moving
  int state = 0;
  
  boolean blink;
  boolean isShooting = false;  // will be set to true when this star becomes the shooting star
  
  // Regular star color (if not shooting, this is used; shooting stars are drawn white)
  int starColor;
  
  PMatrix3D rotationMatrix;
  float friction = 0.95;
  
  // Global controls for shooting stars.
  
  // Constructor that allows specifying a minimum and maximum radius
  Star(float minRadius, float maxRadius) {
    float theta = random(TWO_PI);
    float phi = random(PI);
    float radius = random(minRadius, maxRadius);
    x = radius * sin(phi) * cos(theta);
    y = radius * sin(phi) * sin(theta);
    z = radius * cos(phi);
    // Store original position for resetting shooting cycles.
    origX = x;
    origY = y;
    origZ = z;
    
    rotationMatrix = new PMatrix3D();
    
    // 1 in 50 chance for a non-white color
    if (random(50) < 1) {
      float chance = random(1);
      if (chance < 0.3333) {
        starColor = color(0, 0, 255);        // blue (~33.33%)
      } else if (chance < 0.5333) {
        starColor = color(255, 255, 0);        // yellow (~20%)
      } else if (chance < 0.7333) {
        starColor = color(255, 165, 0);        // orange (~20%)
      } else if (chance < 0.8667) {
        starColor = color(0, 255, 0);          // green (~13.33%)
      } else {
        starColor = color(255, 192, 203);      // pink (~13.33%)
      }
    } else {
      starColor = color(255);                // white
    }
    
    // Initially, no star is set to shoot.
    state = 0;
    // Schedule the first shooting opportunity 1 second from now.
    globalNextShootingStarTime = millis() + 1000;
  }
  
  // Default constructor for stars (50000 - 100000 units away)
  Star() {
    this(50000, 100000);
  }
  
  // Update the star's state.
  void update(Earth e) {
    blink = (random(1) < 0.0002);
    
    // Rotate all stars based on Earth's inertia.
    if (abs(e.inertiaAngle) > 0.0001) {
      float adjustedAngle = -e.inertiaAngle * 0.3;
      PMatrix3D inertiaDelta = getRotationMatrix(adjustedAngle, e.inertiaAxis);
      rotationMatrix.preApply(inertiaDelta);
    }
    
    int currentTime = millis();
    
    // Only stars in the waiting state (state 0) may begin shooting.
    if (state == 0) {
      // If no shooting star is active and it's time for a new chance...
      if (!globalShootingStarActive && currentTime >= globalNextShootingStarTime) {
        // 90% chance to start this star's shooting cycle.
        if (random(1) < 0.9) {
          state = 1;
          isShooting = true;
          shootProgress = 0.0;
          fadeAlpha = 255;
          currentSpeed = random(minSpeed, maxSpeed);
          // Reset starting position.
          startX = origX;
          startY = origY;
          startZ = origZ;
          // Pick a random displacement distance between 500 and 5000 pixels.
          float shootDistance = random(500, 5000);
          float thetaShoot = random(TWO_PI);
          float phiShoot = random(PI);
          dx = shootDistance * sin(phiShoot) * cos(thetaShoot);
          dy = shootDistance * sin(phiShoot) * sin(thetaShoot);
          dz = shootDistance * cos(phiShoot);
          // Mark that a shooting star is now active.
          globalShootingStarActive = true;
        } else {
          // If not chosen, schedule the next check 1 second from now.
          globalNextShootingStarTime = currentTime + 1000;
        }
      }
    }
    
    if (isShooting) {
      // The shooting star will continue its cycle.
      if (state == 1) {  // Moving (shooting) phase
        shootProgress += currentSpeed; // Use randomized speed.
        // Update position along the displacement vector.
        x = origX + shootProgress * dx;
        y = origY + shootProgress * dy;
        z = origZ + shootProgress * dz;
        // When reaching the intended destination, switch to fading while moving.
        if (shootProgress >= 1.0) {
          state = 2;
        }
      } else if (state == 2) {  // Fading while moving phase
        shootProgress += currentSpeed; // Continue movement.
        // Update position along the displacement vector.
        x = origX + shootProgress * dx;
        y = origY + shootProgress * dy;
        z = origZ + shootProgress * dz;
        fadeAlpha -= 10;  // Continue fading.
        if (fadeAlpha <= 0) {
          fadeAlpha = 0;
          // Reset for the next cycle:
          state = 0;
          isShooting = false;
          // Mark that no shooting star is active now.
          globalShootingStarActive = false;
          // Schedule the next shooting chance 1 second from now.
          globalNextShootingStarTime = currentTime + 1000;
          // Reset position.
          x = origX;
          y = origY;
          z = origZ;
        }
      }
    }
    // Non-shooting stars only require rotation update.
  }
  
  // Display the star.
  void display() {
    if (blink) return;
    
    pushMatrix();
    translate(width/2, height/2, 0);
    applyMatrix(rotationMatrix);
    
    if (isShooting) {
      // Only display shooting stars during their moving or fading phases.
      if (state == 1 || state == 2) {
        // Calculate total displacement (shootDistance).
        float totalDistance = sqrt(dx*dx + dy*dy + dz*dz);
        // Determine how far the star has traveled.
        float currentDistance = shootProgress * totalDistance;
        // Set a maximum trail length.
        float maxTrailLength = 200;  // Adjust this value as desired.
        // Compute fraction along the path where the trail should start.
        float trailFraction = (currentDistance > maxTrailLength) 
                                ? (currentDistance - maxTrailLength) / currentDistance 
                                : 0;
                                
        // Calculate the starting point of the trail.
        float trailStartX = lerp(origX, x, trailFraction);
        float trailStartY = lerp(origY, y, trailFraction);
        float trailStartZ = lerp(origZ, z, trailFraction);
        
        int steps = 20;  // Number of segments in the trail.
        for (int i = 0; i < steps; i++) {
          float t1 = i / float(steps);
          float t2 = (i + 1) / float(steps);
          // Interpolate positions along the trail from the computed trail start.
          float xi1 = lerp(trailStartX, x, t1);
          float yi1 = lerp(trailStartY, y, t1);
          float zi1 = lerp(trailStartZ, z, t1);
          float xi2 = lerp(trailStartX, x, t2);
          float yi2 = lerp(trailStartY, y, t2);
          float zi2 = lerp(trailStartZ, z, t2);
          // The segment closer to the star is brighter.
          stroke(255, int(fadeAlpha * t2));
          strokeWeight(2);
          line(xi1, yi1, zi1, xi2, yi2, zi2);
        }
        // Draw the shooting star as a bright point.
        stroke(255, fadeAlpha);
        strokeWeight(3);
        point(x, y, z);
      }
      // If in waiting state, the shooting star remains hidden.
    } else {
      // For regular stars, display using their assigned color.
      translate(x, y, z);
      stroke(starColor);
      strokeWeight(2);
      point(0, 0);
    }
    popMatrix();
  }
}
