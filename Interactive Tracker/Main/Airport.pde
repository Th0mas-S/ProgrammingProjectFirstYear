/*class Airport {
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
    lastScreenPos = new PVector();
  }

  PVector getPosition() {
    float theta = radians(90 - lat);
    float phi = radians(lon);
    float x = sphereRadius * sin(theta) * sin(phi);
    float y = sphereRadius * cos(theta);
    float z = sphereRadius * sin(theta) * cos(phi);
    return new PVector(x, y, z);
  }

  void display() {
    pushMatrix();
    PVector pos = getPosition();
    translate(pos.x, pos.y, pos.z);

    float sx = screenX(0, 0, 0);
    float sy = screenY(0, 0, 0);
    lastScreenPos.set(sx, sy, 0);

    boolean isHovered = (dist(mouseX, mouseY, sx, sy) < (diameter / 2 + 10));
    if (isHovered) {
      fill(255, 255, 0);
      scale(1.2);
    } else {
      fill(255, 0, 0);
    }

    PVector normal = pos.copy().normalize();
    PVector zAxis = new PVector(0, 0, 1);
    float angle = acos(constrain(normal.dot(zAxis), -1, 1));
    PVector axis = zAxis.cross(normal, null);
    if (axis.mag() < 0.0001) {
      axis = new PVector(1, 0, 0);
    }
    rotate(angle, axis.x, axis.y, axis.z);

    noStroke();
    ellipseMode(CENTER);
    ellipse(0, 0, diameter, diameter);
    popMatrix();
  }
}*/


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
