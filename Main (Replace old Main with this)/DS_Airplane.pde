class AirplaneDirectory {
  PVector start, end, currentPos;
  float sphereRadius, startMinute;
  int duration;
  PShape model;  // Using a 3D model loaded from an OBJ.
  
  // Flight info fields.
  String departureLocation, arrivalLocation;
  String departureTime, arrivalTime;
  String airlineName, airlineCode, flightNumber;
  String originCode, destCode;
  
  boolean hasArrived = false;
  
  // Associated Flight.
  Flight flight;
  
  AirplaneDirectory(
    Airport origin, Airport dest, float sphereRadius, PShape model, float startMinute,
    String depLoc, String arrLoc, String depTime, String arrTime,
    String airlineName, String airlineCode, String flightNumber,
    int duration, String originCode, String destCode,
    Flight flight
  ) {
    this.start = origin.getPosition();
    this.end = dest.getPosition();
    this.currentPos = start.copy();
    this.sphereRadius = sphereRadius;
    this.model = model;
    // Load and set the texture unconditionally.
    if (this.model != null) {
      PImage texture = loadImage("AirplaneTexture.png");
      if (texture != null) {
        this.model.setTexture(texture);
      }
    }
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
    
    this.flight = flight;
  }
  
  // This update() method loops the flight animation continuously.
  void update(float currentTime) {
    if (hasArrived) return;
  
    float elapsed = currentTime - startMinute;
    if (elapsed >= duration) {
      elapsed = duration;
      hasArrived = true;
    } else if (elapsed < 0) {
      elapsed = 0;
    }
  
    float t = elapsed / (float)duration;
  
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
    pushMatrix();
      translate(currentPos.x, currentPos.y, currentPos.z);
      // Calculate orientation so the airplane faces the travel direction.
      PVector travelDir = PVector.sub(end, start).normalize();
      PVector globeNormal = currentPos.copy().normalize();
      PVector right = globeNormal.cross(travelDir).normalize();
      PVector forward = right.cross(globeNormal).normalize();
      PMatrix3D m = new PMatrix3D(
        forward.x, globeNormal.x, right.x, 0,
        forward.y, globeNormal.y, right.y, 0,
        forward.z, globeNormal.z, right.z, 0,
        0,         0,             0,       1
      );
      applyMatrix(m);
      rotateY(HALF_PI);
      
      scale(10);
      
      if (model != null) {
        shape(model);
      }
    popMatrix();
  }
  
  PVector getPosition() {
    return currentPos;
  }
}
