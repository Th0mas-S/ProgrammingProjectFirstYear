class Airplane {
  PVector start, end, currentPos;
  float sphereRadius, startMinute;
  int duration;
  boolean finished = false;
  boolean hovered = false;
  boolean selected = false;
  
  PImage model; 

  // Flight info fields
  String departureLocation, arrivalLocation;
  String departureTime, arrivalTime;
  String airlineName, airlineCode, flightNumber;
  String departureDate;
  String originCode, destCode;
  
  // NEW: Store the associated Flight object.
  Flight flight;
  
  Airplane(
    Airport origin, Airport dest, float sphereRadius, PImage model, float startMinute,
    String depLoc, String arrLoc, String depTime, String arrTime,
    String airlineName, String airlineCode, String flightNumber,
    int duration, String originCode, String destCode,
    // NEW: Add Flight as a parameter
    Flight flight
  ) {
    this.start = origin.getPosition();
    this.end = dest.getPosition();
    this.currentPos = start.copy();
    this.sphereRadius = sphereRadius;
    this.model = model;
    this.startMinute = startMinute;
    this.duration = duration;
    this.originCode = originCode;
    this.destCode = destCode;

    this.departureLocation = depLoc;
    this.arrivalLocation = arrLoc;
    this.departureTime = depTime;
    this.arrivalTime = arrTime;
    this.airlineName = airlineName;
    this.airlineCode = airlineCode;
    this.flightNumber = flightNumber;
    
    // Optionally set departureDate if needed.
    // this.departureDate = departureDate; // If available
    
    // NEW: Assign the Flight object.
    this.flight = flight;
  }

  void update(float currentMinute) {
    if (finished) return;

    float elapsed = currentMinute - startMinute;
    float t = constrain(elapsed / float(duration), 0, 1);
    if (t >= 1) {
      finished = true;
      return;
    }

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

    float sx = screenX(currentPos.x, currentPos.y, currentPos.z);
    float sy = screenY(currentPos.x, currentPos.y, currentPos.z);
    hovered = dist(mouseX, mouseY, sx, sy) < 20;
  }
  
  void display() {
    if (finished) return;
    pushMatrix();
      translate(currentPos.x, currentPos.y, currentPos.z);
      // Orientation calculations:
      PVector travelDir = PVector.sub(end, start).normalize();
      PVector globeNormal = currentPos.copy().normalize();
      PVector right = globeNormal.cross(travelDir).normalize();
      PVector forward = right.cross(globeNormal).normalize();
      PMatrix3D m = new PMatrix3D(
        forward.x, globeNormal.x, right.x, 0,
        forward.y, globeNormal.y, right.y, 0,
        forward.z, globeNormal.z, right.z, 0,
        0,         0,              0,      1
      );
      applyMatrix(m);
      rotateX(HALF_PI);
      rotateZ(PI);
      
      // Instead of scaling the coordinate system, choose a scale factor and use it to resize the model image.
      float factor = selected ? 0.02 : 0.01;
      
      if (selected) {
        tint(255, 255, 0);
      } else {
        noTint();
      }
      
      imageMode(CENTER);
      // Draw the model at the scaled size, so its position remains unchanged.
      image(model, 0, 0, model.width * factor, model.height * factor);
    popMatrix();
  }

  boolean closeButtonClicked(int mouseX, int mouseY) {
    float boxW = 350;
    float boxH = 255;
    float x = width - boxW - 10;
    float y = 10;
    float closeSize = 20;
    float closeX = x + boxW - closeSize - 10;
    float closeY = y + boxH - closeSize - 10;

    return mouseX >= closeX && mouseX <= closeX + closeSize &&
           mouseY >= closeY && mouseY <= closeY + closeSize;
  }

  boolean isHovered() {
    return hovered;
  }
  
  PVector getPosition() {
    return currentPos;
  }
}
