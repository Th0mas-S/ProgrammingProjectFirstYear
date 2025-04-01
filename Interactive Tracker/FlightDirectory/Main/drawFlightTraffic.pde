class FlightAnalytics {
  // Class-level variables
  HashMap<String, DelayData> destinations = new HashMap<>();
  HashMap<String, DelayData> airlineDelays = new HashMap<>();

  // Nested DelayData class
  class DelayData {
    int total;
    int count;

    DelayData(int total, int count) {
      this.total = total;
      this.count = count;
    }

    double average() {
      return count > 0 ? (double) total / count : 0;
    }
  }

  // Flight traffic line chart
  void drawFlightTraffic(ArrayList<Flight> flights) {
    int[] traffic = new int[24]; // Hours 0-23
    for (Flight f : flights) {
      int hour = Integer.parseInt(f.scheduledDeparture.split(":")[0]);
      if (hour >= 0 && hour < 24) traffic[hour]++;
    }

    // Calculate maxTraffic manually (no Java 8 streams)
    int maxTraffic = 0;
    for (int count : traffic) {
      if (count > maxTraffic) {
        maxTraffic = count;
      }
    }
    if (maxTraffic == 0) maxTraffic = 1;

    // Draw line chart
    fill(0);
    textSize(20);
    text("Flight Traffic Over Time", 50, 100);
    noFill();
    stroke(255);
    rect(50, 150, 600, 300); // Chart area from (50,150) to (650,450)

    // Draw lines
    strokeWeight(2);
    stroke(255, 0, 0);
    for (int i = 0; i < 23; i++) { 
      float x1 = 50 + (i * (600f / 24));
      float x2 = 50 + ((i + 1) * (600f / 24));

      float y1 = 450 - (traffic[i] / (float) maxTraffic) * 280; // Cast to float
      float y2 = 450 - (traffic[i + 1] / (float) maxTraffic) * 280;

      line(x1, y1, x2, y2);
    }
  }

  // Destination distribution bar chart
  void drawDestinationDistribution(ArrayList<Flight> flights) {
    HashMap<String, Integer> destinationsCount = new HashMap<>();
    for (Flight f : flights) {
      String dest = f.destination;
      destinationsCount.put(dest, destinationsCount.getOrDefault(dest, 0) + 1);
    }

    // Sort destinations by count (descending)
    List<Map.Entry<String, Integer>> entries = new ArrayList<>(destinationsCount.entrySet());
    entries.sort((a, b) -> b.getValue().compareTo(a.getValue()));

    // Draw bar chart
    fill(0);
    text("Destination Distribution", 700, 100);
    rect(700, 150, 600, 300);

    int barWidth = 80;
    int x = 720;
    int y = 450;
    for (int i = 0; i < Math.min(entries.size(), 5); i++) {
      Map.Entry<String, Integer> entry = entries.get(i);
      fill(0, 255, 0);
      rect(x, y - entry.getValue() * 2, barWidth, entry.getValue() * 2);
      fill(0);
      text(entry.getKey(), x, y + 20);
      x += barWidth + 20;
    }
  }

  // Average delay per airline bar chart
  void drawAverageDelay(ArrayList<Flight> flights) {
    airlineDelays.clear();
    for (Flight f : flights) {
      String airline = f.airlineCode;
      int delay = f.departureDelay;
      if (!airline.isEmpty()) {
        if (airlineDelays.containsKey(airline)) {
          DelayData data = airlineDelays.get(airline);
          data.total += delay;
          data.count++;
        } else {
          airlineDelays.put(airline, new DelayData(delay, 1));
        }
      }
    }

    // Sort airlines by average delay (descending)
    List<Map.Entry<String, DelayData>> entries = new ArrayList<>(airlineDelays.entrySet());
    entries.sort((a, b) -> Double.compare(b.getValue().average(), a.getValue().average()));

    // Draw bar chart
    fill(0);
    text("Average Delay Per Airline", 50, 500);
    rect(50, 550, 600, 200);

    int x = 80;
    for (int i = 0; i < Math.min(entries.size(), 5); i++) {
      Map.Entry<String, DelayData> entry = entries.get(i);
      DelayData data = entry.getValue();
      double avg = data.average();

      fill(0, 0, 255);
      rect(x, 700 - (float)(avg * 2), 50, (float)(avg * 2));
      fill(0);
      text(entry.getKey() + " (" + avg + "m)", x, 720);
      x += 80;
    }
  }

  // Cancellation/diversion pie chart
void drawCancellationPie(ArrayList<Flight> flights) {
  int canceled = 0, diverted = 0, completed = 0; // ✅ Declare variables first
  for (Flight f : flights) {
    if (f.cancelled) canceled++;
    else if (f.diverted) diverted++;
    else completed++;
    }

    // Handle zero total
    if (flights.isEmpty()) {
      text("No flights selected", 700, 750);
      return;
    }

    float total = canceled + diverted + completed;
    if (total == 0) {
      text("No valid flights", 700, 750);
      return;
    }

    // Calculate angles in degrees
    float angleCanceled = (canceled / total) * 360;
    float angleDiverted = (diverted / total) * 360;
    float angleCompleted = (completed / total) * 360;

    // Draw pie chart
    fill(0);
    text("Cancellations/Diversions", 700, 500);
    rect(700, 550, 300, 300);

    // Draw sectors using radians
    fill(255, 0, 0);
    arc(850, 800, 200, 200, 0, radians(angleCanceled));
    fill(0, 0, 255);
    arc(850, 800, 200, 200, radians(angleCanceled), radians(angleCanceled + angleDiverted));
    fill(0, 255, 0);
    arc(850, 800, 200, 200, 
        radians(angleCanceled + angleDiverted), 
        radians(angleCanceled + angleDiverted + angleCompleted));

    // Labels with formatted percentages
    textFont(createFont("Arial", 14));
    text("Canceled: " + canceled + " (" + String.format("%.1f", (canceled / total)*100) + "%)", 700, 750);
    text("Diverted: " + diverted + " (" + String.format("%.1f", (diverted / total)*100) + "%)", 700, 770);
    text("Completed: " + completed + " (" + String.format("%.1f", (completed / total)*100) + "%)", 700, 790);
  }
}
