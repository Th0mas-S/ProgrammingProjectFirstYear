class Airport {
  float lat;
  float lon;
  float sphereRadius;
  float diameter;
  PVector lastScreenPos;

  Airport(Location loc, float sphereRadius, float diameter) {
    this.lat = loc.lat;
    this.lon = loc.lon;
    this.sphereRadius = sphereRadius;
    this.diameter = diameter;
    this.lastScreenPos = new PVector();
  }

  PVector getPosition() {
    float theta = radians(90 - lat);
    float phi = radians(lon);
    float x = sphereRadius * sin(theta) * sin(phi);
    float y = sphereRadius * cos(theta);
    float z = sphereRadius * sin(theta) * cos(phi);
    return new PVector(x, y, z);
  }
}
