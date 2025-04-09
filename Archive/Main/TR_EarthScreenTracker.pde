class EarthScreenTracker extends Screen {
  Earth earth;
  CalendarDisplay calendar;
  TimeSlider timeSlider;
  boolean uiHeld = false;
  // Flag to track if a plane was clicked so that earth dragging is disabled.
  boolean planeClicked = false;
  
  ActiveFlightInfo activeFlightInfo;
  
  // Variables for panning.
  PVector panOffset;  // Overall pan offset.
  PVector panStart;   // Starting mouse position when panning.
  
  // Coordinates for the standalone MENU button.
  int menuButtonX, menuButtonY, menuButtonW, menuButtonH;
  // Coordinates for the RESET button.
  int resetButtonX, resetButtonY, resetButtonW, resetButtonH;
  
  EarthScreenTracker(Earth earth) {
    this.earth = earth;
    calendar = new CalendarDisplay();
    timeSlider = new TimeSlider(width / 4, 60, width / 2, 30);
    // Initialize pan variables.
    panOffset = new PVector(0, 0);
    panStart = null;
    
    // Set MENU button coordinates: aligned with the left edge of the calendar, just below it.
    menuButtonX = (int) calendar.x;
    menuButtonY = (int)(calendar.y + calendar.h + 10);
    menuButtonW = 100;
    menuButtonH = 40;
    
    // Set RESET button coordinates: 15 pixels to the right of the MENU button.
    resetButtonX = menuButtonX + menuButtonW + 15;
    resetButtonY = menuButtonY;
    resetButtonW = 100;
    resetButtonH = 40;
    
    calendar.visible = true;
  }
  
  void draw() {
    background(0);
    
    // Update simulation clock.
    timeSlider.update();
    float currentTime = timeSlider.value;
    String currentDate = calendar.getSelectedDate2();
    
    // Reload today's flights if the date has changed.
    if (!currentDate.equals(lastCheckedDate)) {
      todaysFlights.clear();
      spawnedFlights.clear();
      activePlanes.clear();
      for (Flight flight : flights) {
        if (flight.date.equals(currentDate)) {
          todaysFlights.add(flight);
        }
      }
      lastCheckedDate = currentDate;
    }
    
    // Remove airplanes that are no longer active.
    for (int i = activePlanes.size() - 1; i >= 0; i--) {
      Airplane a = activePlanes.get(i);
      if (currentTime < a.startMinute || currentTime > a.startMinute + a.duration || a.finished) {
        String id = a.originCode + "_" + a.destCode + "_" + int(a.startMinute);
        spawnedFlights.remove(id);
        activePlanes.remove(i);
      }
    }
    
    // Spawn airplanes for flights whose time range covers the current time.
    for (Flight flight : todaysFlights) {
      if (currentTime >= flight.minutes && currentTime <= flight.minutes + flight.duration) {
        String flightID = flight.origin + "_" + flight.destination + "_" + flight.minutes;
        if (!spawnedFlights.contains(flightID)) {
          Airport origin = airportMap.get(flight.origin);
          Airport dest = airportMap.get(flight.destination);
          if (origin != null && dest != null && !flight.cancelled) {
            Airplane airplane = new Airplane(
              origin, dest, sphereRadius, airplaneModel, (float) flight.minutes,
              airportLocations.get(flight.origin), airportLocations.get(flight.destination),
              flight.actualDeparture, flight.actualArrival,
              flight.airlineName, flight.airlineCode, flight.flightNumber,
              flight.duration, flight.origin, flight.destination, flight
            );
            activePlanes.add(airplane);
            spawnedFlights.add(flightID);
          }
        }
      }
    }
    
    // Draw stars.
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
    
    // Update Earth and draw globe.
    earth.update();
    pushMatrix();
      // Apply pan offset before centering.
      translate(panOffset.x, panOffset.y, 0);
      translate(width / 2, height / 2, 0);
      applyMatrix(earth.rotationMatrix);
      scale(earth.zoomFactor);
      earth.display();
      
      // Draw airplanes with depth test disabled for proper blending.
      hint(DISABLE_DEPTH_TEST);
      for (Airplane a : activePlanes) {
        if (activeFlightInfo != null &&
            a.flight.identifier.equals(activeFlightInfo.flight.identifier) &&
            a.flight.date.equals(activeFlightInfo.flight.date)) {
          a.selected = true;
        } else {
          a.selected = false;
        }
        a.update(currentTime);
        PVector transformedPos = new PVector();
        earth.rotationMatrix.mult(a.getPosition(), transformedPos);
        PVector norm = transformedPos.copy().normalize();
        if (norm.z > 0.5) {  
          a.display();
        }
      }
      // Draw the flight arc if an airplane is selected and its flight info is visible.
      if (activeFlightInfo != null && activeFlightInfo.visible) {
        activeFlightInfo.drawFlightArc(sphereRadius);
      }
      hint(ENABLE_DEPTH_TEST);
    popMatrix();
    
    // Draw additional UI elements if UI is not hidden.
    hint(DISABLE_DEPTH_TEST);
      // Draw the calendar without stroke.
      pushStyle();
        noStroke();
        calendar.display();
      popStyle();
      timeSlider.display();
      if (activeFlightInfo != null && activeFlightInfo.visible) {
        activeFlightInfo.display();
      }
      // Draw the MENU and RESET buttons.
      drawMenuButton();
      drawResetButton();
    hint(ENABLE_DEPTH_TEST);
  }
  
  // Draws the MENU button with hover effects.
  void drawMenuButton() {
    if (isOverMenuButton()) {
      stroke(color(255));
      strokeWeight(2);
    } else {
      stroke(color(135, 206, 235, 150));
      strokeWeight(2);
    }
    fill(color(50, 50, 50, 230));
    rect(menuButtonX, menuButtonY, menuButtonW, menuButtonH, 8);  
    fill(255);
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Menu", menuButtonX + menuButtonW / 2, menuButtonY + menuButtonH / 2);
  }
  
  // Draws the RESET button with hover effects.
  void drawResetButton() {
    if (isOverResetButton()) {
      stroke(color(255));
      strokeWeight(2);
    } else {
      stroke(color(135, 206, 235, 150));
      strokeWeight(2);
    }
    fill(color(50, 50, 50, 230));
    rect(resetButtonX, resetButtonY, resetButtonW, resetButtonH, 8);
    fill(255);
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Reset", resetButtonX + resetButtonW / 2, resetButtonY + resetButtonH / 2);
  }
  
  boolean isOverSliderButtons() {
    float bx = timeSlider.sliderButtons.buttonsX;
    float by = timeSlider.sliderButtons.playY;
    float bWidth = timeSlider.sliderButtons.buttonSize;
    float bHeight = (timeSlider.sliderButtons.backY + timeSlider.sliderButtons.buttonSize) - by;
    return (mouseX >= bx && mouseX <= bx + bWidth &&
            mouseY >= by && mouseY <= by + bHeight);
  }
  
  boolean isOverCalendar() {
    return (mouseX >= calendar.x && mouseX <= calendar.x + calendar.w &&
            mouseY >= calendar.y && mouseY <= calendar.y + calendar.h);
  }
  
  boolean isOverSliderTrack() {
    return (mouseX >= timeSlider.x && mouseX <= timeSlider.x + timeSlider.w &&
            mouseY >= timeSlider.y && mouseY <= timeSlider.y + timeSlider.h);
  }
  
  boolean isOverMenuButton() {
    return (mouseX >= menuButtonX && mouseX <= menuButtonX + menuButtonW &&
            mouseY >= menuButtonY && mouseY <= menuButtonY + menuButtonH);
  }
  
  boolean isOverResetButton() {
    return (mouseX >= resetButtonX && mouseX <= resetButtonX + resetButtonW &&
            mouseY >= resetButtonY && mouseY <= resetButtonY + resetButtonH);
  }
  
  void mousePressed() {
    if (mouseButton == RIGHT) {
      panStart = new PVector(mouseX, mouseY);
      return;
    }
    
    if (isOverCalendar()) {
      uiHeld = true;
      calendar.mousePressed();
      return;
    }
    
    if (isOverSliderButtons() || isOverSliderTrack()) {
      uiHeld = true;
      timeSlider.mousePressed();
      return;
    }
    
    timeSlider.mousePressed();
    
    // Check if the mouse click is on the MENU button.
    if (isOverMenuButton()) {
      screenManager.switchScreen(mainMenuScreen);
      return;
    }
    
    // Check if the mouse click is on the RESET button.
    if (isOverResetButton()) {
      // Reset functionality, as if the spacebar was pressed.
      earth.rotationMatrix = new PMatrix3D();
      earth.zoomFactor = 0.6;
      panOffset.set(0, 0);
      return;
    }
    
    if (activeFlightInfo != null && activeFlightInfo.closeButtonClicked(mouseX, mouseY)) {
      activeFlightInfo.visible = false;
      for (Airplane plane : activePlanes) {
        plane.selected = false;
      }
      activeFlightInfo = null;
      return;
    }
    
    if (activeFlightInfo != null && activeFlightInfo.moreInfoClicked(mouseX, mouseY)) {
      noTint();
      imageMode(CORNER);
      textAlign(LEFT);
      screenManager.switchScreen(new DirectoryFlightInfoScreen(activeFlightInfo.flight, this));
      return;
    }
    
    Airplane candidate = null;
    for (Airplane a : activePlanes) {
      PVector transformedPos = new PVector();
      earth.rotationMatrix.mult(a.getPosition(), transformedPos);
      PVector norm = transformedPos.copy().normalize();
      if (norm.z > 0.5 && a.isHovered()) {
        candidate = a;
        break;
      }
    }
    
    if (candidate != null) {
      planeClicked = true;
      for (Airplane plane : activePlanes) {
        plane.selected = false;
      }
      candidate.selected = true;
      activeFlightInfo = new ActiveFlightInfo(
        candidate.flight,
        candidate.start, candidate.end, 
        candidate.departureLocation, candidate.arrivalLocation,
        candidate.departureTime, candidate.arrivalTime,
        candidate.airlineName, candidate.airlineCode,
        candidate.flightNumber, candidate.departureDate
      );
      return;
    }
    
    if (calendar.mousePressed()) {
      uiHeld = true;
      return;
    }
    
    if (timeSlider.dragging || isOverSliderButtons() || isOverSliderTrack()) {
      uiHeld = true;
      return;
    }
    
    if (!uiHeld && !planeClicked) {
      earth.isDragging = true;
      earth.inertiaAngle = 0;
      cursor(MOVE);
      if (mouseButton == LEFT && !(keyPressed && keyCode == CONTROL)) {
        earth.lastArcball = getArcballVector(mouseX, mouseY);
      }
    }
  }
  
  void mouseDragged() {
    if (mouseButton == RIGHT) {
      if (panStart == null) panStart = new PVector(mouseX, mouseY);
      PVector delta = new PVector(mouseX - panStart.x, mouseY - panStart.y);
      panOffset.add(delta);
      panStart.set(mouseX, mouseY);
      return;
    }
    
    if (timeSlider.dragging || uiHeld) return;
    
    if (mouseButton == LEFT && !planeClicked) {
      if (mouseButton == LEFT && keyPressed && keyCode == CONTROL) {
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
    if (mouseButton == RIGHT) {
      panStart = null;
      return;
    }
    timeSlider.mouseReleased();
    earth.isDragging = false;
    uiHeld = false;
    planeClicked = false;
    cursor(ARROW);
  }
  
  void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    earth.zoomFactor -= e * 0.05;
    earth.zoomFactor = constrain(earth.zoomFactor, 0.1, 1.25);
  }
  
  void keyPressed() {
    if (key == ' ') {
      earth.rotationMatrix = new PMatrix3D();
      earth.zoomFactor = 0.6;
      panOffset.set(0, 0);
    }
  }
  
  String minutesToTimeString(int minutes) {
    int hh = minutes / 60;
    int mm = minutes % 60;
    return nf(hh, 2) + ":" + nf(mm, 2);
  }
}
