class Screen{
  int screenNum;
  int textSize;
  float scrollPercent;

  Screen(int mode){
    screenNum = mode;
    textSize=24;
    scrollPercent = 0;
  }
  
  void printArray(){
    int counter=0;
    for(int i=int((flights.size()*scrollPercent)); (i<flights.size() && counter<30); i++){
      String info = flights.get(i).toString();
      text(info, 100, 200+((textSize+3)*i));
      counter++;
    }
  } 

  void draw(){
    if(screenNum==1){
      background(0);
      textSize(textSize);
      fill(0, 240, 0);
      printArray();
    }
    
  }

}
