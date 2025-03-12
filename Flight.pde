class Flight{
  String[] list;
  
  String date, carrier, origin, orCity, orCode, destination, destCity, destCode, depTimeE, depTime, arrTimeE, arrTime;
  int flNumber, orWAC, destWAC, flDistance, x, y, minsLate;
  boolean cancelled, diverted;

  Flight(){
  }
  
  boolean clicked(){
    if(mouseX>x-10 && mouseX<x+1555 && mouseY>y-27 && mouseY<y){
      return true;
    }
    else return false;
  }
  
  String getTime(String input){
    String[] time=split(input, "");
    return(time[0]+time[1]+":"+time[2]+time[3]);
  }
  
  void printInfo(){
    println(date+" "+carrier+" "+flNumber+" "+origin+" "+orCity+" "+orCode+" "+orWAC+" "
      +destination+" "+destCity+" "+destCode+" "+destWAC+" "+depTimeE+" "+depTime+" "+
      arrTimeE+" "+arrTime+" "+(cancelled ? "cancelled":"n/a")+" "+
      (diverted ? "diverted":"n/a")+" "+flDistance);
  }
  
  void dataLocation(int xIn, int yIn){
    x=xIn;
    y=yIn;
  }
  
  void draw(){
    if(currentScreen==1) fill(0);
    else fill(0, 240, 0);
    textSize(16);
    text(date, x, y);
    text(carrier, 225, y);
    text(flNumber, 250, y);
    text(origin, 305, y);
    text(orCity, 355, y);
    text(orWAC, 617, y);
    text(destination, 658, y);
    text(destCity, 715, y);
    text(destWAC, 975, y);
    text(depTimeE, 1025, y);
    text(depTime, 1108, y);
    text(arrTimeE, 1191, y);
    text(arrTime, 1274, y);
    if(cancelled) text("Yes", 1385, y);
    else text("  -", 1385, y);
    if(diverted) text("Yes", 1510, y);
    else text("  -", 1510, y);
    text(flDistance, 1610, y);
    
  }

}
