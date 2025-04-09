class AirportSorter{
  int x, y;
  Widget origin, destination;
  Search search;
  String airportCode;


  AirportSorter(){
    x=450;
    y=400;
    airportCode="code";
    
    search = new Search(width/2-140, y+height/12, 24, 4);
    origin = new Widget(width/2-300, y+height/5, 15, 200, 100, #01204E);
    destination = new Widget(width/2+100, y+height/5, 16, 200, 100, #01204E);
  }
  
  void sortOrigin(){
    arrayIndex = new ArrayList<Integer>();          
    for(int i=0; i<flights.size(); i++){
      if(flights.get(i).origin.equalsIgnoreCase(airportCode)){ 
        arrayIndex.add(i);
      }
    }                                              
    println("sorted: "+airportCode);                              
  }
  
  void sortDestination(){
    arrayIndex = new ArrayList<Integer>();          
    for(int i=0; i<flights.size(); i++){
      if(flights.get(i).destination.equalsIgnoreCase(airportCode)){ 
        arrayIndex.add(i);
      }
    }                                              
    println("sorted: "+airportCode);  
  }


  void draw(){
    textSize(40);
    stroke(0);
    fill(0);
    
    search.draw();
    origin.draw();
    destination.draw();
  }



}
