
class AirportInfoScreen extends Screen {
  
  String airportName;
  
  AirportInfoScreen(String name) {
    airportName = name;
  }
  
  void draw() {
      background(50);
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(64);
      text(this.airportName, width/2, height/3);
      
      textSize(32);
      fill(200);
      rectMode(CENTER);
      rect(width/2, height*2/3, 200, 50);
      fill(0);
      text("Return", width/2, height*2/3);
  }
  
  void mousePressed() {
     if (mouseX > width/2 - 100 && mouseX < width/2 + 100 &&
          mouseY > height*2/3 - 25 && mouseY < height*2/3 + 25) {
        //earth.inertiaAngle = 0;
        //earth.isDragging = false;
        screenManager.switchScreen(earthScreen);
     }
  }
  


}
