
/*class Airplane {
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
  PVector lastScreenPos;
  
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
    startNorm = start.copy().normalize();
    endNorm = end.copy().normalize();
    
    currentPos = start.copy();
    lastUpdateTime = millis();
    lastScreenPos = new PVector();
  }
  
  PVector slerpOptimized(float t, PVector temp1, PVector temp2, PVector result) {
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
}*/




//2D Image flight
/* 
class Airplane {
  PVector start;
  PVector end;
  PVector currentPos;
  PImage img;
  float sphereRadius;
  float startMinute;
  int duration = 180; // flight duration in minutes
  boolean finished = false;

  Airplane(Airport origin, Airport dest, float sphereRadius, PImage img, float departureMinute) {
    this.start = origin.getPosition();
    this.end = dest.getPosition();
    this.currentPos = start.copy();
    this.sphereRadius = sphereRadius;
    this.img = img;
    this.startMinute = departureMinute;
  }

  void update(float currentMinute) {
    if (finished) return;

    float elapsed = currentMinute - startMinute;
    float t = constrain(elapsed / float(duration), 0, 1);

    if (t >= 1) {
      finished = true;
      return;
    }

    // Slerp for smooth arc travel
    PVector startNorm = start.copy().normalize();
    PVector endNorm = end.copy().normalize();
    float dot = constrain(startNorm.dot(endNorm), -1, 1);
    float theta = acos(dot);
    float sinTheta = sin(theta);

    if (sinTheta < 0.001) {
      currentPos = start.copy();
    } else {
      PVector p1 = PVector.mult(startNorm, sin((1 - t) * theta));
      PVector p2 = PVector.mult(endNorm, sin(t * theta));
      currentPos = PVector.add(p1, p2).div(sinTheta).normalize().mult(sphereRadius);
    }
  }

void display() {
  if (finished) return;

  pushMatrix();
  translate(currentPos.x, currentPos.y, currentPos.z);

  // Define orientation vectors
  PVector tangent = PVector.sub(end, start).normalize();     // Direction of travel
  PVector normal = currentPos.copy().normalize();            // Globe up
  PVector right = tangent.cross(normal).normalize();         // Right wing
  PVector forward = normal.cross(right).normalize();         // Nose direction (flat to sphere)

  PMatrix3D m = new PMatrix3D(
    forward.x, normal.x, right.x, 0,
    forward.y, normal.y, right.y, 0,
    forward.z, normal.z, right.z, 0,
    0,         0,        0,       1
  );
  applyMatrix(m);

  // ✅ Rotate 90° around right axis to make bottom edge lie on globe
  rotateX(HALF_PI);
  // ✅ Then flip 180° so the nose points toward destination
  rotateZ(PI);

  imageMode(CENTER);
  image(img, 0, 0, 20, 20);
  popMatrix();
}
}*/




//3D Image
class Airplane {
  PVector start;
  PVector end;
  PVector currentPos;
  float sphereRadius;
  float startMinute;
  int duration = 180; // minutes of flight
  boolean finished = false;

  PShape model;

   Airplane(Airport origin, Airport dest, float sphereRadius, PShape model, float departureMinute, int durationMinutes) {
    this.start = origin.getPosition();
    this.end = dest.getPosition();
    this.currentPos = start.copy();
    this.sphereRadius = sphereRadius;
    this.model = model;
    this.startMinute = departureMinute;
    this.duration = durationMinutes;
  }

  void update(float currentMinute) {
    if (finished) return;

    float elapsed = currentMinute - startMinute;
    float t = constrain(elapsed / float(duration), 0, 1);

    if (t >= 1) {
      finished = true;
      return;
    }

    // Slerp interpolation
    PVector startNorm = start.copy().normalize();
    PVector endNorm = end.copy().normalize();
    float dot = constrain(startNorm.dot(endNorm), -1, 1);
    float theta = acos(dot);
    float sinTheta = sin(theta);

    if (sinTheta < 0.001) {
      currentPos = start.copy();
    } else {
      PVector p1 = PVector.mult(startNorm, sin((1 - t) * theta));
      PVector p2 = PVector.mult(endNorm, sin(t * theta));
      currentPos = PVector.add(p1, p2).div(sinTheta).normalize().mult(sphereRadius);
    }
  }

void display() {
  if (finished) return;

  pushMatrix();
  translate(currentPos.x, currentPos.y, currentPos.z);

  // Build orientation frame relative to globe
  PVector travelDir = PVector.sub(end, start).normalize();  // Nose direction
  PVector globeNormal = currentPos.copy().normalize();      // Up from globe
  PVector right = globeNormal.cross(travelDir).normalize(); // Right wing
  PVector forward = right.cross(globeNormal).normalize();   // Recomputed forward (in-plane)

  // Construct transformation matrix: align airplane with travel
  PMatrix3D m = new PMatrix3D(
    forward.x, globeNormal.x, right.x, 0,
    forward.y, globeNormal.y, right.y, 0,
    forward.z, globeNormal.z, right.z, 0,
    0,         0,              0,      1
  );
  applyMatrix(m);

  // ✅ Rotate model so that Z+ (model's nose) points toward travelDir
  rotateY(HALF_PI);  // Tip it over
  rotateZ(PI);       // Flip to point nose correctly

  scale(15);
  shape(model);
  popMatrix();
}
}
