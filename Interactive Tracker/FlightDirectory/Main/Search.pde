class Search{
  int x, y, textSize, sHeight, sWidth;
  int animation;
  boolean search;
  
  Search(int x, int y, int textSize){
    this.x=x;
    this.y=y;
    this.textSize=textSize;
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
    
    if(entered){                                      //when the user enters (from keyPressed() in main) it calls the search method
      screen1.search(inputText);                      //with the user input and resets the search bar
      entered=false;
      search=false;
    }
  }
    


}
