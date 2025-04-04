class DirectoryMenuScreen extends Screen {
  
  Widget directory, graphs, exitButton;

  
  DirectoryMenuScreen() {
     directory = new Widget((width/2)-(width/8), height/3, 3, width/4, 200, #028391);
     graphs = new Widget((width/2)-(width/8), int((height/3)*1.6), 4, width/4, 200, #F9A822);
     exitButton = new Widget((width/2)-(width/8), int((height/3)*2.2), 5, width/4, 200, #F57F5B);
  }
}
