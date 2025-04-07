class DirectoryFlightInfoScreen extends Screen {
  
  PImage logo, airlineLogo;
  Flight flight;
  Widget back, visualizeFlight;
  int textSize;
  Screen previousScreen;

  DirectoryFlightInfoScreen(Flight currentFlight, Screen previousScreen) {
    logo = loadImage("Flighthub Logo.png");
    logo.resize(int(360 * 1.9), int(240 * 1.9));
    
    showData(currentFlight);
    
    back = new Widget(width - 160, 160, 2, 100, 50, #674C11);
    textSize = int((width - 110) * 0.014);
    airlineLogo = loadImage("airlines-logos/" + currentFlight.airlineCode + ".png");
    
    visualizeFlight = new Widget(width / 12, height * 5 / 6, 17, 350, 60, #5A5852);
    
    this.previousScreen = previousScreen;
  }
  
  void showData(Flight currentFlight) {
    flight = currentFlight;
  }

  void draw() {
    background(0);
    for (int i = 0; i < numStars; i++) {
      stars[i].update();
      stars[i].display();
    }
    for (int i = 0; i < numMoreStars; i++) {
      moreStars[i].update();
      moreStars[i].display();
    }
    for (int i = 0; i < numEvenMoreStars; i++) {
      evenMoreStars[i].update();
      evenMoreStars[i].display();
    }
    
    imageMode(CORNER);
    image(logo, 20, -100);
    
    // Use depth testing disabled to ensure transparency is applied.
    hint(DISABLE_DEPTH_TEST);
    pushStyle();
      stroke(135, 206, 235, 150);
      strokeWeight(5);
      fill(128, 128, 128, 50);
      rect(55, 280, width - 110, height - 335, 15);
    popStyle();
    hint(ENABLE_DEPTH_TEST);
    
    textSize(textSize);
    fill(255);
    int iPos = 140;
    int jPos = 430 + ((textSize * 3) + 3);
    
    text("Origin:                " + getAirport(flight.origin) + " / " + flight.origin, iPos, jPos + textSize * 9);
    text("From:      " + getAirportAddress(flight.origin), iPos, jPos - textSize * 5);
    text("Destination:     " + getAirport(flight.destination) + " / " + flight.destination, iPos, jPos + textSize * 10 + 10);
    text("To:            " + getAirportAddress(flight.destination), iPos, jPos - textSize * 4 + 10);
    
    text("Scheduled Departure:    " + flight.scheduledDeparture, iPos + width / 2, jPos - textSize * 5);
    text("Scheduled Arrival:            " + flight.scheduledArrival, iPos + width / 2, jPos - textSize * 4 + 10);
    text("Actual Departure:             " + flight.actualDeparture, iPos + width / 2, jPos - textSize * 2 + 30);
    text("Actual Arrival:                     " + flight.actualArrival, iPos + width / 2, jPos - textSize + 40);
    text("Delayed:    " + flight.departureDelay + " mins", iPos + width / 2, jPos + textSize * 4 + 20);
    text("Flight Distance:  " + flight.flightDistance + " km", iPos, jPos + textSize * 4 + 30);
    
    text("Flight Number:  " + flight.airlineCode + " " + flight.flightNumber, iPos, jPos);
    text("Carrier:  " + getCarrier(flight.airlineCode), iPos, jPos + textSize * 2 + 20);
    text("Date:  " + flight.date, iPos, jPos + textSize + 10);     
    text("Cancelled:  " + (flight.cancelled ? "Yes" : "No"), iPos + width / 2, jPos + textSize * 9);
    text("Diverted:  " + (flight.diverted ? "Yes" : "No"), iPos + width / 2, jPos + textSize * 10 + 20);
    
    noStroke();
    fill(255);
    rect(iPos + (width * 2 / 3) - 10, jPos + (textSize * 12) - 10, 320, 170, 6);
    image(airlineLogo, iPos + (width * 2 / 3), jPos + textSize * 12);
    
    visualizeFlight.draw();
    back.draw();
  }
  
  void mousePressed() {
    println("x: " + mouseX + "  y: " + mouseY);
    if (back.mouseOver()) {
      screenManager.switchScreen(previousScreen);
    }
    if (visualizeFlight.mouseOver()) {
      screenManager.switchScreen(new EarthScreenDirectory(earth, flight, this));
    }
  }
}
