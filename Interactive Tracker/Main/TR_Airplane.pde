class Airplane {
  PVector start, end, currentPos;
  float sphereRadius, startMinute;
  int duration;
  boolean finished = false;
  boolean hovered = false;
  boolean selected = false;
  
  PImage model; 

  // Flight info fields
  String departureLocation, arrivalLocation;
  String departureTime, arrivalTime;
  String airlineName, airlineCode, flightNumber;
  String departureDate;
  String originCode, destCode;
  
  Airplane(
    Airport origin, Airport dest, float sphereRadius, PImage model, float startMinute,
    String depLoc, String arrLoc, String depTime, String arrTime,
    String airlineName, String airlineCode, String flightNumber,
    int duration, String originCode, String destCode
  ) {
    this.start = origin.getPosition();
    this.end = dest.getPosition();
    this.currentPos = start.copy();
    this.sphereRadius = sphereRadius;
    this.model = model;
    this.startMinute = startMinute;
    this.duration = duration;
    this.originCode = originCode;
    this.destCode = destCode;

    this.departureLocation = depLoc;
    this.arrivalLocation = arrLoc;
    this.departureTime = depTime;
    this.arrivalTime = arrTime;
    this.airlineName = airlineName;
    this.airlineCode = airlineCode;
    this.flightNumber = flightNumber;
  }

  void update(float currentMinute) {
    if (finished) return;

    float elapsed = currentMinute - startMinute;
    float t = constrain(elapsed / float(duration), 0, 1);
    if (t >= 1) {
      finished = true;
      return;
    }

    PVector startNorm = start.copy().normalize();
    PVector endNorm = end.copy().normalize();
    float dot = constrain(startNorm.dot(endNorm), -1, 1);
    float theta = acos(dot);
    float sinTheta = sin(theta);

    if (sinTheta < 0.001) {
      currentPos = start.copy();
    } else {
      PVector p1 = PVector.mult(startNorm, sin((1 - t) * theta));
      PVector p2 = PVector.mult(endNorm, sin(t * theta));
      currentPos = PVector.add(p1, p2).div(sinTheta).normalize().mult(sphereRadius);
    }

    float sx = screenX(currentPos.x, currentPos.y, currentPos.z);
    float sy = screenY(currentPos.x, currentPos.y, currentPos.z);
    hovered = dist(mouseX, mouseY, sx, sy) < 20;
  }
  
  void display() {
    if (finished) return;
    pushMatrix();
      translate(currentPos.x, currentPos.y, currentPos.z);
      // Orientation calculations:
      PVector travelDir = PVector.sub(end, start).normalize();
      PVector globeNormal = currentPos.copy().normalize();
      PVector right = globeNormal.cross(travelDir).normalize();
      PVector forward = right.cross(globeNormal).normalize();
      PMatrix3D m = new PMatrix3D(
        forward.x, globeNormal.x, right.x, 0,
        forward.y, globeNormal.y, right.y, 0,
        forward.z, globeNormal.z, right.z, 0,
        0,         0,              0,      1
      );
      applyMatrix(m);
      rotateX(HALF_PI);
      rotateZ(PI);
      
      // Instead of scaling the coordinate system, choose a scale factor and use it to resize the model image.
      float factor = selected ? 0.02 : 0.01;
      
      if (selected) {
        tint(255, 255, 0);
      } else {
        noTint();
      }
      
      imageMode(CENTER);
      // Draw the model at the scaled size, so its position remains unchanged.
      image(model, 0, 0, model.width * factor, model.height * factor);
    popMatrix();
  }
  
  void displayInfoBoxTopRight() {
    if (!selected) return;

    float boxW = 350;
    float boxH = 255;
    float x = width - boxW - 10;
    float y = 10;
    float closeSize = 20;
    float closeX = x + boxW - closeSize - 10;
    float closeY = y + boxH - closeSize - 10;

    String line1 = "From: " + departureLocation;
    String line2 = "To: " + arrivalLocation;
    String line3 = "Departure: " + departureTime;
    String line4 = "Arrival: " + arrivalTime;
    String line5 = "Airline: " + airlineName;
    String line6 = "Flight #: " + airlineCode + flightNumber;
    String line7 = "More Info...";

    pushStyle();
    noStroke();
    fill(50, 230);
    rect(x, y, boxW, boxH, 8);

    // Close button with hover effect
    boolean overClose = mouseX >= closeX && mouseX <= closeX + closeSize &&
                        mouseY >= closeY && mouseY <= closeY + closeSize;
    fill(overClose ? color(100, 150, 255) : color(100));
    rect(closeX, closeY, closeSize, closeSize, 4);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(14);
    text("X", closeX + closeSize / 2, closeY + closeSize / 2);

    // Info text
    fill(255);
    textAlign(LEFT, TOP);
    textSize(20);
    float textX = x + 20;
    float textY = y + 20;
    float lineSpacing = 32;

    text(line1, textX, textY + 0 * lineSpacing);
    text(line2, textX, textY + 1 * lineSpacing);
    text(line3, textX, textY + 2 * lineSpacing);
    text(line4, textX, textY + 3 * lineSpacing);
    text(line5, textX, textY + 4 * lineSpacing);
    text(line6, textX, textY + 5 * lineSpacing);

    // Hoverable "More Info"
    float infoY = textY + 6 * lineSpacing;
    float infoW = textWidth(line7);
    float infoH = lineSpacing;
    boolean overInfo = mouseX >= textX && mouseX <= textX + infoW &&
                       mouseY >= infoY && mouseY <= infoY + infoH;

    if (overInfo) {
      fill(100, 150, 255);
      stroke(255);
      strokeWeight(1.5);
    } else {
      fill(255);
      noStroke();
    }
    text(line7, textX, infoY);

    popStyle();
  }

  boolean closeButtonClicked(int mouseX, int mouseY) {
    float boxW = 350;
    float boxH = 255;
    float x = width - boxW - 10;
    float y = 10;
    float closeSize = 20;
    float closeX = x + boxW - closeSize - 10;
    float closeY = y + boxH - closeSize - 10;

    return mouseX >= closeX && mouseX <= closeX + closeSize &&
           mouseY >= closeY && mouseY <= closeY + closeSize;
  }

  boolean isHovered() {
    return hovered;
  }
  
  PVector getPosition() {
    return currentPos;
  }
}
