class Screen{
  int screenNum;
  int textSize, sliderLength;
  float scrollPercent;
  PImage logo;
  boolean sortQuery, dateQuery;
  Query sortMenu, dateMenu;
  Slider slider;
  Search searchbar;
  Widget clear, back, sort;
  Widget directory, graphs, exitButton;
  Flight flight;
  Graphs newGraph;

  Screen(int mode){
    screenNum = mode;
    textSize=int((width-110)*0.014);
    logo = loadImage("logoBigHD.png");
    if(mode==1){                                                    //screen1..
      scrollPercent = 0;
      sliderLength=height-335-55-40;
      slider = new Slider(width-28, height-55-(sliderLength/2)-(height-335)/2, sliderLength);
      searchbar = new Search(width-340, 160, textSize, 1);
      clear = new Widget(width-480, 160, 1, 100, 50, #F96635);
      sort = new Widget(width-610, 160, 6, 100, 50, #028391);                        //current widget = 9
      sortMenu = new Query(#93D3AE, 1);
      dateMenu = new Query(#FAECB6, 2);
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
  
  
  void printArray(){                                //prints all the Flight data from each Flight in flights array that is selected by index array
    int counter=0;
    for(int i=int((arrayIndex.size()*(slider.getPercent()))); (i<arrayIndex.size() && counter<(height-335-55)/(textSize+3)); i++){
      flights.get(arrayIndex.get(i)).drawData(85, 310+((textSize+3)*counter)+int(height*0.02), textSize);
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
    }                                               //needs support for location names/airline names and not be case sensitive
    println("sorted: "+query);                              //e.g. can only take "LAX" not "los angeles" or "lax"
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

  void draw(){
    
    if(screenNum==1){                                    //main directory screen
      background(#FACA78);
      image(logo, 60, 60);
      stroke(100);
      strokeWeight(5);
      fill(160);      
      rect(55, 280, width-110, height-335, 15);
      
      //stroke(120);
      line(90+(textSize*4.791), 280, 90+(textSize*4.791), height-55);
      line(90+(textSize*8.958), 280, 90+(textSize*8.958), height-55);
      line(90+(textSize*15), 280, 90+(textSize*15), height-55);
      line(90+(textSize*26.25), 280, 90+(textSize*26.25), height-55);
      line(90+(textSize*35.833), 280, 90+(textSize*35.833), height-55);
      line(90+(textSize*43.333), 280, 90+(textSize*43.333), height-55);
      line(90+(textSize*50.833), 280, 90+(textSize*50.833), height-55);
      line(90+(textSize*58.75), 280, 90+(textSize*58.75), height-55);
      
      strokeWeight(1);
      stroke(0);
      textSize(textSize);
      fill(#3E1607);
      printArray();
      slider.draw();
      searchbar.draw();
      clear.draw();
      sort.draw();
      if(sortQuery) sortMenu.draw();
      if(dateQuery) dateMenu.draw();
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
      int j = 325+((textSize*3+3));
      
      text("Origin:                "+flight.origin, i, j+textSize*9);
      text("From:      "+getAirport(flight.origin), i, j+textSize*5);
      text("Destination:     "+flight.destination, i, j+textSize*10+10);
      text("To:            "+getAirport(flight.destination), i, j+textSize*6+10);
      text("Scheduled Departure:    "+flight.scheduledDeparture, i+width/2, j);
      text("Scheduled Arrival:            "+flight.scheduledArrival, i+width/2, j+textSize*1+10);
      text("Actual Departure:             "+flight.actualDeparture, i+width/2, j+textSize*3+10);
      text("Actual Arrival:                     "+flight.actualArrival, i+width/2, j+textSize*4+20);
      text("Delayed:    "+flight.departureDelay+"mins", i+width/2, j+textSize*7+20);
      text("Flight Number:  "+flight.airlineCode+" "+flight.flightNumber, i, j);
      text("Carrier:  "+getCarrier(flight.airlineCode), i, j+textSize*2+20);
      text("Date:  "+flight.date, i, j+textSize+10);
      text("Flight Distance:  "+flight.flightDistance+"km", i+width/2, j+textSize*11);
      
      back.draw();
    }
    else if(screenNum==3){                               //start menu screen
      background(#FACA78);
      textAlign(CENTER);
      image(logo, (width/2)-170, 100);
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
