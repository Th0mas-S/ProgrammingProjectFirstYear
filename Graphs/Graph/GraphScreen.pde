//==================================================
// GraphScreen class: handles drawing all graph views.
class GraphScreen {
  String airport;
  ProcessData data;

  GraphScreen(String airport, ProcessData data) {
    this.airport = airport;
    this.data = data;
  }

  void drawBackButton() {
    fill(180);
    rect(10, 10, 80, 30, 5);
    fill(0);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("Back", 50, 25);
  }

  void drawScreenTitle(String title) {
      fill(0);
      textSize(20);
      textAlign(CENTER, TOP);
      text(title, width / 2, 15);
  }

  void displayOverview() {
    drawBackButton();
    drawScreenTitle("Flight Data Overview for " + airport);
    drawFlightTrafficChart(q1x, q1y, q1w, q1h, false);
    drawDestinationDistribution(q2x, q2y, q2w, q2h, false);
    drawAverageDelayPerAirline(q3x, q3y, q3w, q3h, false);
    drawCancellationsDiversionsChart(q4x, q4y, q4w, q4h, false);
    fill(100);
    textSize(12);
    textAlign(CENTER, CENTER);
    text("Click on a graph for details", width / 2, height - 20);
  }

  void displayTrafficDetail() {
    drawBackButton();
    drawScreenTitle("Hourly Flight Traffic for " + airport);
    drawFlightTrafficChart(50, 80, width - 100, height - 130, true);
  }

  void displayDestinationDetail() {
    drawBackButton();
    drawScreenTitle("Top Destination Distribution for " + airport);
    drawDestinationDistribution(50, 80, width - 100, height - 130, true);
  }

  void displayDelayDetail() {
    drawBackButton();
    drawScreenTitle("Average Delay per Airline for " + airport);
    drawAverageDelayPerAirline(50, 80, width - 100, height - 130, true);
  }

  void displayCancellationDetail() {
    drawBackButton();
    drawScreenTitle("Cancellations & Diversions for " + airport);
    drawCancellationsDiversionsChart(50, 80, width - 100, height - 130, true);
  }

  // --- Graph Drawing Methods (Modified slightly for flexibility) ---
  // Added boolean isDetailView to potentially adjust drawing

