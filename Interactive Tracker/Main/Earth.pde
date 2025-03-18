class Earth {
  PShape shape;
  PImage texture;
  
  PMatrix3D rotationMatrix;
  PVector lastArcball;
  PVector inertiaAxis;  
  
  float zoomFactor = 0.8;
  float inertiaAngle = 0;
  float friction = 0.95;

  boolean isDragging = false;
  
  Earth(String shapeFile, String textureFile) {
    shape = loadShape(shapeFile);
    texture = loadImage(textureFile);
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
}
