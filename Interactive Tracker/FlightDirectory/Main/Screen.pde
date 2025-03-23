class Screen{
  int screenNum;
  int textSize, sliderLength;
  float scrollPercent;
  PImage logo;
  Slider slider;

  Screen(int mode){
    screenNum = mode;
    textSize=int((width-110)*0.014);
    scrollPercent = 0;
    if(mode==1) logo = loadImage("logoB.png");
    sliderLength=height-335-55-40;
    slider = new Slider(width-28, height-55-(sliderLength/2)-(height-335)/2, sliderLength);
  }
  
  
  void printArray(){                                //prints all the Flight data from each Flight in flights array that is selected by index array
    int counter=0;
    for(int i=int((arrayIndex.size()*(slider.getPercent()))); (i<arrayIndex.size() && counter<(height-335-55)/(textSize+3)); i++){
      String info = flights.get(arrayIndex.get(i)).toString();
      text(info, 80, 320+((textSize+3)*counter));
      counter++;
    }
  } 
  
  void search(String query){                        //once called it sets index array to all Flight locations whose airline/flight number/origin or destination
    arrayIndex = new ArrayList<Integer>();          //match the query (search parameter) passed into the function
    for(int i=0; i<flights.size(); i++){
      if(flights.get(i).airlineCode.equals(query) || flights.get(i).flightNumber.equals(query) || flights.get(i).origin.equals(query) || flights.get(i).destination.equals(query)){ 
        arrayIndex.add(i);
      }
    }                                               //needs support for location names/airline names and not be case sensitive
    println("sorted: "+query);                              //e.g. can only take "LAX" not "los angeles" or "lax"
  }

  void draw(){
    if(screenNum==1){
      background(20);
      image(logo, 60, 60);
      
      stroke(0);
      fill(0);      
      rect(55, 280, width-110, height-335, 15); 
      textSize(textSize);
      fill(0, 240, 0);
      printArray();
      slider.draw();
    }
    
  }

}
