class Query{
  int x, y, colour, mode;
  Widget lateness, distance, date, cancelled, diverted, cancel, airport;
  DateSelector selector;
  AirportSorter airportSelector;
  
  
  Query(int colour, int mode){
    x=500;
    y=400;
    this.colour=colour;
    this.mode=mode;
    if(mode==1){
      lateness = new Widget(width/2-(width/10)*2, y+160, 7, width/10, height/16, #F57F5B);
      distance = new Widget(width/2-width/20, y+160, 8, width/10, height/16, #764838);
      date = new Widget(width/2+width/10, y+160, 9, width/10, height/16, #FAA968);
      
      cancelled = new Widget(width/2-(width/10)*2, (y+160)+height/8, 11, width/10, height/16, #028391);
      diverted = new Widget(width/2-width/20, (y+160)+height/8, 12, width/10, height/16, #FAECB6);
      airport = new Widget(width/2+width/10, (y+160)+height/8, 14, width/10, height/16, #A73838);
    }
    else if(mode==2){
      selector = new DateSelector();
    }
    else if(mode==3){
      airportSelector = new AirportSorter();
    }
    cancel = new Widget(width/2-width/40, (y+160)+height/3, 13, width/20, height/32, #99AAAA);
  }


  void draw(){
    strokeWeight(4);
    stroke(0);
    fill(colour);
    rect(x, y, width-2*x, height-y-100, 6);
    
    strokeWeight(2);
    if(mode==1){
      lateness.draw();
      distance.draw();
      date.draw();
      cancelled.draw();
      diverted.draw();
      airport.draw();
    }
    else if(mode==2){
      selector.draw();
    }
    else if(mode==3){
      airportSelector.draw();
    }
    cancel.draw();
  }

}
