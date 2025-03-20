int numStars = 300;
int numMoreStars = 200;
int numEvenMoreStars = 1000;
int numEvenEvenMoreStars = 1000;

Star[] stars = new Star[numStars];
Star[] moreStars = new Star[numMoreStars];
Star[] evenMoreStars = new Star[numEvenMoreStars];
Star[] evenEvenMoreStars = new Star[numEvenEvenMoreStars];


// Star class for generating stars in the 3D environment
class Star {
  float x, y, z;
  boolean blink;
  
  PMatrix3D rotationMatrix;
  
  float friction = 0.95;
  
  
  // Constructor that allows specifying a minimum and maximum radius
  Star(float minRadius, float maxRadius) {
   
    float theta = random(TWO_PI);
    float phi = random(PI);
    float radius = random(minRadius, maxRadius);
    x = radius * sin(phi) * cos(theta);
    y = radius * sin(phi) * sin(theta);
    z = radius * cos(phi);
    rotationMatrix = new PMatrix3D();

  }
  
  // Default constructor for stars (300 - 500 units away)
  Star() {
    this(50000, 100000);
  }
  
  // Update the star's blink state with a small random chance to "turn off"
void update(Earth e) {
  blink = (random(1) < 0.0002);
  
  if (abs(e.inertiaAngle) > 0.0001) {
    // Scale the angle directly (note the negative sign to invert the rotation)
    float adjustedAngle = -e.inertiaAngle * 0.3;
    PMatrix3D inertiaDelta = getRotationMatrix(adjustedAngle, e.inertiaAxis);


    // Apply the inverse rotation to the star's rotationMatrix
    rotationMatrix.preApply(inertiaDelta);
  } 
}

  
  // Display the star as a white point if it's not blinking
  void display() {
     

    if (!blink) {
      pushMatrix();
         translate(width/2, height/2, 0);
         applyMatrix(rotationMatrix);

        translate(x, y, z);
        stroke(255);
        strokeWeight(2);
        point(0, 0);
      popMatrix();
    }
  }
}
