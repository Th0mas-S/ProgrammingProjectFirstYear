PShape earth;
PImage earthDiffuse;
PShape bigSphere;
PImage bigSphereDiffuse;
PMatrix3D rotationMatrix;
PVector lastArcball;
float zoomFactor = 0.5;

void setup() {
  fullScreen(P3D);
  
  // Load and set up the earth sphere (original size)
  earth = loadShape("Earth.obj");
  earthDiffuse = loadImage("earthDiffuse.png");
  earth.setTexture(earthDiffuse);
  
  // Load and set up the big sphere (5x bigger)
  bigSphere = loadShape("Earth.obj");
  bigSphereDiffuse = loadImage("SpaceSky.jpg");  
  bigSphere.setTexture(bigSphereDiffuse);
  
  rotationMatrix = new PMatrix3D();
}

void draw() {
  background(0);
  
  // Draw the big sphere (5x bigger than earth)
  pushMatrix();
  translate(width/2, height/2);
  applyMatrix(rotationMatrix);
  scale(zoomFactor * 25);  // 5x scale relative to earth
  shape(bigSphere);
  popMatrix();
  
  // Draw the earth sphere (original size) on top
  pushMatrix();
  translate(width/2, height/2);
  applyMatrix(rotationMatrix);
  scale(zoomFactor);
  shape(earth);
  popMatrix();
}

void mousePressed() {
  if (mouseButton == LEFT) {
    // Only set up the arcball vector if not using the control key rotation
    if (!(keyPressed && keyCode == CONTROL)) {
      lastArcball = getArcballVector(mouseX, mouseY);
    }
  }
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    // If Control is held, rotate only around the y-axis using horizontal movement
    if (keyPressed && keyCode == CONTROL) {
      float angle = (mouseX - pmouseX) * 0.01;
      PMatrix3D delta = new PMatrix3D();
      delta.rotateY(angle);
      rotationMatrix.preApply(delta);
    } else {
      // Regular arcball rotation
      PVector current = getArcballVector(mouseX, mouseY);
      float dotVal = constrain(lastArcball.dot(current), -1, 1);
      float angle = acos(dotVal);
      PVector axis = lastArcball.cross(current, null);
      if (axis.mag() > 0.0001) {
        axis.normalize();
        PMatrix3D delta = getRotationMatrix(angle, axis);
        rotationMatrix.preApply(delta);
      }
      lastArcball = current;
    }
  }
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

PMatrix3D getRotationMatrix(float angle, PVector axis) {
  float c = cos(angle);
  float s = sin(angle);
  float t = 1 - c;
  float x = axis.x, y = axis.y, z = axis.z;
  PMatrix3D m = new PMatrix3D(
    t * x * x + c,    t * x * y - s * z,  t * x * z + s * y, 0,
    t * x * y + s * z,  t * y * y + c,    t * y * z - s * x, 0,
    t * x * z - s * y,  t * y * z + s * x,  t * z * z + c,   0,
    0,                0,                0,                1
  );
  return m;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  zoomFactor -= e * 0.05;
  zoomFactor = max(0.1, zoomFactor);
}

void keyPressed() {
  if (key == ' ') {
    rotationMatrix = new PMatrix3D();
    zoomFactor = 0.5;
  }
}
