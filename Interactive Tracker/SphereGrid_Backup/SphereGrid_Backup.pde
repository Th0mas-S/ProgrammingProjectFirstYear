ScreenManager screenManager;
Earth earth;
//SphereGrid grid;
Airport airportOrigin;
Airport airportDest;
Airplane airplane;
FlightInfo flightInfo;

Location origin = new Location(-125.5, 119.6);
Location destination = new Location(-51.2, 90.2);

boolean showFlightInfo = false;


float sphereRadius = 640;

void setup() {
  size(1000, 1000, P3D);
  noSmooth();
   
  earth = new Earth("Earth.obj", "earthDiffuse.png");
  //grid = new SphereGrid(sphereRadius, 6.22, 6.22);
  airportOrigin = new Airport(origin, sphereRadius, 5);
  airportDest = new Airport(destination, sphereRadius, 5);
  airplane = new Airplane(airportOrigin, airportDest, sphereRadius, "Airplane.obj", "AirplaneTexture.png");
  
  screenManager = new ScreenManager(earth, /*grid,*/ airportOrigin, airportDest, airplane);
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
  println(frameRate);
  screenManager.drawScreen();
}

void mousePressed() {
  screenManager.handleMousePressed();
}

void mouseDragged() {
  if (screenManager.currentScreen == 0) {
    if (mouseButton == LEFT || mouseButton == RIGHT) {
      if (mouseButton == RIGHT || (mouseButton == LEFT && keyPressed && keyCode == CONTROL)) {
        float angle = (mouseX - pmouseX) * 0.01;
        PMatrix3D delta = getRotationMatrix(angle, new PVector(0, 1, 0));
        earth.rotationMatrix.preApply(delta);
        earth.inertiaAngle = angle;
        earth.inertiaAxis = new PVector(0, 1, 0);
      } else {
        PVector current = getArcballVector(mouseX, mouseY);
        float dotVal = constrain(earth.lastArcball.dot(current), -1, 1);
        float angle = acos(dotVal);
        PVector axis = earth.lastArcball.cross(current, null);
        if (axis.mag() > 0.0001) {
          axis.normalize();
          PMatrix3D delta = getRotationMatrix(angle, axis);
          earth.rotationMatrix.preApply(delta);
          earth.inertiaAngle = angle;
          earth.inertiaAxis = axis.copy();
        }
        earth.lastArcball = current;
      }
    }
  }
}

void mouseReleased() {
  if (screenManager.currentScreen == 0) {
    earth.isDragging = false;
    cursor(ARROW);
  }
}

void mouseWheel(MouseEvent event) {
  if (screenManager.currentScreen == 0) {
    float e = event.getCount();
    earth.zoomFactor -= e * 0.05;
    earth.zoomFactor = constrain(earth.zoomFactor, 0.1, 1.70);
  }
}

void keyPressed() {
  if (screenManager.currentScreen == 0) {
    if (key == ' ') {
      earth.rotationMatrix = new PMatrix3D();
      earth.zoomFactor = 0.8;
    }
    if (keyCode == ENTER) {
      airplane.moving = true;
      airplane.t = 0;
      airplane.lastUpdateTime = millis();
    }
  }
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
