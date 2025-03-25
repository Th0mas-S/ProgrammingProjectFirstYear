class Query{
  int x, y, colour, mode;
  Widget lateness, distance, date;
  DateSelector selector;
  
  
  Query(int colour, int mode){
    x=300;
    y=350;
    this.colour=colour;
    this.mode=mode;
    if(mode==1){
      lateness = new Widget(x+width/7, y+160, 7, 200, 100, #F57F5B);
      distance = new Widget(x+(width/7)*2, y+160, 8, 200, 100, #764838);
      date = new Widget(x+(width/7)*3, y+160, 9, 200, 100, #FAA968);
    }
    else if(mode==2){
      selector = new DateSelector();
    }
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
    }
    else if(mode==2){
      selector.draw();
    }
    
  }

}
