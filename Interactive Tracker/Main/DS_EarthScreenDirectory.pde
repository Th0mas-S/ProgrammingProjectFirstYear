// A simplified earth screen for the flight directory.
// It shows only the single flight (directoryFlight) on the globe.
class EarthScreenDirectory extends Screen {
  Earth earth;
  Flight directoryFlight;
  AirplaneDirectory airplane;  // will hold the single flight's airplane
  TimeSlider timeSlider;
  boolean uiHeld = false;
  
  // Constructor: pass in the Earth object and the single flight to display.
  EarthScreenDirectory(Earth earth, Flight directoryFlight) {
    this.earth = earth;
    this.directoryFlight = directoryFlight;
    timeSlider = new TimeSlider(width / 4, 60, width / 2, 30);
  }
  
  void draw() {
    background(0);
    
    // Update the simulation clock.
    timeSlider.update();
    float currentTime = timeSlider.value;
    
    // Update Earth (rotation, zoom, etc.).
    earth.update();
    pushMatrix();
      translate(width/2, height/2, 0);
      applyMatrix(earth.rotationMatrix);
      scale(earth.zoomFactor);
      earth.display();
      
      // Check if the single flight is active in the current simulation time.
      if (currentTime >= directoryFlight.minutes && currentTime <= directoryFlight.minutes + directoryFlight.duration) {
        if (airplane == null) {
          // Debug: Check if airport locations are present.
          if (airportLocations.get(directoryFlight.origin) == null) {
            println("No airport location for: " + directoryFlight.origin);
          }
          if (airportLocations.get(directoryFlight.destination) == null) {
            println("No airport location for: " + directoryFlight.destination);
          }
          
          // Retrieve origin and destination airports from the airportMap.
          Airport origin = airportMap.get(directoryFlight.origin);
          Airport dest = airportMap.get(directoryFlight.destination);
          
          // Create the airplane only if both airports are valid.
          if (origin != null && dest != null && !directoryFlight.cancelled) {
            airplane = new AirplaneDirectory(
              origin, dest, sphereRadius, airplaneModel, (float)directoryFlight.minutes,
              airportLocations.get(directoryFlight.origin), airportLocations.get(directoryFlight.destination),
              directoryFlight.actualDeparture, directoryFlight.actualArrival,
              directoryFlight.airlineName, directoryFlight.airlineCode, directoryFlight.flightNumber,
              directoryFlight.duration, directoryFlight.origin, directoryFlight.destination,
              directoryFlight
            );
          }
        }
        if (airplane != null) {
          airplane.update(currentTime);
          // Transform and display the airplane as needed.
          PVector transformedPos = new PVector();
          earth.rotationMatrix.mult(airplane.getPosition(), transformedPos);
          PVector norm = transformedPos.copy().normalize();
          if (norm.z > 0.5) {  
            airplane.display();
          }
        }
      } else {
        // Flight not active; remove the airplane.
        airplane = null;
      }
      
      // (Optional) You could draw a flight arc here if needed.
      hint(ENABLE_DEPTH_TEST);
    popMatrix();
    
    // Draw UI elements (the time slider, etc.).
    hint(DISABLE_DEPTH_TEST);
    timeSlider.display();
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
  
  boolean isOverSliderTrack() {
    return (mouseX >= timeSlider.x && mouseX <= timeSlider.x + timeSlider.w &&
            mouseY >= timeSlider.y && mouseY <= timeSlider.y + timeSlider.h);
  }
  
  void mousePressed() {
  
    if (isOverSliderButtons() || isOverSliderTrack()) {
      uiHeld = true;
      timeSlider.mousePressed();
      return;
    }
    
    timeSlider.mousePressed();
    
    
    if (timeSlider.dragging || isOverSliderButtons() || isOverSliderTrack()) {
      uiHeld = true;
      return;
    }
    
    if (!uiHeld) {
      earth.isDragging = true;
      earth.inertiaAngle = 0;
      cursor(MOVE);
      if (mouseButton == LEFT && !(keyPressed && keyCode == CONTROL)) {
        earth.lastArcball = getArcballVector(mouseX, mouseY);
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
