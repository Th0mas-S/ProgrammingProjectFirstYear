class Airplane {
  PShape shape;
  PImage texture;
  PVector start;
  PVector end;
  PVector startNorm;
  PVector endNorm;
  PVector currentPos;
  float t = 0;
  float sphereRadius;
  float lastUpdateTime;
  boolean moving = false;
  PVector lastScreenPos;  // for hover detection
  
  // Temporary vectors for optimized slerp computations.
  PVector temp1 = new PVector();
  PVector temp2 = new PVector();
  PVector slerpResult = new PVector();
  
  Airplane(Airport origin, Airport destination, float sphereRadius, String shapeFile, String textureFile) {
    shape = loadShape(shapeFile);
    texture = loadImage(textureFile);
    shape.setTexture(texture);
    this.sphereRadius = sphereRadius;
    start = origin.getPosition();
    end = destination.getPosition();
    // Precompute normalized versions (they remain constant after construction).
    startNorm = start.copy().normalize();
    endNorm = end.copy().normalize();
    
    currentPos = start.copy();
    lastUpdateTime = millis();
    lastScreenPos = new PVector();
  }
  
  // Optimized slerp using precomputed startNorm and endNorm.
  PVector slerpOptimized(float t, PVector temp1, PVector temp2, PVector result) {
    // Use precomputed normalized vectors.
    float dotVal = constrain(startNorm.dot(endNorm), -1, 1);
    float theta = acos(dotVal);
    if (theta == 0) {
      result.set(startNorm);
      return result;
    }
    float sinTheta = sin(theta);
    float factor0 = sin((1 - t) * theta) / sinTheta;
    float factor1 = sin(t * theta) / sinTheta;
    temp1.set(PVector.mult(startNorm, factor0));
    temp2.set(PVector.mult(endNorm, factor1));
    result.set(PVector.add(temp1, temp2));
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
    
    slerpOptimized(t, temp1, temp2, slerpResult);
    slerpResult.normalize();
    float offset = 20 * sin(PI * t);
    slerpResult.mult(sphereRadius + offset);
    currentPos.set(slerpResult);
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
      slerpOptimized(tt, temp1, temp2, slerpResult);
      slerpResult.normalize();
      float offset = 20 * sin(PI * tt);
      slerpResult.mult(sphereRadius + offset);
      vertex(slerpResult.x, slerpResult.y, slerpResult.z);
    }
    endShape();
    popStyle();
  }
  
  void display() {
    pushMatrix();
    translate(currentPos.x, currentPos.y, currentPos.z);
    
    float dtLocal = 0.001;
    float tFuture = constrain(t + dtLocal, 0, 1);
    slerpOptimized(tFuture, temp1, temp2, slerpResult);
    slerpResult.normalize();
    float offsetFuture = 20 * sin(PI * tFuture);
    slerpResult.mult(sphereRadius + offsetFuture);
    PVector futurePos = slerpResult.copy();
    
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