  // Graph 1: Line Chart – Flight Traffic Over Time (by scheduled hour)
  void drawFlightTrafficChart(float x, float y, float w, float h, boolean isDetailView) {
    // --- Data Calculation --- (Consider moving this outside draw loop)
    int[] hourCounts = new int[24];
    int maxCount = 0;
    int totalFlightsInGraph = 0;
    if (data.table != null) {
        for (TableRow row : data.table.rows()) {
          if (!row.getString("origin").equalsIgnoreCase(airport)) continue;
          totalFlightsInGraph++; // Count flights for this airport
          String sched = row.getString("scheduled_departure");
          try { // Basic error handling for parsing
            if (sched != null && sched.length() >= 16) { // Expect "YYYY-MM-DD HH:MM"
                int hr = Integer.parseInt(sched.substring(11, 13)); // Use Integer.parseInt
                if (hr >= 0 && hr < 24) { // Basic validation
                    hourCounts[hr]++;
                } else {
                    //println("Warning: Invalid hour found in data: " + sched);
                }
            }
          } catch (NumberFormatException e) {
             //println("Warning: Could not parse hour from: " + sched);
          } catch (IndexOutOfBoundsException e) {
             //println("Warning: Date string too short: " + sched);
          }
        }

        for (int count : hourCounts) {
          if (count > maxCount) maxCount = count;
        }
    }
     maxCount = max(maxCount, 1); // Avoid division by zero if no flights

    // --- Drawing ---
    // Draw background box and title (only if not detail view, title drawn separately in detail)
    if (!isDetailView) {
        fill(240);
        rect(x, y, w, h);
        fill(0);
        textSize(14);
        textAlign(CENTER);
        text("Flight Traffic Over Time (Hourly)", x + w / 2, y + 15);
    } else {
         fill(255); // White background for detail view graph area
         noStroke();
         rect(x,y,w,h); // Clear area if needed
    }

    if (totalFlightsInGraph == 0) {
        fill(100);
        textSize(14);
        textAlign(CENTER, CENTER);
        text("No flight data found for " + airport, x + w/2, y + h/2);
        return; // Don't draw axes/graph if no data
    }


    // Draw axes with adjusted margins
    stroke(0);
    strokeWeight(1);
    float marginLeft = x + 40;
    float marginRight = x + w - (isDetailView ? 40 : 20); // More margin right in detail
    float marginTop = y + (isDetailView ? 40 : 30);
    float marginBottom = y + h - (isDetailView ? 50 : 40); // More margin bottom in detail
    line(marginLeft, marginBottom, marginRight, marginBottom); // X-axis
    line(marginLeft, marginBottom, marginLeft, marginTop);      // Y-axis

    // Plot the line chart
    noFill();
    stroke(50, 100, 200);
    strokeWeight(isDetailView ? 2 : 1.5); // Thicker line in detail
    beginShape();
    for (int hr = 0; hr < 24; hr++) {
      float xpos = map(hr, 0, 23, marginLeft, marginRight);
      float ypos = map(hourCounts[hr], 0, maxCount, marginBottom, marginTop);
      vertex(xpos, ypos);
      if (isDetailView) { // Add points in detail view
          fill(50, 100, 200);
          ellipse(xpos, ypos, 5, 5);
          noFill(); // Go back to noFill for the line
      }
    }
    endShape();
    strokeWeight(1); // Reset stroke weight

    // Label axes
    fill(0);
    textSize(isDetailView ? 12 : 10);
    textAlign(CENTER, TOP); // Align labels below x-axis
    for (int hr = 0; hr < 24; hr += (isDetailView ? 2 : 4)) { // More labels in detail
      float xpos = map(hr, 0, 23, marginLeft, marginRight);
      text(nf(hr, 2), xpos, marginBottom + 5);
    }
     text("Hour of Day", x+w/2, marginBottom + (isDetailView? 25:20)); // X-axis label

    textAlign(RIGHT, CENTER); // Align labels left of y-axis
    int yLabelCount = isDetailView ? 6 : 4;
    for (int i = 0; i <= yLabelCount; i++) {
        float val = map(i, 0, yLabelCount, 0, maxCount);
        float ypos = map(i, 0, yLabelCount, marginBottom, marginTop);
        text(nf(round(val),0), marginLeft - 5, ypos);
    }
     // Y-axis Label (rotated) - Requires more effort, skipping for brevity now
     // pushMatrix();
     // translate(x + 15, y + h/2);
     // rotate(-HALF_PI);
     // textAlign(CENTER, CENTER);
     // text("Number of Flights", 0, 0);
     // popMatrix();

  }

