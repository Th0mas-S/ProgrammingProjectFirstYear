class AirplaneMenu {
  PShape shape;
  PImage texture;
  
  float sphereRadius;
  float lastUpdateTime;
  boolean moving = true;
  PVector currentPos;
  PVector lastScreenPos;
  float angle;
  float orbitSpeed = 0.35;
  float tiltAngle;
  
  AirplaneMenu(float sphereRadius, String shapeFile, String textureFile) {
    shape = loadShape(shapeFile);
    texture = loadImage(textureFile);
    shape.setTexture(texture);
    
    this.sphereRadius = sphereRadius;
    boolean spawnTop = random(1) < 0.5;
    angle = PI/2;
    tiltAngle = spawnTop ? 3 * PI/2 : PI/2;
    
    currentPos = new PVector();
    update();
    
    lastUpdateTime = millis();
    lastScreenPos = new PVector();
  }
  
  void update() {
    if (!moving) return;
    
    float now = millis();
    float dt = (now - lastUpdateTime) / 1000.0;
    lastUpdateTime = now;
    
    angle += orbitSpeed * dt;
    if (angle >= TWO_PI) {
      angle = random(TWO_PI);
      tiltAngle = random(TWO_PI);
    }
    
    float offset = 20 * sin(angle * 2.0);
    float r = sphereRadius + offset + altitudeOffset - 6;
    
    float baseX = r * cos(angle);
    float baseZ = r * sin(angle);
    
    float finalX = baseX;
    float finalY = - baseZ * sin(tiltAngle);
    float finalZ = baseZ * cos(tiltAngle);
    
    currentPos.set(finalX, finalY, finalZ);
  }
  
  void display() {
    pushMatrix();
    translate(currentPos.x, currentPos.y, currentPos.z);
      
      float futureAngle = angle + 0.01;
      float offsetFuture = 20 * sin(futureAngle * 2.0);
      float rFuture = sphereRadius + offsetFuture + altitudeOffset;
      float baseX_future = rFuture * cos(futureAngle);
      float baseZ_future = rFuture * sin(futureAngle);
      float finalX_future = baseX_future;
      float finalY_future = - baseZ_future * sin(tiltAngle);
      float finalZ_future = baseZ_future * cos(tiltAngle);
      PVector futurePos = new PVector(finalX_future, finalY_future, finalZ_future);
      
      PVector tangent = PVector.sub(futurePos, currentPos);
      PVector up = currentPos.copy().normalize();
      
      PVector forward = tangent.copy();
      float dot = forward.dot(up);
      forward.sub(PVector.mult(up, dot));
      if (forward.mag() < 0.0001) {
        forward.set(0, 0, 1);
      } else {
        forward.normalize();
      }
      
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

      scale(15);
      shape(shape);
    popMatrix();
  }
}
