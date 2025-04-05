class DirectoryFlightInfoScreen extends Screen {
  
  PImage logo, backdrop, airlineLogo, tab;
  Flight flight;
  Widget back, visualizeFlight;
  int textSize;
  Screen previousScreen;

  DirectoryFlightInfoScreen(Flight currentFlight, Screen previousScreen) {
    //textSize=int((width-110)*0.014);
    logo = loadImage("Flighthub Logo.png");
    logo.resize(int(360*1.9), int(240*1.9));
    tab = loadImage("ds_tab.png");
    
    backdrop = loadImage("ds_backdrop.png");
    backdrop.resize(width, height);
    showData(currentFlight);
    back = new Widget(width-160, 160, 2, 100, 50, #674C11);
    textSize=int((width-110)*0.014);
    airlineLogo=loadImage(("airlines-logos/"+currentFlight.airlineCode+".png"));

    visualizeFlight = new Widget(width/12, height*5/6, 17, 350, 60, #5A5852);
    
    this.previousScreen = previousScreen;

  }
  
  void showData(Flight currentFlight){
    flight = currentFlight;
  }

  void draw() {
      backdrop.resize(width, height);
      background(backdrop);
      
      //noStroke();
      //fill(100, 100, 100, 230);
      //rect(58, 63, 531, 131, 10);
      
      stroke(100);
      strokeWeight(5);
      fill(160, 160, 160, 220);      
      rect(58, 63-15, 531+23, 131+30, 13);        //logo border
      imageMode(CORNER);
      image(logo, 20, -100);
      imageMode(CORNER);
      
      
      stroke(0);
      fill(0);      
      rect(55, 280, width-110, height-335, 15);
      tab.resize(width-110-10, height-335-10);
      image(tab, 60, 285);
      textSize(textSize);
      fill(255);
      int i = 140;
      int j = 430+((textSize*3+3));
      
      text("Origin:                "+getAirport(flight.origin)+" / "+flight.origin, i, j+textSize*9);
      text("From:      "+getAirportAddress(flight.origin), i, j-textSize*5);
      text("Destination:     "+getAirport(flight.destination)+" / "+flight.destination, i, j+textSize*10+10);
      text("To:            "+getAirportAddress(flight.destination), i, j-textSize*4+10);
      
      text("Scheduled Departure:    "+flight.scheduledDeparture, i+width/2, j-textSize*5);
      text("Scheduled Arrival:            "+flight.scheduledArrival, i+width/2, j-textSize*4+10);
      text("Actual Departure:             "+flight.actualDeparture, i+width/2, j-textSize*2+30);
      text("Actual Arrival:                     "+flight.actualArrival, i+width/2, j-textSize+40);
      text("Delayed:    "+flight.departureDelay+"mins", i+width/2, j+textSize*4+20);
      text("Flight Distance:  "+flight.flightDistance+"km", i, j+textSize*4+30);
      
      text("Flight Number:  "+flight.airlineCode+" "+flight.flightNumber, i, j);
      text("Carrier:  "+getCarrier(flight.airlineCode), i, j+textSize*2+20);
      text("Date:  "+flight.date, i, j+textSize+10);     
      text("Cancelled:  "+(flight.cancelled ? "Yes":"No"), i+width/2, j+textSize*9);
      text("Diverted:  "+(flight.diverted ? "Yes":"No"), i+width/2, j+textSize*10+20);
      
      noStroke();
      fill(255);
      rect(i+(width*2/3)-10, j+(textSize*12)-10, 300+20, 150+20, 6);
      image(airlineLogo, i+(width*2/3), j+textSize*12);
      visualizeFlight.draw();
      
      back.draw();
  }
  
  void mousePressed() {
    println("x: "+mouseX+"  y: "+mouseY);
    if(back.mouseOver()) {
      screenManager.switchScreen(previousScreen);
    }
    visualizeFlight.widgetPressed();
  }

}