  // Graph 2: Bar Chart – Destination Distribution with %
  void drawDestinationDistribution(float x, float y, float w, float h, boolean isDetailView) {
     // --- Data Calculation --- (Consider moving outside draw loop)
     HashMap<String, Integer> destCounts = new HashMap<String, Integer>();
     int totalDestFlights = 0;
     if (data.table != null) {
         for (TableRow row : data.table.rows()) {
           if (!row.getString("origin").equalsIgnoreCase(airport)) continue;
           // Exclude cancelled/diverted? Decide based on requirement. Assuming all scheduled departures count.
           String dest = row.getString("destination").trim();
           if (dest.isEmpty()) continue; // Skip empty destinations
           totalDestFlights++;
           destCounts.put(dest, destCounts.getOrDefault(dest, 0) + 1); // Simpler way to increment
         }
     }

     // Convert to an arraylist and sort by count descending
     ArrayList<Map.Entry<String, Integer>> sortedDestList = new ArrayList<>(destCounts.entrySet());
     // Sort using lambda expression (requires Java 8 features in Processing 4)
     sortedDestList.sort((entry1, entry2) -> entry2.getValue().compareTo(entry1.getValue()));

     int itemsToDisplay = isDetailView ? 10 : 5; // Show more in detail view
     if (sortedDestList.size() > itemsToDisplay) {
        sortedDestList = new ArrayList<>(sortedDestList.subList(0, itemsToDisplay));
     }

     // --- Drawing ---
    if (!isDetailView) {
        fill(240);
        rect(x, y, w, h);
        fill(0);
        textSize(14);
        textAlign(CENTER);
        text("Top " + itemsToDisplay + " Destination Distribution", x + w / 2, y + 15);
    } else {
        fill(255);
        noStroke();
        rect(x,y,w,h);
    }

    if (sortedDestList.isEmpty()) {
        fill(100);
        textSize(14);
        textAlign(CENTER, CENTER);
        text("No destination data found for " + airport, x + w/2, y + h/2);
        return;
    }

     // Draw bar chart
     float barMargin = 10;
     float totalBarWidth = w - 60 - (sortedDestList.size() -1) * barMargin; // Available width for bars
     float barWidth = max(10, totalBarWidth / sortedDestList.size()); // Calculate width, ensure min width

     int maxCount = 0;
     if (!sortedDestList.isEmpty()) {
       maxCount = sortedDestList.get(0).getValue(); // Highest count is first after sorting
     }
     maxCount = max(maxCount, 1);

     float chartBottom = y + h - (isDetailView ? 50 : 40);
     float chartTop = y + (isDetailView ? 40 : 30);
     float chartLeft = x + 40;


     for (int i = 0; i < sortedDestList.size(); i++) {
       Map.Entry<String, Integer> entry = sortedDestList.get(i);
       String dest = entry.getKey();
       int count = entry.getValue();

       float barHeight = map(count, 0, maxCount, 0, chartBottom - chartTop);
       float bx = chartLeft + i * (barWidth + barMargin);
       float by = chartBottom - barHeight;

       fill(100, 200, 150);
       stroke(50); // Add subtle border to bars
       rect(bx, by, barWidth, barHeight);
       noStroke();

       fill(0);
       textSize(isDetailView ? 11 : 9);
       textAlign(CENTER, TOP); // Label below bar
       float percent = (totalDestFlights > 0) ? (count / float(totalDestFlights)) * 100 : 0;
       String label = dest + "\n" + count + " (" + nf(percent, 1, 1) + "%)";
       text(label, bx + barWidth / 2, chartBottom + 5);
     }
      // Add Y-axis scale in detail view? (Similar to traffic chart)
      if (isDetailView) {
            stroke(0);
            line(chartLeft, chartBottom, chartLeft, chartTop); // Y axis line
            fill(0);
            textSize(12);
            textAlign(RIGHT, CENTER);
             int yLabelCount = 5;
            for (int i = 0; i <= yLabelCount; i++) {
                float val = map(i, 0, yLabelCount, 0, maxCount);
                float ypos = map(i, 0, yLabelCount, chartBottom, chartTop);
                text(nf(round(val),0), chartLeft - 5, ypos);
            }
      }
  }

