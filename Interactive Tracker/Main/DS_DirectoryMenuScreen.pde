class DirectoryMenuScreen extends Screen {
  
  Widget directory, graphs, exitButton;
  int commonWidgetColor = color(128, 128, 128, 50);  // Transparent grey

  DirectoryMenuScreen() {
    directory = new Widget((width/2) - (width/8), height/3, 3, width/4, 200, commonWidgetColor);
    graphs    = new Widget((width/2) - (width/8), int((height/3) * 1.6), 4, width/4, 200, commonWidgetColor);
    exitButton= new Widget((width/2) - (width/8), int((height/3) * 2.2), 5, width/4, 200, commonWidgetColor);
  }
}
