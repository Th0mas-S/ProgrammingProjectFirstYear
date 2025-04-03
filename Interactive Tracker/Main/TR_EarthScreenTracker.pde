class EarthScreenTracker extends Screen {
  Earth earth;
  CalendarDisplay calendar;
  TimeSlider timeSlider;
  boolean uiHeld = false;
  
  ActiveFlightInfo activeFlightInfo;
  
  EarthScreenTracker(Earth earth) {
    this.earth = earth;
    calendar = new CalendarDisplay();
    timeSlider = new TimeSlider(width / 4, 60, width / 2, 30);
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
      // Replace FlightData with ActiveFlightInfo in your global lists.
      for (Flight flight : allFlights) {
        if (flight.date.equals(currentDate)) {
          todaysFlights.add(flight);
        }
      }
      lastCheckedDate = currentDate;
    }
    
    // Remove planes that are no longer active.
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
            
            println(flight.scheduledDeparture, flight.scheduledArrival);
            Airplane airplane = new Airplane(
              origin, dest, sphereRadius, airplaneModel, (float)flight.minutes,
              airportLocations.get(flight.origin), airportLocations.get(flight.destination),
              flight.actualDeparture, flight.actualArrival,
              flight.airlineName, flight.airlineCode, flight.flightNumber,
             flight.duration, flight.origin, flight.destination
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
      translate(width / 2, height / 2, 0);
      applyMatrix(earth.rotationMatrix);
      scale(earth.zoomFactor);
      earth.display();
      
      // Draw airplanes with depth test disabled for blending.
      hint(DISABLE_DEPTH_TEST);
      for (Airplane a : activePlanes) {
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
    // Check if the mouse is over any UI element.
    boolean uiHover = isOverSliderButtons() || isOverCalendar() || isOverSliderTrack();
    if (uiHover) {
      uiHeld = true;
      // Let the UI (time slider, calendar) handle the press.
      timeSlider.mousePressed();
      return;
    }
    
    // Otherwise, process UI mouse press first.
    timeSlider.mousePressed();
    
    // Check if the ActiveFlightInfo close button was clicked.
    if (activeFlightInfo != null && activeFlightInfo.closeButtonClicked(mouseX, mouseY)) {
      activeFlightInfo.visible = false;
      return;
    }
    
    // Select an airplane if hovered and visible.
    for (Airplane a : activePlanes) {
      PVector transformedPos = new PVector();
      earth.rotationMatrix.mult(a.getPosition(), transformedPos);
      PVector norm = transformedPos.copy().normalize();
      if (norm.z > 0.5 && a.isHovered()) {
        // Deselect all other planes.
        for (Airplane b : activePlanes) {
          b.selected = false;
        }
        // Mark this plane as selected.
        a.selected = true;
        
        activeFlightInfo = new ActiveFlightInfo(
          a.start, a.end, 
          a.departureLocation, a.arrivalLocation,
          a.departureTime, a.arrivalTime,
          a.airlineName, a.airlineCode,
          a.flightNumber, a.departureDate
        );
        break;
      }
    }
    
    // Also let the calendar process its own mouse press.
    if (calendar.mousePressed()) {
      uiHeld = true;
      return;
    }
    
    // Additional UI checks.
    if (timeSlider.dragging || isOverSliderButtons() || isOverSliderTrack()) {
      uiHeld = true;
      return;
    }
    
    // If no UI is held, allow globe interaction.
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
  
  String minutesToTimeString(int minutes) {
    int hh = minutes / 60;
    int mm = minutes % 60;
    return nf(hh, 2) + ":" + nf(mm, 2);
  }
}