  // Graph 3: Bar Chart – Average Flight Delay Per Airline
  void drawAverageDelayPerAirline(float x, float y, float w, float h, boolean isDetailView) {
      // --- Data Calculation ---
      HashMap<String, float[]> airlineData = new HashMap<String, float[]>();
      // float[0]: total delay minutes, float[1]: count of flights
      int totalFlightsConsidered = 0;
      if (data.table != null) {
          for (TableRow row : data.table.rows()) {
            if (!row.getString("origin").equalsIgnoreCase(airport)) continue;

            // Only consider non-cancelled, non-diverted flights for delay averages
            String cancelled = row.getString("cancelled").toLowerCase().trim();
            String diverted = row.getString("diverted").toLowerCase().trim();
            if (cancelled.equals("true") || cancelled.equals("1") || diverted.equals("true") || diverted.equals("1")) {
                continue;
            }

            String airline = row.getString("airline_name").trim();
             if (airline.isEmpty()) continue; // Skip if no airline name

            int delay = 0;
            try { // Handle potential errors getting delay
                delay = row.getInt("minutes_late");
            } catch (NumberFormatException e) {
                //println("Warning: Could not parse minutes_late for row");
                continue; // Skip row if delay is not a number
            }
            delay = max(0, delay); // Treat early flights as 0 delay for average

            float[] currentData = airlineData.getOrDefault(airline, new float[]{0f, 0f});
            currentData[0] += delay; // Sum of delays
            currentData[1]++;      // Count of flights
            airlineData.put(airline, currentData);
            totalFlightsConsidered++;
          }
      }

      // Calculate averages and store with airline name
       ArrayList<Map.Entry<String, Float>> avgDelayList = new ArrayList<>();
       for (Map.Entry<String, float[]> entry : airlineData.entrySet()) {
           String airline = entry.getKey();
           float[] counts = entry.getValue();
           if (counts[1] > 0) { // Ensure there are flights to average
               float avg = counts[0] / counts[1];
               avgDelayList.add(new java.util.AbstractMap.SimpleEntry<>(airline, avg));
           }
       }

      // Sort by average delay descending
      avgDelayList.sort((e1, e2) -> e2.getValue().compareTo(e1.getValue()));

      int itemsToDisplay = isDetailView ? 15 : 10; // Show more airlines in detail
      if (avgDelayList.size() > itemsToDisplay) {
          avgDelayList = new ArrayList<>(avgDelayList.subList(0, itemsToDisplay));
      }

      // --- Drawing ---
     if (!isDetailView) {
        fill(240);
        rect(x, y, w, h);
        fill(0);
        textSize(14);
        textAlign(CENTER);
        text("Top " + itemsToDisplay + " Airlines by Avg. Delay (Mins)", x + w / 2, y + 15);
     } else {
         fill(255);
         noStroke();
         rect(x,y,w,h);
     }

     if (avgDelayList.isEmpty()) {
        fill(100);
        textSize(14);
        textAlign(CENTER, CENTER);
        text("No valid delay data found for " + airport, x + w/2, y + h/2);
        return;
    }

     // Draw bar chart (horizontal might be better for long airline names, but keeping vertical)
     float barMargin = isDetailView ? 8 : 5;
     float totalBarWidth = w - 60 - (avgDelayList.size() -1) * barMargin;
     float barWidth = max(8, totalBarWidth / avgDelayList.size());

     float maxAvg = 0;
      if (!avgDelayList.isEmpty()) {
          maxAvg = avgDelayList.get(0).getValue(); // Highest avg delay is first
      }
     maxAvg = max(maxAvg, 1); // Ensure maxAvg is at least 1 for mapping

     float chartBottom = y + h - (isDetailView ? 60 : 40); // More space for labels in detail
     float chartTop = y + (isDetailView ? 40 : 30);
     float chartLeft = x + 40;

     for (int i = 0; i < avgDelayList.size(); i++) {
        Map.Entry<String, Float> entry = avgDelayList.get(i);
        String airline = entry.getKey();
        float avg = entry.getValue();

        float barHeight = map(avg, 0, maxAvg, 0, chartBottom - chartTop);
        float bx = chartLeft + i * (barWidth + barMargin);
        float by = chartBottom - barHeight;

        fill(200, 100, 150);
        stroke(50);
        rect(bx, by, barWidth, barHeight);
        noStroke();

        fill(0);
        textSize(isDetailView ? 11 : 9);
        textAlign(CENTER, TOP);

        // Rotate text if detail view and bars are narrow
        if (isDetailView && barWidth < 40) {
            pushMatrix();
            translate(bx + barWidth / 2, chartBottom + 3);
            rotate(HALF_PI / 1.5); // Rotate text ~60 degrees
            textAlign(LEFT, CENTER);
            text(airline + " (" + nf(avg, 0, 1) + ")", 0, 0);
            popMatrix();
        } else {
            text(airline + "\n" + nf(avg, 0, 1), bx + barWidth / 2, chartBottom + 5);
        }
     }
      // Add Y-axis scale in detail view
      if (isDetailView) {
           stroke(0);
           line(chartLeft, chartBottom, chartLeft, chartTop); // Y axis line
           fill(0);
           textSize(12);
           textAlign(RIGHT, CENTER);
           int yLabelCount = 5;
           for (int i = 0; i <= yLabelCount; i++) {
                float val = map(i, 0, yLabelCount, 0, maxAvg);
                float ypos = map(i, 0, yLabelCount, chartBottom, chartTop);
                text(nf(round(val),0) + "m", chartLeft - 5, ypos); // Add 'm' for minutes
           }
      }
  }

