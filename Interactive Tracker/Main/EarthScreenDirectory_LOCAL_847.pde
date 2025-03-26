
class EarthScreen extends Screen {
  
  Earth earth;
  Airport airportOrigin;
  Airport airportDest;
  Airplane airplane;
  
  EarthScreen(Earth earth, Airport airportOrigin, Airport airportDest, Airplane airplane) {
      this.earth = earth;
      this.airportOrigin = airportOrigin;
      this.airportDest = airportDest;
      this.airplane = airplane;
  }
  
 void draw() {
  background(0);
      if (showFlightInfo) {
    flightInfo.display();
  }
    for (Star star : stars) {
    star.update(earth);
    star.display();
  }
  for (Star star : moreStars) {
    star.update(earth);
    star.display();
  }
  for (Star star : evenMoreStars) {
    star.update(earth);
    star.display();
  }

  earth.update();
    
  lights();
  directionalLight(255, 255, 255, 1, 1, 1);

  
  // Center the screen once and apply global rotation
  translate(width/2, height/2, 0);
  applyMatrix(earth.rotationMatrix);
  
  // Draw stars in the global coordinate system (they share the same center)


  // Draw Earth and its related objects
  pushMatrix();
    // Only apply zooming for Earth and its related objects
    scale(earth.zoomFactor);

    earth.display();
    airportOrigin.display();
    airportDest.display();
    airplane.update();
    airplane.displayPath();
    airplane.display();
  popMatrix();
  
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
        earth.inertiaAngle = 0;
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
