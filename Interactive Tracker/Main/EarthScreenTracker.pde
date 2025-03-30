class EarthScreenTracker extends Screen {
  Earth earth;
  CalendarDisplay calendar;
  TimeSlider timeSlider;
  boolean uiHeld = false;

  EarthScreenTracker(Earth earth) {
    this.earth = earth;
    calendar = new CalendarDisplay();
    timeSlider = new TimeSlider(width / 4, 60, width / 2, 30);
  }

void draw() {
  background(0);

  String currentDate = calendar.getSelectedDate();
  float currentTime = timeSlider.value;

  // ✅ Date has changed → reload today's flights
  if (!currentDate.equals(lastCheckedDate)) {
    todaysFlights.clear();
    spawnedFlights.clear();
    activePlanes.clear();

    for (FlightData flight : allFlights) {
      if (flight.dateStr.equals(currentDate)) {
        todaysFlights.add(flight);
      }
    }
    lastCheckedDate = currentDate;
  }

  // ✅ Remove planes no longer valid (rewound or finished), and untrack them
  for (int i = activePlanes.size() - 1; i >= 0; i--) {
    Airplane a = activePlanes.get(i);
    if (currentTime < a.startMinute || currentTime > a.startMinute + a.duration || a.finished) {
      String id = a.originCode + "_" + a.destCode + "_" + int(a.startMinute);
      spawnedFlights.remove(id); // ✅ Allow re-spawning later
      activePlanes.remove(i);
    }
  }

  // ✅ Spawn planes that should now be active
  for (FlightData flight : todaysFlights) {
    if (currentTime >= flight.minutes && currentTime <= flight.minutes + flight.duration) {
      String flightID = flight.originCode + "_" + flight.destCode + "_" + flight.minutes;
      if (!spawnedFlights.contains(flightID)) {
        Airport origin = airportMap.get(flight.originCode);
        Airport dest = airportMap.get(flight.destCode);
        if (origin != null && dest != null) {
          Airplane airplane = new Airplane(
            origin, dest, sphereRadius, airplaneModel, (float)flight.minutes,
            flight.originCityCountry, flight.destCityCountry,
            flight.departureTimeStr, flight.arrivalTimeStr,
            flight.airlineName, flight.airlineCode, flight.flightNumber,
            flight.dateStr, flight.duration, flight.originCode, flight.destCode
          );
          activePlanes.add(airplane);
          spawnedFlights.add(flightID);
        }
      }
    }
  }

  // 🌌 Stars
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

  // 🌍 Earth + Planes
  pushMatrix();
    translate(width / 2, height / 2, 0);
    applyMatrix(earth.rotationMatrix);
    scale(earth.zoomFactor);
    earth.display();

    for (Airplane a : activePlanes) {
      a.update(currentTime);
      a.display();
    }
  popMatrix();

  // 🧭 UI
  hint(DISABLE_DEPTH_TEST);
  timeSlider.update();
  timeSlider.display();
  calendar.display();
  if (selectedPlane != null) {
    selectedPlane.displayInfoBoxTopRight();
  }
  hint(ENABLE_DEPTH_TEST);
}


void mousePressed() {
  timeSlider.mousePressed();
  
  if (selectedPlane != null && selectedPlane.closeButtonClicked(mouseX, mouseY)) {
  selectedPlane.selected = false;
  selectedPlane = null;
  return;
  }

  // Select one airplane if hovered
  for (Airplane a : activePlanes) {
    if (a.isHovered()) {
      if (selectedPlane != null) selectedPlane.selected = false;
      a.selected = true;
      selectedPlane = a;
      break; // only allow one selected
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
    float bHeight = (timeSlider.sliderButtons.ffY + timeSlider.sliderButtons.buttonSize) - by;
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
}
