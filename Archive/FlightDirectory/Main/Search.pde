class Search{
  int x, y, textSize, sHeight, sWidth;
  int animation, mode;
  boolean search;
  
  Search(int x, int y, int textSize, int mode){
    this.x=x;
    this.y=y;
    this.textSize=textSize;
    this.mode=mode;
    sHeight=50;
    sWidth=280;
    animation=0;
    clearInput();
  }

  boolean mouseOver(){
    if(mouseX>x && mouseX<x+sWidth && mouseY>y && mouseY<y+sHeight){
      return true;
    }
    else return false;
  }
  
  void searchPressed(){                                  //determines if the user clicked on the search bar
    if(mouseOver()){
      clearInput();
      search=true;
    }
    else search=false;
  }

  void draw(){
    if(mouseOver()) stroke(255);
    else stroke(0);
    fill(200);
    rect(x, y, sWidth, sHeight, 8);
    fill(0);
    textSize(25);
    if(mode==1){
      if(!search){                                          //code for showing either "search" or the users currently typed in characters
        text("Search", x+20, y+33);
      }
      else{
        if(inputText.equals("")){
          if(animation>35){
            text("Search_", x+20, y+33);
            animation++;
          }
          else{
            text("Search", x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
        else{
          if(animation>35){
            text(inputText+"_", x+20, y+33);
            animation++;
          }
          else{
            text(inputText, x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
      }
    }
    else if(mode==2){
      if(!search){                                          
        text(screen1.dateMenu.selector.date1, x+20, y+33);
      }
      else{
        if(inputText.equals("")){
          if(animation>35){
            text("_", x+20, y+33);
            animation++;
          }
          else{
            text("", x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
        else{
          if(animation>35){
            text(inputText+"_", x+20, y+33);
            animation++;
          }
          else{
            text(inputText, x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
      }
    }
    else if(mode==3){
      if(!search){                                          
        text(screen1.dateMenu.selector.date2, x+20, y+33);
      }
      else{
        if(inputText.equals("")){
          if(animation>35){
            text("_", x+20, y+33);
            animation++;
          }
          else{
            text("", x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
        else{
          if(animation>35){
            text(inputText+"_", x+20, y+33);
            animation++;
          }
          else{
            text(inputText, x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
      }  
    }
    else if(mode==4){
      if(!search){                                          
        text(screen1.airportMenu.airportSelector.airportCode, x+20, y+33);
      }
      else{
        if(inputText.equals("")){
          if(animation>35){
            text("_", x+20, y+33);
            animation++;
          }
          else{
            text("", x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
        else{
          if(animation>35){
            text(inputText+"_", x+20, y+33);
            animation++;
          }
          else{
            text(inputText, x+20, y+33);
            animation++;
          }
          if(animation>70) animation=0;
        }
      }  
    }
    
    
    
    if(entered && mode==1 && search){                                      //when the user enters (from keyPressed() in main) it calls the search method
      screen1.search(inputText);                      //with the user input and resets the search bar
      entered=false;
      search=false;
    }
    if(entered && mode==2 && search){
      screen1.dateMenu.selector.date1=inputText;
      entered=false;
      search=false;
    }
    if(entered && mode==3 && search){
      screen1.dateMenu.selector.date2=inputText;
      entered=false;
      search=false;
    }
    if(entered && mode==4 && search){
      screen1.airportMenu.airportSelector.airportCode=inputText;
      entered=false;
      search=false;
    }
  }
    


}
