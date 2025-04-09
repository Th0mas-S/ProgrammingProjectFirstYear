class Assets {
  PShape earthShape;
  PImage earthTexture;

  void loadEarthAssets(PApplet p, String shapeFile, String textureFile) {
    if (earthShape == null) {
      earthShape = p.loadShape(shapeFile);
    }
    if (earthTexture == null) {
      earthTexture = p.loadImage(textureFile);
    }
  }
}
