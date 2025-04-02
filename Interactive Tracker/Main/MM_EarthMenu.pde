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
