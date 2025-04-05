class EarthMenu {
  PShape shape;
  PImage texture;
  PMatrix3D rotationMatrix;
  
  // The constructor expects a PApplet (typically your main sketch) and an Assets instance.
  EarthMenu(String shapeFile, String textureFile, PApplet p, Assets assets) {
    assets.loadEarthAssets(p, shapeFile, textureFile);
    shape = assets.earthShape;
    texture = assets.earthTexture;
    shape.setTexture(texture);
    rotationMatrix = new PMatrix3D();
  }
  
  void slowRotate() {
    rotationMatrix.preApply(getUnRotationMatrix(0.001, new PVector(0,1,0)));
  }
  
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
