//==================================================
// GraphScreen class: shows the graph for a selected airport.
class GraphScreen {
  String airport;
  ProccessData data;
  
  GraphScreen(String airport, ProccessData data) {
    this.airport = airport;
    this.data = data;
  }
  
  void display() {
    // Draw a simple back button at the top-left.
    fill(150);
    rect(10, 10, 80, 30, 5);
    fill(0);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Back", 10 + 40, 10 + 15);
    
    // Title
    fill(0);
    textSize(20);
    textAlign(CENTER);
    text("Flight Data for " + airport, width/2, 40);
    
    // Draw the pie chart (graph)
    float chartX = width/2;
    float chartY = height/2 + 20;
    int chartSize = 300;
    
    if(data.totalFlights == 0) {
      fill(255, 0, 0);
      text("No flight data found for " + airport, width/2, height/2);
      return;
    }
    
    float onTimeAngle = map(data.departedOnTime, 0, data.totalFlights, 0, TWO_PI);
    float delayedAngle = map(data.delayedFlights, 0, data.totalFlights, 0, TWO_PI);
    float cancelledAngle = map(data.cancelledFlights, 0, data.totalFlights, 0, TWO_PI);
    
    float lastAngle = 0;
    // On-time: green
    fill(0, 255, 0);
    arc(chartX, chartY, chartSize, chartSize, lastAngle, lastAngle + onTimeAngle);
    lastAngle += onTimeAngle;
    // Delayed: yellow
    fill(255, 255, 0);
    arc(chartX, chartY, chartSize, chartSize, lastAngle, lastAngle + delayedAngle);
    lastAngle += delayedAngle;
    // Cancelled: red
    fill(255, 0, 0);
    arc(chartX, chartY, chartSize, chartSize, lastAngle, lastAngle + cancelledAngle);
    
    // Display data counts below the chart.
    fill(0);
    textSize(16);
    text("Total Flights: " + data.totalFlights, chartX, chartY + chartSize/2 + 20);
    text("On Time: " + data.departedOnTime, chartX, chartY + chartSize/2 + 40);
    text("Delayed: " + data.delayedFlights, chartX, chartY + chartSize/2 + 60);
    text("Cancelled: " + data.cancelledFlights, chartX, chartY + chartSize/2 + 80);
  }
}
