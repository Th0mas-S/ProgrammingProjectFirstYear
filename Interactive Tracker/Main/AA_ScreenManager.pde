
class Screen {
  void draw() {}
  void mousePressed() {}
  void mouseDragged() {}
  void mouseReleased() {}
  void mouseMoved() {}
  void mouseWheel(MouseEvent event) {}
  void keyPressed() {}
}

class ScreenManager {
  Screen currentScreen;

  ScreenManager() {
  }
  
  void switchScreen(Screen screen) {
    if (screen == null) {
      println("Attempted to switch to a null screen. Switching to MainMenuScreen instead.");
      currentScreen = mainMenuScreen; // Default to a valid screen
    } else {
      println("Switching to screen: " + screen);
      currentScreen = screen;
    }
  }

  
  void drawScreen() {
    if (currentScreen != null) currentScreen.draw();
  }
  
  void handleMousePressed() {
    if (currentScreen != null) currentScreen.mousePressed();
  }
  
  void handleMouseReleased() {
    if (currentScreen != null) currentScreen.mouseReleased();
  }
  
  void handleMouseDragged() {
    if (currentScreen != null) currentScreen.mouseDragged();
  }
  
  void handleMouseWheel(MouseEvent event) {
    if (currentScreen != null) currentScreen.mouseWheel(event);
  }
  
  void handleKeyPressed() {
    if (currentScreen != null) currentScreen.keyPressed();
  }
  
  void handleMouseMoved() {
    if (currentScreen != null) currentScreen.mouseMoved();
  }
}
