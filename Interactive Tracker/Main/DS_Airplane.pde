class AirplaneDirectory {
  PVector start, end, currentPos;
  float sphereRadius, startMinute;
  int duration;
  boolean finished = false;
  
  PImage model; 

  // Flight info fields.
  String departureLocation, arrivalLocation;
  String departureTime, arrivalTime;
  String airlineName, airlineCode, flightNumber;
  String originCode, destCode;
  
  // The single Flight associated with this airplane.
  Flight flight;
  
  AirplaneDirectory(
    Airport origin, Airport dest, float sphereRadius, PImage model, float startMinute,
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
  }
  
  void display() {
  if (model == null) {
    println("Airplane model is null in AirplaneDirectory!");
    return;
  }
  pushMatrix();
    translate(currentPos.x, currentPos.y, currentPos.z);
    // Calculate orientation...
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
    rotateX(HALF_PI);
    rotateZ(PI);
    
    float factor = 0.01;
    imageMode(CENTER);
    image(model, 0, 0, model.width * factor, model.height * factor);
  popMatrix();
}
  
  PVector getPosition() {
    return currentPos;
  }
}
