class Screen{
  int screenNum;
  int textSize, sliderLength;
  float scrollPercent;
  PImage logo;
  Slider slider;
  Search searchbar;
  Widget clear, back;
  Widget directory;
  Flight flight;

  Screen(int mode){
    screenNum = mode;
    textSize=int((width-110)*0.014);
    logo = loadImage("logoBigHD.png");
    if(mode==1){                                                    //screen1..
      scrollPercent = 0;
      sliderLength=height-335-55-40;
      slider = new Slider(width-28, height-55-(sliderLength/2)-(height-335)/2, sliderLength);
      searchbar = new Search(width-340, 160, textSize);
      clear = new Widget(width-480, 160, 1, 100, 50, #B4B1B1);
    }
    else if(mode==2){                                                //screen2...
      back = new Widget(width-160, 160, 2, 100, 50, #B4B1B1);
    }
    else if(mode==3){                                                //start screen...
      directory = new Widget((width/2)-300, 500, 3, 600, 200, #B79746);
    }
  }
  
  
  void printArray(){                                //prints all the Flight data from each Flight in flights array that is selected by index array
    int counter=0;
    for(int i=int((arrayIndex.size()*(slider.getPercent()))); (i<arrayIndex.size() && counter<(height-335-55)/(textSize+3)); i++){
      flights.get(arrayIndex.get(i)).drawData(85, 325+((textSize+3)*counter), textSize);
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
  
  void checkFlights(){                              //checks if a user has clicked on a specific line of flight data and takes them to that data page
    int counter=0;
    for(int i=int((arrayIndex.size()*(slider.getPercent()))); (i<arrayIndex.size() && counter<(height-335-55)/(textSize+3)); i++){
      if(flights.get(arrayIndex.get(i)).mouseOver) showFlight(flights.get(arrayIndex.get(i)));
      counter++;
    }

  }
  
  void showData(Flight currentFlight){
    flight = currentFlight;
  }

  void draw(){
    
    if(screenNum==1){                                    //main directory screen
      background(0);
      image(logo, 60, 60);
      stroke(0);
      fill(40);      
      rect(55, 280, width-110, height-335, 15);
      textSize(textSize);
      fill(0, 240, 0);
      printArray();
      slider.draw();
      searchbar.draw();
      clear.draw();
    }
    else if(screenNum==2){                               //individual flight data page
      background(0);
      image(logo, 60, 60);
      stroke(0);
      fill(40);      
      rect(55, 280, width-110, height-335, 15);
      textSize(textSize);
      fill(0, 240, 0);
      flight.drawData(85, 325+((textSize+3)), textSize);
      back.draw();
    }
    else if(screenNum==3){                               //start menu screen
      background(#F7FFC9);
      textAlign(CENTER);
      image(logo, (width/2)-170, 60);
      textAlign(LEFT);
      directory.draw();
    }
    
  }

}
