
class FlightInfo {
  String departureLocation, arrivalLocation, departureTime, arrivalTime, airline, flightNumber;
  
  FlightInfo(String depLoc, String arrLoc, String depTime, String arrTime, String airline, String flightNumber) {
    this.departureLocation = depLoc;
    this.arrivalLocation = arrLoc;
    this.departureTime = depTime;
    this.arrivalTime = arrTime;
    this.airline = airline;
    this.flightNumber = flightNumber;
  }
  
  void display() {
    pushStyle();
    rectMode(CORNER);
    stroke(0, 255, 0);
    strokeWeight(2);
    fill(255, 255, 0);
    rect(10, 10, 300, 150);
    
    textSize(16);
    textAlign(LEFT, TOP);
    fill(0);
    String line1 = "From: " + departureLocation;
    String line2 = "To: " + arrivalLocation;
    String line3 = "Departed: " + departureTime;
    String line4 = "Arrived: " + arrivalTime;
    String line5 = "Airline: " + airline;
    String line6 = "Flight #: " + flightNumber;
    String line7 = "More Info...";
    
    text(line1, 20, 20);
    text(line2, 20, 40);
    text(line3, 20, 60);
    text(line4, 20, 80);
    text(line5, 20, 100);
    text(line6, 20, 120);

    int boxX = 20;
    int boxY = 140;
    int boxW = 100;
    int boxH = 20;
    
    if (mouseX >= boxX && mouseX <= boxX + boxW &&
        mouseY >= boxY && mouseY <= boxY + boxH) {
      fill(255, 0, 0);
    } else {
      fill(0);
    }
    text(line7, 20, 140);
    popStyle();
  }
}
