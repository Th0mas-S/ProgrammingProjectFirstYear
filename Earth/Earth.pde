PShape earth;
PImage gradientTexture;
PImage earthDiffuse;
PMatrix3D rotationMatrix;
PVector lastArcball;
float zoomFactor = 0.5;

void setup() {
  size(1000, 1000, P3D);
  earth = loadShape("Earth.obj");
  int texSize = 256;
  gradientTexture = createImage(texSize, texSize, RGB);
  gradientTexture.loadPixels();
  for (int y = 0; y < texSize; y++) {
    int c = lerpColor(color(255, 0, 0), color(0, 0, 255), y / float(texSize - 1));
    for (int x = 0; x < texSize; x++) {
      gradientTexture.pixels[y * texSize + x] = c;
    }
  }
  gradientTexture.updatePixels();
  //earthDiffuse = loadImage("earthDiffuse.png");
  earth.setTexture(gradientTexture);
  rotationMatrix = new PMatrix3D();
}

void draw() {
  background(0);
  pushMatrix();
  translate(width/2, height/2);
  applyMatrix(rotationMatrix);
  scale(zoomFactor);
  shape(earth);
  popMatrix();
}

void mousePressed() {
  if (mouseButton == LEFT) {
    lastArcball = getArcballVector(mouseX, mouseY);
  }
}

void mouseDragged() {
  if (mouseButton == LEFT) {
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
