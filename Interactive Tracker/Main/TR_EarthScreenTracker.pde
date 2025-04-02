class EarthScreenTracker extends Screen {
  Earth earth;
  CalendarDisplay calendar;
  TimeSlider timeSlider;
  boolean uiHeld = false;
  boolean uiHidden = false;  // Toggle for UI visibility

  EarthScreenTracker(Earth earth) {
    this.earth = earth;
    calendar = new CalendarDisplay();
    timeSlider = new TimeSlider(width / 4, 60, width / 2, 30);
  }
  
  void draw() {
    background(0);
    
    // Always update the simulation clock regardless of UI visibility.
    timeSlider.update();
    float currentTime = timeSlider.value;
    String currentDate = calendar.getSelectedDate2();
    
    // ✅ Date change: reload today's flights if needed.
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
    
    // ✅ Remove planes that are no longer active.
    for (int i = activePlanes.size() - 1; i >= 0; i--) {
      Airplane a = activePlanes.get(i);
      if (currentTime < a.startMinute || currentTime > a.startMinute + a.duration || a.finished) {
        String id = a.originCode + "_" + a.destCode + "_" + int(a.startMinute);
        spawnedFlights.remove(id);
        activePlanes.remove(i);
      }
    }
    
    // ✅ Spawn planes that should now be active.
    for (Flight flight : todaysFlights) {
      if (currentTime >= flight.minutes && currentTime <= flight.minutes + flight.duration) {
        String flightID = flight.origin + "_" + flight.destination + "_" + flight.minutes;
        if (!spawnedFlights.contains(flightID)) {
          Airport origin = airportMap.get(flight.origin);
          Airport dest = airportMap.get(flight.destination);
          if (origin != null && dest != null) {
            Airplane airplane = new Airplane(
              origin, dest, sphereRadius, airplaneModel, (float)flight.minutes,
              airportLocations.get(flight.origin), airportLocations.get(flight.destination),
              flight.scheduledDeparture, flight.scheduledArrival,
              flight.airlineName, flight.airlineCode, flight.flightNumber,
              flight.date, flight.duration, flight.origin, flight.destination
            );
            activePlanes.add(airplane);
            spawnedFlights.add(flightID);
          }
        }
      }
    }
    
    // 🌌 Stars (always update and display)
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
    
    // 🌍 Update Earth and draw globe.
    earth.update();
    pushMatrix();
      translate(width / 2, height / 2, 0);
      applyMatrix(earth.rotationMatrix);
      scale(earth.zoomFactor);
      earth.display();
      // Airplane drawing code commented out:
      
      for (Airplane a : activePlanes) {
        a.update(currentTime);
        a.display();
      }
      
    popMatrix();
    
    // Only draw additional UI elements if UI is not hidden.
    if (!uiHidden) {
      hint(DISABLE_DEPTH_TEST);
      timeSlider.display();
      calendar.display();
      if (selectedPlane != null) {
        selectedPlane.displayInfoBoxTopRight();
      }
      hint(ENABLE_DEPTH_TEST);
    }
    
    // Always draw the Hide UI button in the bottom right.
    drawHideUIButton();
  }
  
  // Draws the hide/show UI button in the bottom right corner.
  void drawHideUIButton() {
    int buttonWidth = 120;
    int buttonHeight = 40;
    int margin = 20;
    int x = width - buttonWidth - margin;
    int y = height - buttonHeight - margin;
    
    boolean over = (mouseX >= x && mouseX <= x + buttonWidth && mouseY >= y && mouseY <= y + buttonHeight);
    if (over) {
      fill(100, 150, 255);
      stroke(255);
      strokeWeight(2);
    } else {
      fill(150);
      noStroke();
    }
    rect(x, y, buttonWidth, buttonHeight, 5);
    
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(uiHidden ? "Show UI" : "Hide UI", x + buttonWidth/2, y + buttonHeight/2);
  }
  
  // Checks if the mouse is over the hide UI button.
  boolean isOverHideUIButton() {
    int buttonWidth = 120;
    int buttonHeight = 40;
    int margin = 20;
    int x = width - buttonWidth - margin;
    int y = height - buttonHeight - margin;
    return (mouseX >= x && mouseX <= x + buttonWidth && mouseY >= y && mouseY <= y + buttonHeight);
  }
  
  void mousePressed() {
    // Check if the Hide UI button is clicked.
    if (isOverHideUIButton()) {
      uiHidden = !uiHidden;
      return;
    }
    
    // Even if UI is hidden, allow globe interaction; otherwise, process UI events.
    if (uiHidden) {
      return;
    }
    
    timeSlider.mousePressed();
    
    if (selectedPlane != null && selectedPlane.closeButtonClicked(mouseX, mouseY)) {
      selectedPlane.selected = false;
      selectedPlane = null;
      return;
    }
    
    // Select one airplane if hovered.
    for (Airplane a : activePlanes) {
      if (a.isHovered()) {
        if (selectedPlane != null) selectedPlane.selected = false;
        a.selected = true;
        selectedPlane = a;
        break;
      }
    }
    
    if (calendar.mousePressed()) {
      uiHeld = true;
      return;
    }
    
    if (isOverCalendar()) {
      uiHeld = true;
      return;
    }
    
    if (timeSlider.dragging || isOverSliderButtons() || isOverSliderTrack()) {
      uiHeld = true;
      return;
    }
    
    if (mouseButton == LEFT || mouseButton == RIGHT) {
      if (!uiHeld) {
        earth.isDragging = true;
        earth.inertiaAngle = 0;
        cursor(MOVE);
        if (mouseButton == LEFT && !(keyPressed && keyCode == CONTROL)) {
          earth.lastArcball = getArcballVector(mouseX, mouseY);
        }
      }
    }
  }
  
  void mouseDragged() {
    if (timeSlider.dragging || uiHeld) return;
    
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
    timeSlider.mouseReleased();
    earth.isDragging = false;
    uiHeld = false;
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
  
  String minutesToTimeString(int minutes) {
    int hh = minutes / 60;
    int mm = minutes % 60;
    return nf(hh, 2) + ":" + nf(mm, 2);
  }
}
