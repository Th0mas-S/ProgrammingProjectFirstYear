
void loadAirportCoordinates(String filepath) {
  
}

class HeatMapScreen extends Screen {
  
  PImage earthImage;
  
  HeatMapScreen() {
    earthImage = loadImage("worldmap.png");
  }
  
  void draw() {
    fill(0);
    image(earthImage, 0, 0, width, height);
    
  }
}
