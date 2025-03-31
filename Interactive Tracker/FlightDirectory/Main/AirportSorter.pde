class AirportSorter{
  int x, y;
  Widget origin, destination;
  Search search;
  String airportCode;


  AirportSorter(){
    x=450;
    y=500;
    airportCode="code";
    
    search = new Search(width/2-280-50, y+height/10, 24, 4);
    origin = new Widget(width/2-280-50, y+height/4, 15, 200, 100, #01204E);
    destination = new Widget(width/2+50, y+height/4, 16, 200, 100, #01204E);
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
