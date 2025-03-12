class Search{
  boolean searchB;
  int animation, mode;
  
  Search(int modeIn){
    mode=modeIn;
    searchB=false;
    animation=0;
  }

  void draw(){
    if(searchB && mode==1){
      stroke(0);
      fill(240);
      rect(1600, 50, 200, 50);
      fill(0);
      textSize(25);
      text("Airport:", 1510, 83);
      if(inputText.equals("")){
        if(animation>35){
          text("Search_", 1620, 83);
          animation++;
        }
        else{
          text("Search", 1620, 83);
          animation++;
        }
        if(animation>70) animation=0;
      }
      else{
        if(animation>35){
          text(inputText+"_", 1620, 83);
          animation++;
        }
        else{
          text(inputText, 1620, 83);
          animation++;
        }
        if(animation>70) animation=0;
      }
    }
    else if(mode==2){
      stroke(0);
      fill(240);
      rect(1450, 50, 350, 50);
      fill(0);
      textSize(25);
      text("Dates:", 1360, 83);
      
      if(inputText.equals("")){
        if(animation>35){
          if(screen1.phase==0){
            text("From_", 1480, 83);
            animation++;  
          }
          else{
            text(screen1.input1, 1480, 83);
            text("To_", 1640, 83);
            animation++; 
          }
        }
        else{
          if(screen1.phase==0){
            text("From", 1480, 83);
            animation++;  
          }
          else{
            text(screen1.input1, 1480, 83);
            text("To", 1640, 83);
            animation++; 
          }
        }
        if(animation>70) animation=0;
      }
      else{
        if(animation>35){
          if(screen1.phase==0){
            text(inputText+"_", 1480, 83);
            animation++;  
          }
          else{
            text(screen1.input1, 1480, 83);
            text(inputText+"_", 1620, 83);
            animation++; 
          }
        }
        else{
          if(screen1.phase==0){
            text(inputText, 1480, 83);
            animation++;  
          }
          else{
            text(screen1.input1, 1480, 83);
            text(inputText, 1620, 83);
            animation++; 
          }
        }
        if(animation>70) animation=0;
      }
    }
    
   }

}
