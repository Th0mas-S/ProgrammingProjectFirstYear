class Airplane {
  PShape shape;
  PImage texture;
  
  PVector start;
  PVector end;
  PVector currentPos;
  PVector lastScreenPos;
  
  boolean moving = false;
    
  float t = 0;
  float sphereRadius;
  float lastUpdateTime;

  Airplane(Airport origin, Airport destination, float sphereRadius, String shapeFile, String textureFile) {
    shape = loadShape(shapeFile);
    texture = loadImage(textureFile);
    shape.setTexture(texture);
    this.sphereRadius = sphereRadius;
    start = origin.getPosition();
    end = destination.getPosition();
    currentPos = start.copy();
    lastUpdateTime = millis();
    lastScreenPos = new PVector();
  }
  
  PVector slerp(PVector v0, PVector v1, float t) {
    PVector v0n = v0.copy().normalize();
    PVector v1n = v1.copy().normalize();
    float dotVal = constrain(v0n.dot(v1n), -1, 1);
    float theta = acos(dotVal);
    if (theta == 0) return v0n.copy();
    float sinTheta = sin(theta);
    float factor0 = sin((1 - t) * theta) / sinTheta;
    float factor1 = sin(t * theta) / sinTheta;
    PVector result = PVector.add(PVector.mult(v0n, factor0), PVector.mult(v1n, factor1));
    result.mult(sphereRadius);
    return result;
  }
  
  void update() {
    if (!moving) return;
    float now = millis();
    float dt = (now - lastUpdateTime) / 1000.0;
    lastUpdateTime = now;
    t += dt / 21.0;
    if (t > 1) t = 0;
    PVector pt = slerp(start, end, t);
    pt.normalize();
    float offset = 20 * sin(PI * t);
    pt.mult(sphereRadius + offset);
    currentPos = pt;
  }
  
  void displayPath() {
    int segments = 100;
    pushStyle();
    stroke(0, 255, 0);
    strokeWeight(2);
    noFill();
    beginShape();
    for (int i = 0; i <= segments; i++) {
      float tt = i / float(segments);
      PVector pt = slerp(start, end, tt);
      pt.normalize();
      float offset = 20 * sin(PI * tt);
      pt.mult(sphereRadius + offset);
      vertex(pt.x, pt.y, pt.z);
    }
    endShape();
    popStyle();
  }
  
  void display() {
    pushMatrix();
    translate(currentPos.x, currentPos.y, currentPos.z);
  
    float dtLocal = 0.001;
    float tFuture = constrain(t + dtLocal, 0, 1);
    PVector futurePos = slerp(start, end, tFuture);
    futurePos.normalize();
    float offsetFuture = 20 * sin(PI * tFuture);
    futurePos.mult(sphereRadius + offsetFuture);
  
    PVector tangent = PVector.sub(futurePos, currentPos);
    PVector up = currentPos.copy().normalize();
    PVector forward = tangent.copy();
    float dot = forward.dot(up);
    forward.sub(PVector.mult(up, dot));
    if (forward.mag() < 0.0001) forward = new PVector(0, 0, 1);
    else forward.normalize();
    PVector right = up.cross(forward, null).normalize();
  
    PMatrix3D m = new PMatrix3D(
      right.x, up.x, forward.x, 0,
      right.y, up.y, forward.y, 0,
      right.z, up.z, forward.z, 0,
      0,       0,    0,         1
    );
    applyMatrix(m);
  
    float sx = screenX(0, 0, 0);
    float sy = screenY(0, 0, 0);
    lastScreenPos.set(sx, sy, 0);
    boolean isHovered = (dist(mouseX, mouseY, sx, sy) < 50);
  
    if (isHovered) {
      tint(255, 255, 0);
      scale(18);
    } else {
      noTint();
      scale(15);
    }
    
    shape(shape);
    popMatrix();
  }
}
