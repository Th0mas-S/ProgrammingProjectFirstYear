class ActiveFlightInfo {
  // Flight info fields (for display)
  String departureLocation, arrivalLocation;
  String departureTime, arrivalTime;
  String airlineName, airlineCode, flightNumber;
  String departureDate;
  
  // For drawing the flight arc:
  PVector origin, destination;
  
  // The associated Flight object
  Flight flight;
  
  // Visibility flag for the info box.
  boolean visible = true;  
  
  // Layout parameters for the info box.
  float boxW = 350;
  float boxH = 255;
  float textX, textY, lineSpacing;
  
  // Constructor that takes the Flight object along with other parameters.
  ActiveFlightInfo(Flight flight, PVector origin, PVector destination, 
                   String depLoc, String arrLoc, String depTime, String arrTime,
                   String airlineName, String airlineCode, String flightNumber,
                   String departureDate) {
    this.flight = flight;
    this.departureLocation = depLoc;
    this.arrivalLocation = arrLoc;
    this.departureTime = depTime;
    this.arrivalTime = arrTime;
    this.airlineName = airlineName;
    this.airlineCode = airlineCode;
    this.flightNumber = flightNumber;
    this.departureDate = departureDate;
    this.origin = origin;
    this.destination = destination;
    
    // Set up layout parameters (ensure these match your display layout)
    textX = width - boxW - 10 + 20;
    textY = 10 + 20;
    lineSpacing = 32;
  }
  
  // Draw the flight info box.
  void display() {
    if (!visible) return;
    
    float closeSize = 20;
    float x = width - boxW - 10;
    float y = 10;
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
    stroke(135, 206, 235, 150);
    strokeWeight(2);
    fill(50, 230);
    rect(x, y, boxW, boxH, 8);

    // Draw close button with hover effect.
    boolean overClose = mouseX >= closeX && mouseX <= closeX + closeSize &&
                          mouseY >= closeY && mouseY <= closeY + closeSize;
    fill(overClose ? color(100, 150, 255) : color(100));
    noStroke();
    rect(closeX, closeY, closeSize, closeSize, 4);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(14);
    text("X", closeX + closeSize / 2, closeY + closeSize / 2);

    // Draw flight info text.
    fill(255);
    textAlign(LEFT, TOP);
    textSize(20);
    text(line1, textX, textY + 0 * lineSpacing);
    text(line2, textX, textY + 1 * lineSpacing);
    text(line3, textX, textY + 2 * lineSpacing);
    text(line4, textX, textY + 3 * lineSpacing);
    text(line5, textX, textY + 4 * lineSpacing);
    text(line6, textX, textY + 5 * lineSpacing);

    // Draw "More Info" text with hover effect.
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
  
  // Returns true if the close button is clicked.
  boolean closeButtonClicked(int mx, int my) {
    float x = width - boxW - 10;
    float y = 10;
    float closeSize = 20;
    float closeX = x + boxW - closeSize - 10;
    float closeY = y + boxH - closeSize - 10;
    return mx >= closeX && mx <= closeX + closeSize &&
           my >= closeY && my <= closeY + closeSize;
  }
  
  // Returns true if the "More Info" text is clicked.
  boolean moreInfoClicked(int mx, int my) {
    String line7 = "More Info...";
    float infoY = textY + 6 * lineSpacing;
    float infoW = textWidth(line7);
    float infoH = lineSpacing;
    return (mx >= textX && mx <= textX + infoW &&
            my >= infoY && my <= infoY + infoH);
  }
  
  // Draw the flight arc (unchanged from before)
  void drawFlightArc(float sphereRadius) {
    if (origin == null || destination == null) return;
    pushStyle();
      hint(ENABLE_DEPTH_TEST);
      stroke(255, 0, 0);
      strokeWeight(2);
      noFill();
      beginShape();
      int segments = 50;
      PVector o = origin.copy().normalize();
      PVector d = destination.copy().normalize();
      float dot = constrain(o.dot(d), -1, 1);
      float theta = acos(dot);
      float sinTheta = sin(theta);
      
      for (int i = 0; i <= segments; i++) {
        float t = i / (float) segments;
        PVector point;
        if (sinTheta < 0.001) {
          point = o.copy();
        } else {
          PVector p1 = PVector.mult(o, sin((1 - t) * theta));
          PVector p2 = PVector.mult(d, sin(t * theta));
          point = PVector.add(p1, p2).div(sinTheta);
        }
        point.mult(sphereRadius);
        vertex(point.x, point.y, point.z);
      }
      endShape();
    popStyle();
    
    pushMatrix();
      PVector destPos = destination.copy().normalize().mult(sphereRadius);
      translate(destPos.x, destPos.y, destPos.z);
      noStroke();
      fill(0, 255, 0);
      sphereDetail(10);
      sphere(5);
    popMatrix();
  }
}
