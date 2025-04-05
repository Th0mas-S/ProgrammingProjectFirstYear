
class Earth {
  PShape shape;
  PImage texture;
  
  PMatrix3D rotationMatrix;
  PVector lastArcball;
  PVector inertiaAxis;  
  
  float zoomFactor = 0.6;
  float inertiaAngle = 0;
  float friction = 0.95;
  boolean isDragging = false;
  
  Earth(String shapeFile, String textureFile, PApplet p, Assets assets) {
    assets.loadEarthAssets(p, shapeFile, textureFile);
    shape = assets.earthShape;
    texture = assets.earthTexture;
    shape.setTexture(texture);
    
    rotationMatrix = new PMatrix3D();
    inertiaAxis = new PVector(0, 1, 0);
    lastArcball = new PVector();
  }
  
  void update() {
    if (!isDragging && abs(inertiaAngle) > 0.0001) {
      PMatrix3D inertiaDelta = getRotationMatrix(inertiaAngle, inertiaAxis);
      rotationMatrix.preApply(inertiaDelta);
      inertiaAngle *= friction;
    } else if (abs(inertiaAngle) <= 0.0001) {
      inertiaAngle = 0;
    }
  }
  
  void display() {
    shape(shape);
  }
  
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
}
