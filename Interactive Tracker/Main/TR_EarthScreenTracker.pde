class EarthScreenTracker extends Screen {
  Earth earth;
  CalendarDisplay calendar;
  TimeSlider timeSlider;
  boolean uiHeld = false;
  // Flag to track if a plane was clicked so that earth dragging is disabled.
  boolean planeClicked = false;
  
  ActiveFlightInfo activeFlightInfo;
  
  // New variables for panning
  PVector panOffset;  // Overall pan offset.
  PVector panStart;   // Starting mouse position when panning.
  
  EarthScreenTracker(Earth earth) {
    this.earth = earth;
    calendar = new CalendarDisplay();
    timeSlider = new TimeSlider(width / 4, 60, width / 2, 30);
    // Initialize pan variables.
    panOffset = new PVector(0, 0);
    panStart = null;
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
              origin, dest, sphereRadius, airplaneModel, (float)flight.minutes,
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
    
    // Update and display stars.
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
      
      // Draw airplanes with depth test disabled for blending.
      hint(DISABLE_DEPTH_TEST);
      for (Airplane a : activePlanes) {
        // If this airplane's flight matches the persistent selected flight, mark it as selected.
        if (activeFlightInfo != null &&
            a.flight.identifier.equals(activeFlightInfo.flight.identifier) &&
            a.flight.date.equals(activeFlightInfo.flight.date)) {
          a.selected = true;
        } else {
          a.selected = false;
        }
        
        a.update(currentTime);
        // Transform airplane position to viewer space.
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
    timeSlider.display();
    calendar.display();
    if (activeFlightInfo != null && activeFlightInfo.visible) {
      activeFlightInfo.display();
    }
    hint(ENABLE_DEPTH_TEST);
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
  
  void mousePressed() {
    // Check for middle mouse button press for panning.
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
    
    // Look for a candidate plane that is hovered.
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
      // Prevent earth dragging when a plane is clicked.
      planeClicked = true;
      
      // Deselect all planes and select the candidate.
      for (Airplane plane : activePlanes) {
        plane.selected = false;
      }
      candidate.selected = true;
      
      // Create ActiveFlightInfo using the candidate's Flight object.
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
    
    // Only allow earth dragging if no plane was clicked.
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
    // If middle mouse button is held, pan the globe.
    if (mouseButton == RIGHT) {
      if (panStart == null) {
        panStart = new PVector(mouseX, mouseY);
      }
      PVector delta = new PVector(mouseX - panStart.x, mouseY - panStart.y);
      panOffset.add(delta);
      panStart.set(mouseX, mouseY);
      return;
    }
    
    // Prevent dragging if a plane was clicked or if slider UI is active.
    if (planeClicked || timeSlider.dragging || uiHeld) return;
    
    if (mouseButton == LEFT) {
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
    // If middle mouse was used, end panning.
    if (mouseButton == RIGHT) {
      panStart = null;
      return;
    }
    timeSlider.mouseReleased();
    earth.isDragging = false;
    uiHeld = false;
    // Reset the planeClicked flag when the mouse is released.
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
      earth.zoomFactor = 0.8;
    }
  }
  
  String minutesToTimeString(int minutes) {
    int hh = minutes / 60;
    int mm = minutes % 60;
    return nf(hh, 2) + ":" + nf(mm, 2);
  }
}
