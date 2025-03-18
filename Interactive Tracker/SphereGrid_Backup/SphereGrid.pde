class SphereGrid {
  float sphereRadius;
  float latStep;
  float lonStep;
  
  SphereGrid(float sphereRadius, float latStep, float lonStep) {
    this.sphereRadius = sphereRadius;
    this.latStep = latStep;
    this.lonStep = lonStep;
  }
  
  void display() {
    pushStyle();
    fill(255, 255, 0);
    for (float lat = -80; lat <= 80; lat += latStep) {
      float theta = radians(90 - lat);
      for (float lon = -180; lon <= 180; lon += lonStep) {
        float phi = radians(lon);
        float x = sphereRadius * sin(theta) * sin(phi);
        float y = sphereRadius * cos(theta);
        float z = sphereRadius * sin(theta) * cos(phi);
        pushMatrix();
        translate(x, y, z);
        sphere(3);
        popMatrix();
      }
    }
    popStyle();
  }
}
