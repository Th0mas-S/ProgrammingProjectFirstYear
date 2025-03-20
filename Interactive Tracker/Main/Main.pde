
ScreenManager screenManager;
EarthScreen earthScreen;

Earth earth;
Airport airportOrigin;
Airport airportDest;
Airplane airplane;
FlightInfo flightInfo;


Location origin = new Location(-25.5, 9.6); // departure latitude and longitude (loaded from file)        Relative Latitude = -(Actual Latitude) + 0.2617
Location destination = new Location(-51.2, 90.2); // arrival latitude and longitude (loaded from file)    Relative Longitude = 1.0071(Actual Longitude) + 90.35

boolean showFlightInfo = false;

float sphereRadius = 640;
                                                                                                                                                                      
void setup() {
  fullScreen(P3D);
  
  // Initialize near stars (300 - 500 units away)
    // Initialize stars (300 - 500 units away)
  for (int i = 0; i < numStars; i++) {
    stars[i] = new Star(1000, 2500);
  }
  
  //// Initialize moreStars (500 - 800 units away)
  for (int i = 0; i < numMoreStars; i++) {
    moreStars[i] = new Star(1500, 3000);
  }
  
  // Initialize evenMoreStars (800 - 1200 units away)
  for (int i = 0; i < numEvenMoreStars; i++) {
    evenMoreStars[i] = new Star(2000, 3500);
  }
  
  // Initialize evenEvenMoreStars (1200 - 2000 units away)
  for (int i = 0; i < numEvenEvenMoreStars; i++) {
    evenEvenMoreStars[i] = new Star(3000, 4000);
  }
   
  earth = new Earth("Earth.obj", "Surface2k.png"); //Change to "Surface16k.png" or "Surface2k.png" Download "Surface16k.png" from https://drive.google.com/drive/folders/1csCDLNxFFXlvlKpspokz1EXBzWIePThU?usp=sharing
  airportOrigin = new Airport(origin, sphereRadius, 5);
  airportDest = new Airport(destination, sphereRadius, 5);
  airplane = new Airplane(airportOrigin, airportDest, sphereRadius, "Airplane.obj", "AirplaneTexture.png");
  
  screenManager = new ScreenManager();
  earthScreen = new EarthScreen(earth, airportOrigin, airportDest, airplane);
  screenManager.switchScreen(earthScreen);
  noStroke();
  
   flightInfo = new FlightInfo(
    "Miami",       // departure location (loaded from file)
    "London",      // arrival location (loaded from file)
    "23:05",    // departure time (loaded from file)
    "11:30",    // arrival time (loaded from file)
    "British Airways",  // airline (loaded from file)
    "BA0208"        // flight number (loaded from file)
  );
}

void draw() {
  screenManager.drawScreen();
}
void mousePressed() {
  screenManager.handleMousePressed();
}

void mouseDragged() {
  screenManager.handleMouseDragged();
}

void mouseReleased() {
   screenManager.handleMouseReleased();
}

void mouseWheel(MouseEvent event) {
  screenManager.handleMouseWheel(event);
}

void keyPressed() {
  screenManager.handleKeyPressed();
}

//Helper Functions
PMatrix3D getRotationMatrix(float angle, PVector axis) {
  float c = cos(angle);
  float s = sin(angle);
  float t = 1 - c;
  float x = axis.x, y = axis.y, z = axis.z;
  return new PMatrix3D(
    t * x * x + c,      t * x * y - s * z,  t * x * z + s * y, 0,
    t * x * y + s * z,   t * y * y + c,      t * y * z - s * x, 0,
    t * x * z - s * y,   t * y * z + s * x,  t * z * z + c,     0,
    0,                  0,                  0,                 1
  );
}

PVector getArcballVector(float x, float y) {
  float radius = min(width, height) / 2;
  float dx = (x - width/2) / radius;
  float dy = (y - height/2) / radius;
  PVector v = new PVector(dx, dy, 0);
  float mag = v.mag();
  if (mag > 1.0) {
    v.normalize();
  } else {
    v.z = sqrt(1.0 - mag * mag);
  }
  return v;
}

void multiplyP3DMatrixScalar(PMatrix3D mat, float s) {
  mat.m00 *= s;  mat.m01 *= s;  mat.m02 *= s;  mat.m03 *= s;
  mat.m10 *= s;  mat.m11 *= s;  mat.m12 *= s;  mat.m13 *= s;
  mat.m20 *= s;  mat.m21 *= s;  mat.m22 *= s;  mat.m23 *= s;
  mat.m30 *= s;  mat.m31 *= s;  mat.m32 *= s;  mat.m33 *= s;
  
}