  // Graph 4: Pie Chart – Cancellations and Diversions
  void drawCancellationsDiversionsChart(float x, float y, float w, float h, boolean isDetailView) {
    // --- Data Calculation ---
    int cancelledCount = 0;
    int divertedCount = 0;
    int completedCount = 0;
     if (data.table != null) {
        for (TableRow row : data.table.rows()) {
          if (!row.getString("origin").equalsIgnoreCase(airport)) continue;

          String cancelled = row.getString("cancelled").toLowerCase().trim();
          String diverted = row.getString("diverted").toLowerCase().trim();

          if (cancelled.equals("true") || cancelled.equals("1")) {
            cancelledCount++;
          } else if (diverted.equals("true") || diverted.equals("1")) {
            divertedCount++;
          } else {
            completedCount++;
          }
        }
     }
    int total = cancelledCount + divertedCount + completedCount;

    // --- Drawing ---
    if (!isDetailView) {
        fill(240);
        rect(x, y, w, h);
        fill(0);
        textSize(14);
        textAlign(CENTER);
        text("Flight Status (Completed/Cancelled/Diverted)", x + w / 2, y + 15);
    } else {
        fill(255);
        noStroke();
        rect(x,y,w,h);
    }

     if (total == 0) {
        fill(100);
        textSize(14);
        textAlign(CENTER, CENTER);
        text("No status data found for " + airport, x + w/2, y + h/2);
        return;
    }


    float cancelledAngle = map(cancelledCount, 0, total, 0, TWO_PI);
    float divertedAngle = map(divertedCount, 0, total, 0, TWO_PI);
    //float completedAngle = map(completedCount, 0, total, 0, TWO_PI); // Can derive from others
    float completedAngle = TWO_PI - cancelledAngle - divertedAngle; // More robust

    // Draw pie chart
    float cx = x + w / (isDetailView? 3 : 2) ; // Center X (shift left in detail for legend)
    float cy = y + h / 2 + (isDetailView? 0 : 10); // Center Y
    float dia = min(w * (isDetailView? 0.5 : 0.6) , h * (isDetailView? 0.6: 0.5)); // Diameter
    float lastAngle = -HALF_PI; // Start at the top

    noStroke();
    // Completed (Green)
    fill(0, 180, 0); // Darker green
    arc(cx, cy, dia, dia, lastAngle, lastAngle + completedAngle);
    lastAngle += completedAngle;
    // Cancelled (Red)
    fill(220, 0, 0); // Darker Red
    arc(cx, cy, dia, dia, lastAngle, lastAngle + cancelledAngle);
    lastAngle += cancelledAngle;
    // Diverted (Orange)
    fill(255, 165, 0); // Orange
    arc(cx, cy, dia, dia, lastAngle, lastAngle + divertedAngle);


    // Legend
    float legendX = isDetailView ? (x + w / 2 + 20) : (x + 10);
    float legendY = isDetailView ? (cy - 40) : (y + h - 45);
    float legendSpacing = isDetailView ? 25 : 15;
    textSize(isDetailView? 14 : 10);
    textAlign(LEFT, CENTER);

    // Completed
    fill(0, 180, 0);
    rect(legendX, legendY, legendSpacing, legendSpacing); // Color swatch
    fill(0);
    float completedPercent = (total > 0) ? (completedCount / (float)total) * 100 : 0;
    text("Completed: " + completedCount + " (" + nf(completedPercent, 1, 1) + "%)", legendX + legendSpacing + 5, legendY + legendSpacing/2);

    // Cancelled
    fill(220, 0, 0);
    rect(legendX, legendY + legendSpacing + 5, legendSpacing, legendSpacing);
    fill(0);
    float cancelledPercent = (total > 0) ? (cancelledCount / (float)total) * 100 : 0;
    text("Cancelled: " + cancelledCount + " (" + nf(cancelledPercent, 1, 1) + "%)", legendX + legendSpacing + 5, legendY + 1.5f*legendSpacing + 5);

    // Diverted
    fill(255, 165, 0);
    rect(legendX, legendY + 2 * (legendSpacing + 5) , legendSpacing, legendSpacing);
    fill(0);
    float divertedPercent = (total > 0) ? (divertedCount / (float)total) * 100 : 0;
    text("Diverted: " + divertedCount + " (" + nf(divertedPercent, 1, 1) + "%)", legendX + legendSpacing + 5, legendY + 2.5f*legendSpacing + 10);
  }
}
