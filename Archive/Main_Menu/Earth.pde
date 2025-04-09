class Earth {
  PShape shape;
  PImage texture;
  PMatrix3D rotationMatrix;
  
  Earth(String shapeFile, String textureFile) {
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
