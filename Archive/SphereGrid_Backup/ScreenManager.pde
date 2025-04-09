class ScreenManager {
  int currentScreen;
  Earth earth;
  SphereGrid grid;
  Airport airportOrigin;
  Airport airportDest;
  Airplane airplane;
  
  ScreenManager(Earth earth, SphereGrid grid, Airport airportOrigin, Airport airportDest, Airplane airplane) {
    this.earth = earth;
    this.grid = grid;
    this.airportOrigin = airportOrigin;
    this.airportDest = airportDest;
    this.airplane = airplane;
    currentScreen = 0;
  }
  
  void drawScreen() {
    if (currentScreen == 0) {
      background(0);
      earth.update();
      
      pushMatrix();
      translate(width/2, height/2);
      applyMatrix(earth.rotationMatrix);
      scale(earth.zoomFactor);
      
      earth.display();
      grid.display();
      airportOrigin.display();
      airportDest.display();
      
      airplane.update();
      airplane.displayPath();
      airplane.display();
      
      popMatrix();
      
      if (showFlightInfo) {
        flightInfo.display();
      }
    
    } else if (currentScreen == 1) {
      background(50);
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(64);
      text("Origin Airport", width/2, height/3);
      
      textSize(32);
      fill(200);
      rectMode(CENTER);
      rect(width/2, height*2/3, 200, 50);
      fill(0);
      text("Return", width/2, height*2/3);
    } else if (currentScreen == 2) {
      background(50);
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(64);
      text("Destination Airport", width/2, height/3);
      
      textSize(32);
      fill(200);
      rectMode(CENTER);
      rect(width/2, height*2/3, 200, 50);
      fill(0);
      text("Return", width/2, height*2/3);
    }
  }
  
  void handleMousePressed() {
    if (currentScreen == 0) {
      if (mouseButton == LEFT) {
        if (dist(mouseX, mouseY, airportOrigin.lastScreenPos.x, airportOrigin.lastScreenPos.y) < (airportOrigin.diameter/2 + 10)) {
          currentScreen = 1;
          return;
        }
        if (dist(mouseX, mouseY, airportDest.lastScreenPos.x, airportDest.lastScreenPos.y) < (airportDest.diameter/2 + 10)) {
          currentScreen = 2;
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
    } else { 
      if (mouseX > width/2 - 100 && mouseX < width/2 + 100 &&
          mouseY > height*2/3 - 25 && mouseY < height*2/3 + 25) {
        currentScreen = 0;
      }
    }
  }
}
