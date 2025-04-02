import processing.data.Table;
import processing.data.TableRow;

// Global variables
int screenMode = 0; // 0 = selection screen, 1 = graph screen
AirportSelector airportSelector;
GraphScreen graphScreen;
ProccessData processData; // Our data processor

// Sample airport list (extend as needed)
String[] airports = {
  "LAX", "SEA", "SFO", "ATL", "JFK", 
  "ORD", "DFW", "DEN", "MIA", "BOS",
  "PHX", "CLT", "LAS", "PHL", "IAH"
};

void setup() {
  size(800, 600);
  textFont(createFont("Comic Sans MS", 20));
  
  // Create the airport selection screen with the list and slider.
  airportSelector = new AirportSelector(airports);
  // Load the CSV data once.
  processData = new ProccessData("flight_data_2017.csv");
}

void draw() {
  background(255);
  
  if(screenMode == 0) {
    airportSelector.display();
  } else if(screenMode == 1) {
    graphScreen.display();
  }
}

void mousePressed() {
  if(screenMode == 0) {
    // Check if an airport was clicked.
    String selected = airportSelector.handleMousePressed();
    // Also check for slider clicks.
    airportSelector.mousePressed();
    if(selected != null) {
      // Process data for the selected airport and switch screens.
      processData.process(selected);
      graphScreen = new GraphScreen(selected, processData);
      screenMode = 1;
    }
  } else if(screenMode == 1) {
    // A simple back button in the graph screen (top-left corner).
    if(mouseX > 10 && mouseX < 90 && mouseY > 10 && mouseY < 40) {
      screenMode = 0;
    }
  }
}

void mouseDragged() {
  if(screenMode == 0) {
    airportSelector.mouseDragged();
  }
}

void mouseReleased() {
  if(screenMode == 0) {
    airportSelector.mouseReleased();
  }
}
