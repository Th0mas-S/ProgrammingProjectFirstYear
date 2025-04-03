class ActiveFlightInfo {
  // Flight info fields
  String departureLocation, arrivalLocation;
  String departureTime, arrivalTime;
  String airlineName, airlineCode, flightNumber;
  String departureDate;
  
  // For drawing the flight arc:
  PVector origin, destination;
  
  // Visibility flag for the info box.
  boolean visible = true;  
  
  // Standard constructor (without arc data)
  ActiveFlightInfo(String depLoc, String arrLoc, String depTime, String arrTime,
                   String airlineName, String airlineCode, String flightNumber,
                   String departureDate) {
    this.departureLocation = depLoc;
    this.arrivalLocation = arrLoc;
    this.departureTime = depTime;
    this.arrivalTime = arrTime;
    this.airlineName = airlineName;
    this.airlineCode = airlineCode;
    this.flightNumber = flightNumber;
    this.departureDate = departureDate;
  }
  
  // Overloaded constructor that also takes origin and destination for the arc.
  ActiveFlightInfo(PVector origin, PVector destination, 
                   String depLoc, String arrLoc, String depTime, String arrTime,
                   String airlineName, String airlineCode, String flightNumber,
                   String departureDate) {
    this(depLoc, arrLoc, depTime, arrTime, airlineName, airlineCode, flightNumber, departureDate);
    this.origin = origin;
    this.destination = destination;
  }
  
  // Draw the flight info box.
  void display() {
    if (!visible) return;
    
    float boxW = 350;
    float boxH = 255;
    float x = width - boxW - 10;
    float y = 10;
    float closeSize = 20;
    float closeX = x + boxW - closeSize - 10;
    float closeY = y + boxH - closeSize - 10;

    String line1 = "From: " + departureLocation;
    String line2 = "To: " + arrivalLocation;
    String line3 = "Departure: " + departureDate + " " + departureTime;
    String line4 = "Arrival: " + arrivalTime;
    String line5 = "Airline: " + airlineName;
    String line6 = "Flight #: " + airlineCode + flightNumber;
    String line7 = "More Info...";

    pushStyle();
    noStroke();
    fill(50, 230);
    rect(x, y, boxW, boxH, 8);

    // Draw close button with hover effect.
    boolean overClose = mouseX >= closeX && mouseX <= closeX + closeSize &&
                        mouseY >= closeY && mouseY <= closeY + closeSize;
    fill(overClose ? color(100, 150, 255) : color(100));
    rect(closeX, closeY, closeSize, closeSize, 4);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(14);
    text("X", closeX + closeSize / 2, closeY + closeSize / 2);

    // Draw flight info text.
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
    float boxW = 350;
    float boxH = 255;
    float x = width - boxW - 10;
    float y = 10;
    float closeSize = 20;
    float closeX = x + boxW - closeSize - 10;
    float closeY = y + boxH - closeSize - 10;
    
    return mx >= closeX && mx <= closeX + closeSize &&
           my >= closeY && my <= closeY + closeSize;
  }
  
  void drawFlightArc(float sphereRadius) {
    // Only draw if both origin and destination are defined.
    if (origin == null || destination == null) return;
    
    // Draw the red arc between origin and destination.
    pushStyle();
      hint(ENABLE_DEPTH_TEST);
      stroke(255, 0, 0); // red
      strokeWeight(2);
      noFill();
      beginShape();
      int segments = 50;
      
      // Normalize the origin and destination vectors.
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
      // Calculate destination position on the sphere.
      PVector destPos = destination.copy().normalize().mult(sphereRadius);
      translate(destPos.x, destPos.y, destPos.z);
      
      noStroke();
      fill(0, 255, 0);
      sphereDetail(10);
      sphere(5);
    popMatrix();
  }

}
