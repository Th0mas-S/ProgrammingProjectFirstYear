class EarthScreenDirectory extends Screen {
  Earth earth;
  Flight directoryFlight;
  AirplaneDirectory airplane;
  SliderDirectory sliderDirectory;
  boolean uiHeld = false;

  PVector panOffset;
  PVector panStart;
  
  Screen previousScreen;

  // Constants for the info screen and buttons
  final int infoX = 10;
  final int infoY = 10;
  final int infoW = 350;
  final int infoH = 165;
  
  // Back Button Constants
  final int backButtonX = infoX; 
  final int backButtonY = infoY + infoH + 10;  // 10 pixels below the info screen
  final int backButtonW = 100;
  final int backButtonH = 40;
  
  // Menu Button Constants (positioned to the right of the back button)
  final int menuButtonX = backButtonX + backButtonW + 10;
  final int menuButtonY = backButtonY;
  final int menuButtonW = 100;
  final int menuButtonH = 40;
  
  // Reset Button Constants (positioned to the right of the menu button)
  final int resetButtonX = menuButtonX + menuButtonW + 10;
  final int resetButtonY = menuButtonY;
  final int resetButtonW = 100;
  final int resetButtonH = 40;

  EarthScreenDirectory(Earth earth, Flight directoryFlight, Screen previousScreen) {
    this.earth = earth;
    this.directoryFlight = directoryFlight;

    int departureMinutes = timeStringToMinutes(directoryFlight.actualDeparture);
    int arrivalMinutes = timeStringToMinutes(directoryFlight.actualArrival);

    if (arrivalMinutes < departureMinutes) {
      println("🌙 Arrival crosses midnight. Adjusting arrivalMinutes...");
      arrivalMinutes += 1440;
    }

    int flightDuration = arrivalMinutes - departureMinutes;

    println("✅ Departure: " + departureMinutes + "min");
    println("✅ Arrival: " + arrivalMinutes + "min");
    println("⏳ Duration: " + flightDuration + "min");

    if (flightDuration <= 0) {
      println("❌ Invalid duration. Forcing fallback duration of 60 mins.");
      arrivalMinutes = departureMinutes + 60;
      flightDuration = 60;
    }

    sliderDirectory = new SliderDirectory(width / 4, 60, width / 2, 30, departureMinutes, arrivalMinutes);

    panOffset = new PVector(0, 0);
    panStart = null;
    this.previousScreen = previousScreen;
  }
  
  // Helper function: returns a fitted text size so that the text fits within maxWidth.
  float getFittedTextSize(String s, float baseSize, float maxWidth) {
    textSize(baseSize);
    float measuredWidth = textWidth(s);
    if (measuredWidth > maxWidth) {
      return baseSize * maxWidth / measuredWidth;
    } else {
      return baseSize;
    }
  }
  
  int timeStringToMinutes(String timeStr) {
    String trimmed = trim(timeStr);
    String[] dateTimeParts = split(trimmed, " ");
    if (dateTimeParts.length < 2) {
      println("⚠️ Could not extract time from: [" + trimmed + "]");
      return 0;
    }
    String timePart = dateTimeParts[1];
    String[] parts = split(timePart, ":");
    if (parts.length != 2) {
      println("⚠️ Invalid time format in: " + timePart);
      return 0;
    }
    int hours = int(parts[0]);
    int minutes = int(parts[1]);
    return (hours * 60 + minutes); // Allow values > 1440 for the next day
  }
  
  void draw() {
    background(0);
    sliderDirectory.update();
    float currentTime = sliderDirectory.value;

    // --- Draw star field (as in the tracker screen) ---
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
    
    pushMatrix();
      translate(panOffset.x, panOffset.y, 0);
      translate(width / 2, height / 2, 0);
      applyMatrix(earth.rotationMatrix);
      scale(earth.zoomFactor);
      earth.display();

      if (airplane == null) {
        println("Attempting to load airplane for flight: " + directoryFlight.flightNumber);
        Airport origin = airportMap.get(directoryFlight.origin);
        Airport dest = airportMap.get(directoryFlight.destination);

        if (origin != null && dest != null && !directoryFlight.cancelled) {
          PShape airplaneModel = loadShape("Airplane.obj");
          if (airplaneModel != null) {
            PImage airplaneTexture = loadImage("AirplaneTexture.png");
            if (airplaneTexture != null) airplaneModel.setTexture(airplaneTexture);
          }

          int departureMinutes = timeStringToMinutes(directoryFlight.actualDeparture);
          int arrivalMinutes = timeStringToMinutes(directoryFlight.actualArrival);
          if (arrivalMinutes < departureMinutes) arrivalMinutes += 1440;
          int duration = arrivalMinutes - departureMinutes;

          if (duration > 0) {
            airplane = new AirplaneDirectory(
              origin, dest, sphereRadius, airplaneModel, departureMinutes,
              airportLocations.get(directoryFlight.origin), airportLocations.get(directoryFlight.destination),
              directoryFlight.actualDeparture, directoryFlight.actualArrival,
              directoryFlight.airlineName, directoryFlight.airlineCode, directoryFlight.flightNumber,
              duration, directoryFlight.origin, directoryFlight.destination, directoryFlight
            );
          } else {
            println("❌ Invalid duration: " + duration);
          }
        } else {
          println("❌ Could not load airplane (missing airport or cancelled flight)");
        }
      }

      if (airplane != null) {
        PVector P0 = airplane.start.copy();
        PVector P2 = airplane.end.copy();
        int segments = 100;
        float alt = 15;
        noFill();
        stroke(255, 0, 0);
        strokeWeight(2);
        beginShape();
        for (int i = 0; i <= segments; i++) {
          float t = i / (float) segments;
          PVector startNorm = P0.copy().normalize();
          PVector endNorm = P2.copy().normalize();
          float dotVal = constrain(startNorm.dot(endNorm), -1, 1);
          float theta = acos(dotVal);
          float sinTheta = sin(theta);
          PVector slerpPoint = (sinTheta < 0.001) ? P0.copy() :
            PVector.add(PVector.mult(P0, sin((1 - t) * theta)), PVector.mult(P2, sin(t * theta))).div(sinTheta);
          slerpPoint.normalize();
          float currentRadius = airplane.sphereRadius + alt * sin(PI * t);
          slerpPoint.mult(currentRadius);
          vertex(slerpPoint.x, slerpPoint.y, slerpPoint.z);
        }
        endShape();

        float elapsed = (currentTime - airplane.startMinute) % airplane.duration;
        if (elapsed < 0) elapsed += airplane.duration;
        float t = elapsed / airplane.duration;
        PVector startNorm = P0.copy().normalize();
        PVector endNorm = P2.copy().normalize();
        float dotVal = constrain(startNorm.dot(endNorm), -1, 1);
        float theta = acos(dotVal);
        float sinTheta = sin(theta);
        PVector pos = (sinTheta < 0.001) ? P0.copy() :
          PVector.add(PVector.mult(P0, sin((1 - t) * theta)), PVector.mult(P2, sin(t * theta))).div(sinTheta);
        pos.normalize();
        float currentRadius = airplane.sphereRadius + alt * sin(PI * t);
        pos.mult(currentRadius);
        airplane.currentPos = pos;

        pushMatrix();
          fill(255, 255, 0);
          noStroke();
          PVector originPos = P0.copy().normalize().mult(airplane.sphereRadius);
          translate(originPos.x, originPos.y, originPos.z);
          sphere(5);
        popMatrix();

        pushMatrix();
          fill(0, 255, 0);
          noStroke();
          PVector destPos = P2.copy().normalize().mult(airplane.sphereRadius);
          translate(destPos.x, destPos.y, destPos.z);
          sphere(3);
        popMatrix();

        airplane.display();
      }

    hint(ENABLE_DEPTH_TEST);
    popMatrix();

    // Slider display
    hint(DISABLE_DEPTH_TEST);
    sliderDirectory.display();
    hint(ENABLE_DEPTH_TEST);

    // Draw the info screen in the top left.
    pushStyle();
      hint(DISABLE_DEPTH_TEST);
      rectMode(CORNER);
      fill(50, 50, 50, 230);
      stroke(135, 206, 235, 150);
      strokeWeight(2);
      rect(infoX, infoY, infoW, infoH, 10);

      // Prepare the text to display.
      String fromText, toText, departedText, arrivedText, flightNumberText;
      if (airplane != null) {
        fromText = "From: " + airplane.departureLocation;
        toText = "To: " + airplane.arrivalLocation;
        departedText = "Departed: " + airplane.departureTime;
        arrivedText = "Arrived: " + airplane.arrivalTime;
        flightNumberText = "Flight Number: " + airplane.airlineCode + airplane.flightNumber;
      } else {
        fromText = "From: " + airportLocations.get(directoryFlight.origin);
        toText = "To: " + airportLocations.get(directoryFlight.destination);
        departedText = "Departed: " + directoryFlight.actualDeparture;
        arrivedText = "Arrived: " + directoryFlight.actualArrival;
        flightNumberText = "Flight Number: " + directoryFlight.airlineCode + directoryFlight.flightNumber;
      }
      
      float baseTextSize = 24;
      float maxTextWidth = infoW - 20;
      float textX = infoX + 10;
      float textY = infoY + 10;
      float lineSpacing = 30;
      
      fill(255);
      textAlign(LEFT, TOP);
      
      float fittedSize = getFittedTextSize(fromText, baseTextSize, maxTextWidth);
      textSize(fittedSize);
      text(fromText, textX, textY);
      
      fittedSize = getFittedTextSize(toText, baseTextSize, maxTextWidth);
      textSize(fittedSize);
      text(toText, textX, textY + lineSpacing);
      
      fittedSize = getFittedTextSize(departedText, baseTextSize, maxTextWidth);
      textSize(fittedSize);
      text(departedText, textX, textY + 2 * lineSpacing);
      
      fittedSize = getFittedTextSize(arrivedText, baseTextSize, maxTextWidth);
      textSize(fittedSize);
      text(arrivedText, textX, textY + 3 * lineSpacing);
      
      fittedSize = getFittedTextSize(flightNumberText, baseTextSize, maxTextWidth);
      textSize(fittedSize);
      text(flightNumberText, textX, textY + 4 * lineSpacing);
      
      // Draw the Back, Menu, and Reset buttons.
      drawBackButton();
      drawMenuButton();
      drawResetButton();
      
    hint(ENABLE_DEPTH_TEST);
    popStyle();
  }

  // Draws the Back button with hover effects.
  void drawBackButton() {
    if (mouseX >= backButtonX && mouseX <= backButtonX + backButtonW &&
        mouseY >= backButtonY && mouseY <= backButtonY + backButtonH) {
      stroke(color(255));
      strokeWeight(2);
    } else {
      stroke(color(135, 206, 235, 150));
      strokeWeight(2);
    }
    fill(color(50, 50, 50, 230));
    rect(backButtonX, backButtonY, backButtonW, backButtonH, 8);
    fill(255);
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Back", backButtonX + backButtonW / 2, backButtonY + backButtonH / 2);
  }
  
  // Draws the Menu button with the same hover effects.
  void drawMenuButton() {
    if (mouseX >= menuButtonX && mouseX <= menuButtonX + menuButtonW &&
        mouseY >= menuButtonY && mouseY <= menuButtonY + menuButtonH) {
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
  
  // Draws the Reset button with hover effects.
  void drawResetButton() {
    if (mouseX >= resetButtonX && mouseX <= resetButtonX + resetButtonW &&
        mouseY >= resetButtonY && mouseY <= resetButtonY + resetButtonH) {
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

  boolean isOverSliderArea() {
    return (mouseX >= sliderDirectory.x && mouseX <= sliderDirectory.x + sliderDirectory.w &&
            mouseY >= sliderDirectory.y && mouseY <= sliderDirectory.y + sliderDirectory.h);
  }

  void mousePressed() {
    if (mouseButton == RIGHT) {
      panStart = new PVector(mouseX, mouseY);
      return;
    }
    
    // Check if the click is within the Menu button area.
    if (mouseX >= menuButtonX && mouseX <= menuButtonX + menuButtonW &&
        mouseY >= menuButtonY && mouseY <= menuButtonY + menuButtonH) {
      screenManager.switchScreen(mainMenuScreen);
      return;
    }
    
    // Check if the click is within the Reset button area.
    if (mouseX >= resetButtonX && mouseX <= resetButtonX + resetButtonW &&
        mouseY >= resetButtonY && mouseY <= resetButtonY + resetButtonH) {
      // Reset the earth's rotation, zoom and pan (same as pressing the spacebar).
      earth.rotationMatrix = new PMatrix3D();
      earth.zoomFactor = 0.6;
      panOffset.set(0, 0);
      return;
    }
    
    // Check if the click is within the Back button area.
    if (mouseX >= backButtonX && mouseX <= backButtonX + backButtonW &&
        mouseY >= backButtonY && mouseY <= backButtonY + backButtonH) {
      EarthScreenDirectory screen = (EarthScreenDirectory) screenManager.currentScreen;
      screenManager.switchScreen(screen.previousScreen);
      return;
    }

    if (isOverSliderArea() ||
        (mouseX >= sliderDirectory.sliderButtons.buttonsX &&
         mouseX <= sliderDirectory.sliderButtons.buttonsX + sliderDirectory.sliderButtons.buttonSize)) {
      uiHeld = true;
      sliderDirectory.mousePressed();
      return;
    }

    sliderDirectory.mousePressed();
    if (sliderDirectory.dragging ||
        (mouseX >= sliderDirectory.sliderButtons.buttonsX &&
         mouseX <= sliderDirectory.sliderButtons.buttonsX + sliderDirectory.sliderButtons.buttonSize)) {
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
    if (mouseButton == RIGHT) {
      if (panStart == null) panStart = new PVector(mouseX, mouseY);
      PVector delta = new PVector(mouseX - panStart.x, mouseY - panStart.y);
      panOffset.add(delta);
      panStart.set(mouseX, mouseY);
      return;
    }

    if (sliderDirectory.dragging || uiHeld) return;

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
    if (mouseButton == RIGHT) {
      panStart = null;
      return;
    }
    sliderDirectory.mouseReleased();
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
      earth.zoomFactor = 0.6;
      panOffset.set(0, 0);
    }
  }

  String minutesToTimeString(int minutes) {
    int dayOffset = minutes / 1440;
    int wrappedMinutes = minutes % 1440;
    int hh = wrappedMinutes / 60;
    int mm = wrappedMinutes % 60;
    return nf(hh, 2) + ":" + nf(mm, 2);
  }
}
