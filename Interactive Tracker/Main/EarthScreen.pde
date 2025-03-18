
ArrayList<Airport> loadAllAirports(String fileName) {
  ArrayList<Airport> airports = new ArrayList<Airport>(300);
  
  String[] readIn = loadStrings(fileName);
  
  for(int i=1; i<readIn.length; i++){
    String[] row = split(readIn[i], ",");
    airports.add(new Airport(new Location(-parseFloat(row[1])  + 0.2617, 1.0071 * parseFloat(row[2]) + 90.35), sphereRadius, 5)); 
  }
  
  return airports;
}

class EarthScreen extends Screen {
  
  Earth earth;
  Airport airportOrigin;
  Airport airportDest;
  Airplane airplane;
  
  ArrayList<Airport> allAirports;
  
  EarthScreen(Earth earth, Airport airportOrigin, Airport airportDest, Airplane airplane) {
      this.earth = earth;
      this.airportOrigin = airportOrigin;
      this.airportDest = airportDest;
      this.airplane = airplane;
      
      allAirports = loadAllAirports("coordinate.csv");
  }
  
  void draw() {
      background(0);
      earth.update();
      
      pushMatrix();
      translate(width/2, height/2);
      applyMatrix(earth.rotationMatrix);
      scale(earth.zoomFactor);
      
      earth.display();
      airportOrigin.display();
      airportDest.display();

      
      for(Airport a : allAirports) {
        a.display();
      }
      
      airplane.update();
      airplane.displayPath();
      airplane.display();
      
      popMatrix();
      
      if (showFlightInfo) {
        flightInfo.display();
      }    
  }
  
  void mousePressed() {
  if (mouseButton == LEFT) {
        if (dist(mouseX, mouseY, airportOrigin.lastScreenPos.x, airportOrigin.lastScreenPos.y) < (airportOrigin.diameter/2 + 10)) {
          screenManager.switchScreen(new AirportInfoScreen("Origin"));
          return;
        }
        if (dist(mouseX, mouseY, airportDest.lastScreenPos.x, airportDest.lastScreenPos.y) < (airportDest.diameter/2 + 10)) {
          screenManager.switchScreen(new AirportInfoScreen("Destination"));
          return;
        }
        if (dist(mouseX, mouseY, airplane.lastScreenPos.x, airplane.lastScreenPos.y) < 50) {
        showFlightInfo = true;
      }
      }
      if (mouseButton == LEFT || mouseButton == RIGHT) {
        earth.isDragging = true;
        cursor(MOVE);
        if (mouseButton == LEFT && !(keyPressed && keyCode == CONTROL)) {
          earth.lastArcball = getArcballVector(mouseX, mouseY);
        }
      }
  }
  
  void mouseDragged() {
    if (mouseButton == LEFT || mouseButton == RIGHT) {
      if (mouseButton == RIGHT || (mouseButton == LEFT && keyPressed && keyCode == CONTROL)) {
        float angle = (mouseX - pmouseX) * 0.01;
        PMatrix3D delta = getRotationMatrix(angle, new PVector(0, 1, 0));
        earth.rotationMatrix.preApply(delta);
        earth.inertiaAngle = angle;
        earth.inertiaAxis = new PVector(0, 1, 0);
      } else {
        PVector current = getArcballVector(mouseX, mouseY);
        float dotVal = constrain(earth.lastArcball.dot(current), -1, 1);
        float angle = acos(dotVal);
        PVector axis = earth.lastArcball.cross(current, null);
        if (axis.mag() > 0.0001) {
          axis.normalize();
          PMatrix3D delta = getRotationMatrix(angle, axis);
          earth.rotationMatrix.preApply(delta);
          earth.inertiaAngle = angle;
          earth.inertiaAxis = axis.copy();
        }
        earth.lastArcball = current;
      }
    }
  }
  
  void mouseReleased() {
    earth.isDragging = false;
    cursor(ARROW);
  }
 
  void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    earth.zoomFactor -= e * 0.05;
    earth.zoomFactor = constrain(earth.zoomFactor, 0.1, 1.3);
  }
  
  void keyPressed() {
    if (key == ' ') {
      earth.rotationMatrix = new PMatrix3D();
      earth.zoomFactor = 0.8;
    }
    if (keyCode == ENTER) {
      airplane.moving = true;
      airplane.t = 0;
      airplane.lastUpdateTime = millis();
    }
  }
  
}
