class Screen{
  int screenNum;
  int textSize;
  float scrollPercent;

  Screen(int mode){
    screenNum = mode;
    textSize=24;
    scrollPercent = 0;
  }
  
  float getPercent(){
    float percent = scrollPercent*0.001/4;
    if(percent>0.9999) return(0.9999);
    else if(percent<0) return(0);
    return(percent);
   }
  
  void printArray(){
    int counter=0;
    for(int i=int((flights.size()*getPercent())); (i<flights.size() && counter<25); i++){
      String info = flights.get(i).toString();
      text(info, 80, 320+((textSize+3)*counter));
      counter++;
    }
    //println(getPercent());
  } 

  void draw(){
    if(screenNum==1){
      background(20);
      
      textSize(60);
      fill(240);
      text("Flight", 80, 100);
      fill(#00ACFF);
      rect(230, 50, 122, 65);
      fill(0);
      text("hub", 240, 100);
      
      rect(55, 280, 1740, 710);
      
      textSize(textSize);
      fill(0, 240, 0);
      printArray();
    }
    
  }

}
