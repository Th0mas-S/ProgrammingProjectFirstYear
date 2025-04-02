import java.util.Set;
import java.util.HashSet;
import java.util.Collections;

class AirportList {
  ArrayList<String> airportCodes;
  ArrayList<Flight> flights;
  Widget airportBack;
  int screenNum;
  int textSize;
  int sliderLength;


  AirportList(ArrayList<Flight> flights) {
    this.flights = flights;
    this.textSize = int((width - 110) * 0.014);

    // Initialize airport list
    airportCodes = new ArrayList<>();
    Set<String> uniqueAirports = new HashSet<>();

    // Check if flights is initialized
    if (flights != null) {
      for (Flight f : flights) {
        uniqueAirports.add(f.origin);
        uniqueAirports.add(f.destination);
      }
    }

    airportCodes.addAll(uniqueAirports);
    Collections.sort(airportCodes);

    // Back button
    this.airportBack = new Widget(50, height - 100, 2, 100, 50, 0xDD5341); // Fixed color syntax
  }

  void draw() {
    background(0xFACA78);

    stroke(100);
    strokeWeight(3);
    fill(255);
    rect(100, 150, width - 200, height - 250, 15);

    // Calculate visible airports
    int itemHeight = 30;
    int visibleCount = (height - 250) / itemHeight;
    float scrollPos = screen4.slider.getPercent();
    int startIndex = (int) (scrollPos * (airportCodes.size() - visibleCount));

    // Draw airports
    textSize(18);
    fill(0);
    for (int i = 0; i < visibleCount; i++) {
      int index = startIndex + i;
      if (index >= airportCodes.size()) break;

      String code = airportCodes.get(index);
      String name = getAirportName(code); // Renamed for clarity
      float y = 160 + i * itemHeight;

      // Highlight on hover
      if (mouseX > 100 && mouseX < width - 100 && mouseY > y && mouseY < y + itemHeight) {
        fill(200);
        rect(100, y, width - 200, itemHeight);
        fill(0);
      }

      text(code + " - " + name, 120, y + 20);
    }

    textSize(24);
    text("Select Airport", 120, 120);
  }

  void checkAirportClick() {
      // Only process if the left mouse button is pressed and the mouse isn't over the slider.
      if (mouseButton != LEFT || screen4.slider.mouseOver()) {
          return;
      }
    
      int itemHeight = 30;
      float scrollPos = screen4.slider.getPercent();
      int startIndex = (int)(scrollPos * (airportCodes.size() - ((height - 250) / itemHeight)));
      
      for (int i = 0; i < ((height - 250) / itemHeight); i++) {
          int index = startIndex + i;
          if (index >= airportCodes.size()) break;
    
          float y = 160 + i * itemHeight;
          
          // Only trigger if the click falls inside the airport entry area
          if (mouseX > 100 && mouseX < width - 100 && mouseY > y && mouseY < y + itemHeight) {
              String selectedCode = airportCodes.get(index);
              selectAirport(selectedCode);
              break; // Stop processing after a successful selection
          }
      }
  }
}



//  // Dummy method - implement actual lookup
private String getAirportName(String code) {
  return "Airport Name for " + code;
}
//}
