class Screen{
  ArrayList<Header> headers;
  int screenNum;
  int textSize, sliderLength;
  float scrollPercent;
  PImage logo, backdrop;
  boolean sortQuery, dateQuery, airportQuery;
  Query sortMenu, dateMenu, airportMenu;
  Slider slider;
  Search searchbar;
  Widget clear, back, sort;
  Widget directory, graphs, exitButton;
  Flight flight;
  Graphs newGraph;
  Header date;

  Screen(int mode){
    screenNum = mode;
    textSize=int((width-110)*0.014);
    logo = loadImage("Flighthub Logo.png");
    logo.resize(int(360*1.2), int(240*1.2));
    backdrop = loadImage("backdrop1.png");
    backdrop.resize(width, height);
    if(mode==1){                                                    //screen1..
      scrollPercent = 0;
      sliderLength=height-335-55-40;
      slider = new Slider(width-28, height-55-(sliderLength/2)-(height-335)/2, sliderLength);
      searchbar = new Search(width-340, 160, textSize, 1);
      clear = new Widget(width-480, 160, 1, 100, 50, #F96635);
      sort = new Widget(width-610, 160, 6, 100, 50, #028391);                        //current widget = 14 
      sortMenu = new Query(#93D3AE, 1);
      dateMenu = new Query(#FAECB6, 2);
      airportMenu = new Query(#9DCDDE, 3);
      
      headers = new ArrayList<Header>();
      headers.add( new Header(int(85+(textSize*2.5)), 307, "Date", int(textSize/1.1), 1) );
      headers.add( new Header(int(85+(textSize*8.7)), 307, "Flight", int(textSize/1.1), 2) );
      headers.add( new Header(int(85+(textSize*15)), 307, "Route", int(textSize/1.1), 3) );
      headers.add( new Header(int(85+(textSize*22)), 307, "Scheduled", int(textSize/1.1), 4) );
      headers.add( new Header(int(85+(textSize*31)), 307, "Actual", int(textSize/1.1), 5) );
      headers.add( new Header(int(85+(textSize*40)), 307, "Delay", int(textSize/1.1), 6) );
      headers.add( new Header(int(85+(textSize*47)), 307, "Diverted", int(textSize/1.1), 7) );
      headers.add( new Header(int(85+(textSize*55)), 307, "Cancelled", int(textSize/1.1), 8) );
      headers.add( new Header(int(85+(textSize*65)), 307, "Distance", int(textSize/1.1), 9) );
      
    }
    else if(mode==2){                                                //screen2...
      back = new Widget(width-160, 160, 2, 100, 50, #DD5341);
    }
    else if(mode==3){                                                //start screen...
      directory = new Widget((width/2)-(width/8), height/3, 3, width/4, 200, #028391);
      graphs = new Widget((width/2)-(width/8), int((height/3)*1.6), 4, width/4, 200, #F9A822);
      exitButton = new Widget((width/2)-(width/8), int((height/3)*2.2), 5, width/4, 200, #F57F5B);
    }
    else if(mode==4){                                                //start screen...
      newGraph = new Graphs();
    }
  }
  
  void filterCancelled(){
    arrayIndex = new ArrayList<Integer>();          
    for(int i=0; i<flights.size(); i++){
      if(flights.get(i).cancelled){ 
        arrayIndex.add(i);
      }
    }  
  }
  
  void filterDiverted(){
    arrayIndex = new ArrayList<Integer>();          
    for(int i=0; i<flights.size(); i++){
      if(flights.get(i).diverted){ 
        arrayIndex.add(i);
      }
    }  
  }
  
  
  void printArray(){                                //prints all the Flight data from each Flight in flights array that is selected by index array
    int counter=0;
    for(int i=int((arrayIndex.size()*(slider.getPercent()))); (i<arrayIndex.size() && counter<(height-335-55)/(textSize+3)); i++){
      flights.get(arrayIndex.get(i)).drawData(85, 315+((textSize+3)*counter)+int(height*0.02), textSize);
      counter++;
    }
  } 
  
  void search(String query){                        //once called it sets index array to all Flight locations whose airline/flight number/origin or destination
    arrayIndex = new ArrayList<Integer>();          //match the query (search parameter) passed into the function
    for(int i=0; i<flights.size(); i++){
      if(flights.get(i).airlineCode.equalsIgnoreCase(query) || flights.get(i).flightNumber.equalsIgnoreCase(query) || flights.get(i).origin.equalsIgnoreCase(query) 
      || flights.get(i).destination.equalsIgnoreCase(query) || query.equalsIgnoreCase(flights.get(i).airlineCode+flights.get(i).flightNumber)){ 
        arrayIndex.add(i);
      }
    }                                               
    println("sorted: "+query);                              
  }
  
  void sortByDate(String date1In, String date2In) {
    arrayIndex = new ArrayList<>();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    LocalDate startDate = LocalDate.parse(date1In, formatter);
    LocalDate endDate = LocalDate.parse(date2In, formatter);
    for (int i = 0; i < flights.size(); i++) {
        LocalDate flightDate = LocalDate.parse(flights.get(i).date, formatter);
        if (!flightDate.isBefore(startDate) && !flightDate.isAfter(endDate)) {
            arrayIndex.add(i);
        }
    }
  }
  
  void sortByLateness(){
    clearIndex();
    arrayIndex.sort((i, j) -> Integer.compare(flights.get(j).departureDelay, flights.get(i).departureDelay));
  }
  
  void sortByDistance(){
    clearIndex();
    arrayIndex.sort((i, j) -> Integer.compare(int(flights.get(j).flightDistance), int(flights.get(i).flightDistance)));
  }
  
  void checkFlights(){                              //checks if a user has clicked on a specific line of flight data and takes them to that data page
    if(mouseX>55 && mouseY>280){
      int counter=0;
      for(int i=int((arrayIndex.size()*(slider.getPercent()))); (i<arrayIndex.size() && counter<(height-335-55)/(textSize+3)); i++){
        if(flights.get(arrayIndex.get(i)).mouseOver) showFlight(flights.get(arrayIndex.get(i)));
        counter++;
      }
    }
  }
  
  void showData(Flight currentFlight){
    flight = currentFlight;
  }
  
  void drawHeaders(){
    for(int i=0; i<headers.size(); i++){
      headers.get(i).draw();
    }
  }
  
  void clearHeaders(){
    for(int i=0; i<headers.size(); i++){
      headers.get(i).clicked=false;
    }
  }
  
  void headersPressed(){
    for(int i=0; i<headers.size(); i++){
      headers.get(i).headerPressed();
    }
  }

  void draw(){
    
    if(screenNum==1){                                    //main directory screen
      background(backdrop);
      image(logo, 60, 60);
      stroke(100);
      strokeWeight(5);
      fill(160, 160, 160, 220);      
      rect(55, 280, width-110, height-335, 15);
      
      strokeWeight(1);
      stroke(0);
      textSize(textSize);
      fill(#3E1607);
      printArray();
      
      stroke(100);
      strokeWeight(5);
      
      line(90+(textSize*5.6), 280, 90+(textSize*5.6), height-55);
      line(90+(textSize*11.1), 280, 90+(textSize*11.1), height-55);
      line(90+(textSize*18), 280, 90+(textSize*18), height-55);
      line(90+(textSize*26.25), 280, 90+(textSize*26.25), height-55);
      line(90+(textSize*35.833), 280, 90+(textSize*35.833), height-55);
      line(90+(textSize*43.333), 280, 90+(textSize*43.333), height-55);
      line(90+(textSize*50.833), 280, 90+(textSize*50.833), height-55);
      line(90+(textSize*58.75), 280, 90+(textSize*58.75), height-55);
      
      drawHeaders();
      
      slider.draw();
      searchbar.draw();
      clear.draw();
      sort.draw();
      if(sortQuery) sortMenu.draw();
      if(dateQuery) dateMenu.draw();
      if(airportQuery) airportMenu.draw();
    }
    else if(screenNum==2){                               //individual flight data page
      background(#FAA968);
      image(logo, 60, 60);
      stroke(0);
      fill(#2BBAA5);      
      rect(55, 280, width-110, height-335, 15);
      textSize(textSize);
      fill(0);
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
      
      back.draw();
    }
    else if(screenNum==3){                               //start menu screen
      background(#9DCDDE);
      imageMode(CENTER);
      image(logo, (width/2), 200);
      imageMode(CORNER);
      textAlign(LEFT);
      directory.draw();
      graphs.draw();
      exitButton.draw();
    }
    
     else if(screenNum==4){                               //graph screen
     newGraph.draw();
     newGraph.drawButtons();
     newGraph.drawPieChart();
    }
    
  }

}
