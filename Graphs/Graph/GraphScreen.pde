//-------------------------------------------------
// GraphScreen class
//-------------------------------------------------
class GraphScreen {
  String airport;
  ProcessData data;
  String selectedDate;
  CalendarDisplay calendar;

  GraphScreen(String airport, ProcessData data) {
    this.airport = airport;
    this.data = data;
    calendar = new CalendarDisplay();
    selectedDate = calendar.getSelectedDate();
    println("Initial date set to: " + selectedDate);
  }


  // Overview: Show header overlays, graphs, calendar, and hover effects.
  void displayOverview() {
    // Draw Back Button using common helper function
    drawBackButtonInternal(height * 0.06); // Pass an arbitrary Y for positioning near top

    // Main Title
    String fullAirportName = airportNamesMap.getOrDefault(airport, airport);
    fill(0);
    textSize(26);
    textAlign(CENTER, TOP);
    float titleY = height * 0.02; // Position title
    text("Flight Data Overview for " + fullAirportName, width/2, titleY);

    // Draw each graph in its quadrant (overview mode: isDetailView = false)
    drawFlightTrafficChart(q1x, q1y, q1w, q1h, false);
    drawDestinationDistribution(q2x, q2y, q2w, q2h, false);
    drawDelayDistribution(q3x, q3y, q3w, q3h, false);
    drawCancellationsDiversionsChart(q4x, q4y, q4w, q4h, false);

    // *** REQUIREMENT #5: Draw hover highlights AFTER graphs ***
    noFill();
    strokeWeight(3);
    // Q1 Hover Check
    if (mouseX > q1x && mouseX < q1x + q1w && mouseY > q1y && mouseY < q1y + q1h) {
        stroke(100, 150, 255); // Blue highlight
        rect(q1x, q1y, q1w, q1h);
    }
    // Q2 Hover Check
    if (mouseX > q2x && mouseX < q2x + q2w && mouseY > q2y && mouseY < q2y + q2h) {
        stroke(100, 150, 255); // Blue highlight
        rect(q2x, q2y, q2w, q2h);
    }
    // Q3 Hover Check
    if (mouseX > q3x && mouseX < q3x + q3w && mouseY > q3y && mouseY < q3y + q3h) {
        stroke(100, 150, 255); // Blue highlight
        rect(q3x, q3y, q3w, q3h);
    }
    // Q4 Hover Check
    if (mouseX > q4x && mouseX < q4x + q4w && mouseY > q4y && mouseY < q4y + q4h) {
        stroke(100, 150, 255); // Blue highlight
        rect(q4x, q4y, q4w, q4h);
    }
    noStroke(); // Reset stroke

    // Hint text
    fill(100);
    textSize(18);
    textAlign(CENTER, CENTER);
    text("Click on a graph for details", width/2, height - 30);

    // *** REQUIREMENT #4: Draw calendar ONLY in overview ***
    calendar.setPosition(width - calendar.w - 20, titleY + 10); // Position near top right, below title space
    calendar.display();
  }

  // Detailed view: common setup, graph call, NO calendar.
  void displayTrafficDetail() {
    String fullAirportName = airportNamesMap.getOrDefault(airport, airport);
    drawGraphHeader(width*0.05, height*0.02, width*0.9,
                    "Hourly Flight Traffic - " + fullAirportName + " on " + selectedDate);
    float chartY = height * 0.12;
    float chartH = height * 0.80;
    drawFlightTrafficChart(width*0.05, chartY, width*0.9, chartH, true);
    // *** REQUIREMENT #4: No calendar.display() here ***
  }

  void displayDestinationDetail() {
    String fullAirportName = airportNamesMap.getOrDefault(airport, airport);
    drawGraphHeader(width*0.05, height*0.02, width*0.9,
                    "Top Destination Distribution - " + fullAirportName + " on " + selectedDate);
    float chartY = height * 0.12;
    float chartH = height * 0.80;
    drawDestinationDistribution(width*0.05, chartY, width*0.9, chartH, true);
     // *** REQUIREMENT #4: No calendar.display() here ***
  }

  void displayDelayDistributionDetail() {
    String fullAirportName = airportNamesMap.getOrDefault(airport, airport);
    drawGraphHeader(width*0.05, height*0.02, width*0.9,
                    "Departure Delay Distribution - " + fullAirportName + " on " + selectedDate);
    float chartY = height * 0.12;
    float chartH = height * 0.80;
    drawDelayDistribution(width*0.05, chartY, width*0.9, chartH, true);
      // *** REQUIREMENT #4: No calendar.display() here ***
  }

  void displayCancellationDetail() {
    String fullAirportName = airportNamesMap.getOrDefault(airport, airport);
    drawGraphHeader(width*0.05, height*0.02, width*0.9,
                    "Flight Status - " + fullAirportName + " on " + selectedDate);
    float chartY = height * 0.12;
    float chartH = height * 0.80;
    drawCancellationsDiversionsChart(width*0.05, chartY, width*0.9, chartH, true);
     // *** REQUIREMENT #4: No calendar.display() here ***
  }


 // --- Individual Graph Drawing Functions ---

 // Graph 1: Flight Traffic Over Time (Line Chart)
 void drawFlightTrafficChart(float x, float y, float w, float h, boolean isDetailView) {
    String fullAirportName = airportNamesMap.getOrDefault(airport, airport);

    // 1. Data Preparation
    int[] hourCounts = new int[24];
    int maxCount = 0, totalFlights = 0;
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        String origin = row.getString("origin");
        if (origin == null || !origin.equalsIgnoreCase(airport)) continue;

        String sched = row.getString("scheduled_departure");
        if (sched != null && sched.length() >= 13 && sched.startsWith(selectedDate)) {
          totalFlights++;
          try {
            int hr = Integer.parseInt(sched.substring(11, 13));
            if (hr >= 0 && hr < 24) {
              hourCounts[hr]++;
            }
          } catch(Exception e) { /* Ignore parse errors */ }
        }
      }
      for (int count : hourCounts) {
        if (count > maxCount) maxCount = count;
      }
    }
    maxCount = max(maxCount, 1);

    // 2. Background and Header
    if (!isDetailView) {
      fill(245, 245, 250);
      noStroke();
      rect(x, y, w, h);
      drawGraphHeaderDesc(x, y, w, "Hourly Flight Traffic", "Departures per hour on " + selectedDate);
    } else {
      fill(255);
      noStroke();
      rect(x, y, w, h);
    }

    // 3. Define Chart Area
    float marginLeft = x + w * 0.08;
    float marginRight = x + w * 0.95;
    float marginTop = y + h * (isDetailView ? 0.10 : 0.18);
    float marginBottom = y + h * (isDetailView ? 0.85 : 0.90);
    float chartWidth = marginRight - marginLeft;
    float chartHeight = marginBottom - marginTop;

    // Handle no data
    if (totalFlights == 0) {
      fill(100);
      textSize(isDetailView ? 18 : 14);
      textAlign(CENTER, CENTER);
      text("No flight data for " + airport + " on " + selectedDate, x + w/2, y + h/2);
      return;
    }

    // 4. Draw Axes
    stroke(150);
    strokeWeight(1);
    line(marginLeft, marginBottom, marginRight, marginBottom); // X-axis line
    line(marginLeft, marginBottom, marginLeft, marginTop);     // Y-axis line

    // 5. Draw Axis Labels and Ticks (Detailed View Only)
    if (isDetailView) {
      fill(0);
      textSize(max(10, w * 0.018));

      // X-Axis Labels
      textAlign(CENTER, TOP);
      for (int hr = 0; hr < 24; hr += 2) {
        float xpos = map(hr, 0, 23.5, marginLeft, marginRight);
         line(xpos, marginBottom, xpos, marginBottom + 5); // Tick marks
        text(nf(hr,2), xpos, marginBottom + 8);
      }
      textSize(max(12, w * 0.02));
      text("Hour of Day (Scheduled Departure)", marginLeft + chartWidth / 2, marginBottom + 30);

      // Y-Axis Labels
      textAlign(RIGHT, CENTER);
      int yLabelCount = max(2, min(6, (int)(chartHeight / 30)));
      float yStep = (float)maxCount / yLabelCount; // *** Variable defined here ***
      yStep = max(1, yStep); // Ensure step is at least 1

      for (int i = 0; i <= yLabelCount; i++) {
         float val = i * yStep;
         // *** CORRECTED: Use yStep here ***
         // Avoid drawing label for 0 if maxCount is > 0 and yStep is small enough that 0 and first step labels would overlap
         if (i == 0 && maxCount > 0 && (map(0, 0, maxCount, marginBottom, marginTop) - map(yStep, 0, maxCount, marginBottom, marginTop) < 15)) continue;

        float ypos = map(val, 0, maxCount, marginBottom, marginTop);
         if (ypos >= marginTop -1 && ypos <= marginBottom + 1) { // Allow slight overdraw for rounding
             line(marginLeft - 5, ypos, marginLeft, ypos); // Tick marks
             text(nf(round(val),0), marginLeft - 8, ypos);
         }
      }
       textSize(max(12, w * 0.02));
      // Y-axis title rotated
      pushMatrix();
      translate(x + w * 0.03, marginTop + chartHeight / 2);
      rotate(-HALF_PI);
      textAlign(CENTER, BOTTOM);
      text("Number of Flights", 0, 0);
      popMatrix();
    }

    // 6. Draw Data
    noFill();
    stroke(50,100,200);
    strokeWeight(isDetailView ? 2 : 1.5);
    beginShape();
    for (int hr = 0; hr < 24; hr++) {
      float xpos = map(hr, 0, 23, marginLeft, marginRight);
      float ypos = map(hourCounts[hr], 0, maxCount, marginBottom, marginTop);
      vertex(xpos, ypos);
    }
    endShape();

    // Draw points
    fill(50,100,200);
    noStroke();
    float pointSize = isDetailView? w * 0.008 : w * 0.01;
    for (int hr = 0; hr < 24; hr++) {
      float xpos = map(hr, 0, 23, marginLeft, marginRight);
      float ypos = map(hourCounts[hr], 0, maxCount, marginBottom, marginTop);
      ellipse(xpos, ypos, pointSize, pointSize);
    }
    strokeWeight(1);
  }


  // Graph 2: Destination Distribution (Bar Chart)
 void drawDestinationDistribution(float x, float y, float w, float h, boolean isDetailView) {
    String fullAirportName = airportNamesMap.getOrDefault(airport, airport);

    // 1. Data Preparation
    HashMap<String, Integer> destCounts = new HashMap<String, Integer>();
    int totalDestFlights = 0;
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
         String origin = row.getString("origin");
         if (origin == null || !origin.equalsIgnoreCase(airport)) continue;

         String sched = row.getString("scheduled_departure");
         if (sched != null && sched.startsWith(selectedDate)) {
             String dest = row.getString("destination");
             if (dest != null) {
                 dest = dest.trim();
                 if (!dest.isEmpty()) {
                     totalDestFlights++;
                     destCounts.put(dest, destCounts.getOrDefault(dest, 0) + 1);
                 }
             }
         }
      }
    }
    // Sort
    ArrayList<Map.Entry<String, Integer>> sortedList = new ArrayList<>(destCounts.entrySet());
    sortedList.sort((a, b) -> b.getValue().compareTo(a.getValue()));

    // Limit items
    int itemsToShow = isDetailView ? 10 : 5;
    itemsToShow = min(itemsToShow, sortedList.size());
    if (itemsToShow < sortedList.size()) {
        sortedList = new ArrayList<>(sortedList.subList(0, itemsToShow));
    }
    int maxCount = sortedList.isEmpty() ? 1 : sortedList.get(0).getValue();

    // 2. Background and Header
    if (!isDetailView) {
      fill(245, 245, 250);
      noStroke();
      rect(x, y, w, h);
      drawGraphHeaderDesc(x, y, w, "Top Destination Distribution", "Top " + itemsToShow + " destinations on " + selectedDate);
    } else {
      fill(255);
      noStroke();
      rect(x, y, w, h);
    }

    // 3. Define Chart Area
    float marginLeft = x + w * 0.12;
    float marginRight = x + w * 0.95;
    float marginTop = y + h * (isDetailView ? 0.10 : 0.18);
    float marginBottom = y + h * (isDetailView ? 0.85 : 0.90); // Extra space for potentially rotated labels
    float chartWidth = marginRight - marginLeft;
    float chartHeight = marginBottom - marginTop;

     // Handle no data
     if (totalDestFlights == 0 || sortedList.isEmpty()) {
        fill(100);
        textSize(isDetailView ? 18 : 14);
        textAlign(CENTER, CENTER);
        text("No destination data for " + airport + " on " + selectedDate, x + w/2, y + h/2);
        return;
     }

    // 4. Draw Axes
    stroke(150);
    strokeWeight(1);
    line(marginLeft, marginBottom, marginRight, marginBottom); // X-axis line
    line(marginLeft, marginBottom, marginLeft, marginTop);     // Y-axis line


    // 5. Draw Axis Labels and Ticks (Detailed View Only)
    if (isDetailView) {
      fill(0);
      // Y-Axis Labels
      textAlign(RIGHT, CENTER);
       textSize(max(10, w * 0.018));
       int yLabelCount = max(2, min(5, (int)(chartHeight / 30)));
       float suggestedStep = max(1, (float)maxCount / yLabelCount);
       float magnitude = pow(10, floor(log(suggestedStep) / log(10.0)));
       float residual = suggestedStep / magnitude;
       float step = (residual > 5) ? 10 * magnitude : (residual > 2) ? 5 * magnitude : (residual > 1) ? 2 * magnitude : max(1, magnitude);
       step = max(1, step);
       int adjustedMax = max(1, (int)(ceil(maxCount / step) * step));
       maxCount = adjustedMax; // Update maxCount for scaling bars

      for (float val = 0; val <= maxCount; val += step) {
        float ypos = map(val, 0, maxCount, marginBottom, marginTop);
         if (ypos >= marginTop - 1 && ypos <= marginBottom + 1) {
            line(marginLeft - 5, ypos, marginLeft, ypos);
            text(nf((int)val, 0), marginLeft - 8, ypos);
         }
      }
       textSize(max(12, w * 0.02));
      // Y-axis title
      pushMatrix();
      translate(x + w * 0.03, marginTop + chartHeight / 2);
      rotate(-HALF_PI);
      textAlign(CENTER, BOTTOM);
      text("Number of Flights", 0, 0);
      popMatrix();

      // X-Axis Labels (Destination Names)
      // *** REQUIREMENT #1: Use Airport Names ***
       textAlign(CENTER, TOP);
       textSize(max(9, w * 0.015)); // Slightly smaller for potentially long names
       float totalBarAreaWidth = chartWidth;
       float barSpacingRatio = 0.2;
       float totalBarWidth = totalBarAreaWidth / (itemsToShow * (1 + barSpacingRatio));
       float barWidth = totalBarWidth;
       float barMargin = totalBarWidth * barSpacingRatio;
       boolean rotateLabels = itemsToShow > 5 || chartWidth / itemsToShow < 80; // Rotate if many bars or narrow space

       for (int i = 0; i < itemsToShow; i++) {
           Map.Entry<String, Integer> entry = sortedList.get(i);
           String destCode = entry.getKey();
           String destName = airportNamesMap.getOrDefault(destCode, destCode); // Get name, fallback to code

           float labelX = marginLeft + i * (barWidth + barMargin) + barMargin / 2 + barWidth / 2; // Center under bar

           pushMatrix();
           translate(labelX, marginBottom + 5);
           if (rotateLabels) { // Rotate if needed
               rotate(PI/4);
               textAlign(LEFT, TOP); // Align differently when rotated
           } else {
              textAlign(CENTER, TOP);
           }
           text(destName, 0, 0); // Display airport name
           popMatrix();
       }
        textSize(max(12, w * 0.02));
        textAlign(CENTER, TOP);
        // Adjust Y position of axis title based on whether labels were rotated
        text("Destination Airport", marginLeft + chartWidth / 2, marginBottom + (rotateLabels ? 65 : 30));
    }

    // 6. Draw Bars
    noStroke();
    float totalBarAreaWidth = chartWidth; // Recalculate for drawing
    float barSpacingRatio = 0.2;
    float totalBarWidth = totalBarAreaWidth / (itemsToShow * (1 + barSpacingRatio));
    float barWidth = totalBarWidth;
    float barMargin = totalBarWidth * barSpacingRatio;


    for (int i = 0; i < itemsToShow; i++) {
      Map.Entry<String, Integer> entry = sortedList.get(i);
      float barHeightValue = entry.getValue();
      float barHeightPixels = map(barHeightValue, 0, maxCount, 0, chartHeight);
       if (barHeightValue > 0 && barHeightPixels < 1) {
           barHeightPixels = 1;
       }

      float bx = marginLeft + i * (barWidth + barMargin) + barMargin / 2;
      float by = marginBottom - barHeightPixels;

      fill(100 + i*(100/itemsToShow), 200 - i*(80/itemsToShow), 150);
      rect(bx, by, barWidth, barHeightPixels);

      // Optional: Draw value label on top of bar in detail view
      if (isDetailView && barHeightPixels > 15) { // Only if bar is tall enough for label inside
          fill(0);
          textSize(max(9, w * 0.015));
          textAlign(CENTER, BOTTOM);
          text(entry.getValue(), bx + barWidth/2, by - 2);
      } else if (isDetailView && barHeightValue > 0) { // If bar too short, draw label above bar
          fill(0);
           textSize(max(9, w * 0.015));
           textAlign(CENTER, BOTTOM);
           text(entry.getValue(), bx + barWidth/2, by - 2);
      }
    }
 }


 // Graph 3: Delay Distribution Histogram
 void drawDelayDistribution(float x, float y, float w, float h, boolean isDetailView) {
    String fullAirportName = airportNamesMap.getOrDefault(airport, airport);

    // 1. Data Preparation
    String[] delayLabels = {"0-5", "6-15", "16-30", "31-60", ">60 min"};
    int[] delayCounts = new int[delayLabels.length];
    int totalRelevantFlights = 0;
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
         String origin = row.getString("origin");
         if (origin == null || !origin.equalsIgnoreCase(airport)) continue;

         String sched = row.getString("scheduled_departure");
         if (sched == null || !sched.startsWith(selectedDate)) continue;

        // Skip cancelled or diverted
        String cancelledStr = row.getString("cancelled");
        String divertedStr = row.getString("diverted");
        boolean isCancelled = (cancelledStr != null && (cancelledStr.trim().equalsIgnoreCase("true") || cancelledStr.trim().equals("1")));
        boolean isDiverted = (divertedStr != null && (divertedStr.trim().equalsIgnoreCase("true") || divertedStr.trim().equals("1")));
        if (isCancelled || isDiverted) continue;

        // Process delay
        int delay = 0;
        try {
           delay = row.getInt("minutes_late");
        } catch(Exception e) { delay = 0; } // Treat errors/missing as 0

        totalRelevantFlights++;

        // Categorize delay
        if (delay <= 5) delayCounts[0]++;
        else if (delay <= 15) delayCounts[1]++;
        else if (delay <= 30) delayCounts[2]++;
        else if (delay <= 60) delayCounts[3]++;
        else delayCounts[4]++;
      }
    }
    // Find max count
    int maxCount = 0;
    for (int count : delayCounts) {
      if (count > maxCount) maxCount = count;
    }
    maxCount = max(maxCount, 1); // Ensure at least 1

    // 2. Background and Header
    if (!isDetailView) {
      fill(245, 245, 250);
      noStroke();
      rect(x, y, w, h);
      drawGraphHeaderDesc(x, y, w, "Departure Delays", "Flights by delay category (minutes) on " + selectedDate);
    } else {
      fill(255);
      noStroke();
      rect(x, y, w, h);
    }

    // 3. Define Chart Area
    float marginLeft = x + w * 0.12;
    float marginRight = x + w * 0.95;
    float marginTop = y + h * (isDetailView ? 0.10 : 0.18);
    float marginBottom = y + h * (isDetailView ? 0.85 : 0.90);
    float chartWidth = marginRight - marginLeft;
    float chartHeight = marginBottom - marginTop;

     // Handle no data
     if (totalRelevantFlights == 0) {
        fill(100);
        textSize(isDetailView ? 18 : 14);
        textAlign(CENTER, CENTER);
        text("No non-cancelled/diverted flights\nfound for delay analysis on " + selectedDate, x + w/2, y + h/2);
        return;
     }

    // 4. Draw Axes
    stroke(150);
    strokeWeight(1);
    line(marginLeft, marginBottom, marginRight, marginBottom); // X-axis line
    line(marginLeft, marginBottom, marginLeft, marginTop);     // Y-axis line

    // 5. Draw Axis Labels and Ticks (Detailed View Only)
    if (isDetailView) {
      fill(0);
      textSize(max(10, w * 0.018));

      // Y-Axis Labels
      textAlign(RIGHT, CENTER);
       int yLabelCount = max(2, min(5, (int)(chartHeight / 30)));
       float suggestedStep = max(1, (float)maxCount / yLabelCount);
       float magnitude = pow(10, floor(log(suggestedStep) / log(10.0)));
       float residual = suggestedStep / magnitude;
       float step = (residual > 5) ? 10 * magnitude : (residual > 2) ? 5 * magnitude : (residual > 1) ? 2 * magnitude : max(1, magnitude);
       step = max(1, step);
       int adjustedMax = max(1, (int)(ceil(maxCount / step) * step));
       maxCount = adjustedMax; // Update maxCount for scaling

      for (float val = 0; val <= maxCount; val += step) {
        float ypos = map(val, 0, maxCount, marginBottom, marginTop);
         if (ypos >= marginTop - 1 && ypos <= marginBottom + 1) {
            line(marginLeft - 5, ypos, marginLeft, ypos);
            text(nf((int)val,0), marginLeft - 8, ypos);
         }
      }
       textSize(max(12, w * 0.02));
      // Y-axis title
      pushMatrix();
      translate(x + w * 0.03, marginTop + chartHeight / 2);
      rotate(-HALF_PI);
      textAlign(CENTER, BOTTOM);
      text("Number of Flights", 0, 0);
      popMatrix();

      // X-Axis Labels
       textAlign(CENTER, TOP);
       textSize(max(10, w * 0.018));
       float totalBarAreaWidth = chartWidth;
       float barSpacingRatio = 0.1;
       float totalBarWidth = totalBarAreaWidth / (delayLabels.length * (1 + barSpacingRatio));
       float barWidth = totalBarWidth;
       float barMargin = totalBarWidth * barSpacingRatio;

       for (int i = 0; i < delayLabels.length; i++) {
           float labelX = marginLeft + i * (barWidth + barMargin) + barMargin / 2 + barWidth / 2;
           text(delayLabels[i], labelX, marginBottom + 8); // Position label under bar center
       }
       textSize(max(12, w * 0.02));
       text("Delay Category (Minutes)", marginLeft + chartWidth / 2, marginBottom + 30); // Axis title
    }

    // 6. Draw Histogram Bars
    noStroke();
    float totalBarAreaWidth = chartWidth;
    float barSpacingRatio = 0.1;
    float totalBarWidth = totalBarAreaWidth / (delayLabels.length * (1 + barSpacingRatio));
    float barWidth = totalBarWidth;
    float barMargin = totalBarWidth * barSpacingRatio;

    color[] barColors = { color(0, 180, 0), color(255, 220, 0), color(255, 165, 0), color(255, 80, 0), color(200, 0, 0) };

    for (int i = 0; i < delayCounts.length; i++) {
      float barHeightValue = delayCounts[i];
      float barHeightPixels = map(barHeightValue, 0, maxCount, 0, chartHeight);
        if (barHeightValue > 0 && barHeightPixels < 1) {
           barHeightPixels = 1; // Min height
        }
      float bx = marginLeft + i * (barWidth + barMargin) + barMargin / 2;
      float by = marginBottom - barHeightPixels;

      fill(barColors[i]);
      rect(bx, by, barWidth, barHeightPixels);

      // *** REQUIREMENT #2: Draw count label ALWAYS in detail view ***
      if (isDetailView) {
          fill(i > 2 ? 255 : 0); // Contrast text color
          textSize(max(9, w * 0.015));
          textAlign(CENTER, BOTTOM);
          // Draw label slightly above the bar's top edge (by-2), even if bar height is 0
          text(delayCounts[i], bx + barWidth/2, by - 2);
      }
    }
 }


 // Graph 4: Cancellations & Diversions Pie Chart
 void drawCancellationsDiversionsChart(float x, float y, float w, float h, boolean isDetailView) {
    String fullAirportName = airportNamesMap.getOrDefault(airport, airport);

    // 1. Data Preparation
    int cancelledCount = 0, divertedCount = 0, completedCount = 0;
    int totalFlights = 0;
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
         String origin = row.getString("origin");
         if (origin == null || !origin.equalsIgnoreCase(airport)) continue;
         String sched = row.getString("scheduled_departure");
         if (sched == null || !sched.startsWith(selectedDate)) continue;

        totalFlights++; // Count total relevant rows first

        String cancelledStr = row.getString("cancelled");
        String divertedStr = row.getString("diverted");
        boolean isCancelled = (cancelledStr != null && (cancelledStr.trim().equalsIgnoreCase("true") || cancelledStr.trim().equals("1")));
        boolean isDiverted = (divertedStr != null && (divertedStr.trim().equalsIgnoreCase("true") || divertedStr.trim().equals("1")));

        if (isCancelled) cancelledCount++;
        else if (isDiverted) divertedCount++;
        else completedCount++;
      }
    }
    // Ensure counts add up
    totalFlights = completedCount + cancelledCount + divertedCount;

    // 2. Background and Header
    if (!isDetailView) {
      fill(245, 245, 250);
      noStroke();
      rect(x, y, w, h);
      drawGraphHeaderDesc(x, y, w, "Flight Status", "Completed vs Cancelled/Diverted on " + selectedDate);
    } else {
      fill(255);
      noStroke();
      rect(x, y, w, h);
    }

     // 3. Define Chart Area & Layout
     // *** REQUIREMENT #3: Adjust layout for detailed view ***
     float pieCenterX, pieCenterY, pieDiameter;
     float legendX, legendY, legendBoxSize, legendSpacingY, legendTextOffsetX;

     if (isDetailView) {
         // Pie chart on the left
         pieCenterX = x + w * 0.35; // Center X shifted left
         pieCenterY = y + h * 0.5;  // Center Y vertically
         pieDiameter = min(w * 0.5, h * 0.6); // Adjust diameter based on available space

         // Legend on the right
         legendX = pieCenterX + pieDiameter * 0.5 + w * 0.1; // Start legend right of pie + gap
         legendY = pieCenterY - h * 0.2; // Align legend top near pie center Y
         legendBoxSize = max(15, h * 0.025);
         legendSpacingY = legendBoxSize * 1.8;
         legendTextOffsetX = legendBoxSize * 1.5;
     } else {
         // Original overview layout
         pieCenterX = x + w * 0.5;
         pieCenterY = y + h * 0.60; // Lower Y for overview header space
         pieDiameter = min(w * 0.55, h * 0.55);
         // Legend not drawn in overview, but keep variables defined
         legendX=0; legendY=0; legendBoxSize=0; legendSpacingY=0; legendTextOffsetX=0;
     }


     // Handle no data
     if (totalFlights == 0) {
         fill(100);
         textSize(isDetailView ? 18 : 14);
         textAlign(CENTER, CENTER);
         text("No flight status data for " + airport + " on " + selectedDate, x + w/2, y + h/2); // Center text in overall area
         return;
     }

    // 4. Draw Pie Chart Slices
    float lastAngle = -HALF_PI;
    noStroke();
    color completedColor = color(0, 180, 0);
    color cancelledColor = color(220, 0, 0);
    color divertedColor = color(255, 165, 0);

    if (completedCount > 0) {
       fill(completedColor);
       float completedAngle = map(completedCount, 0, totalFlights, 0, TWO_PI);
       arc(pieCenterX, pieCenterY, pieDiameter, pieDiameter, lastAngle, lastAngle + completedAngle);
       lastAngle += completedAngle;
    }
    if (cancelledCount > 0) {
       fill(cancelledColor);
       float cancelledAngle = map(cancelledCount, 0, totalFlights, 0, TWO_PI);
       arc(pieCenterX, pieCenterY, pieDiameter, pieDiameter, lastAngle, lastAngle + cancelledAngle);
       lastAngle += cancelledAngle;
    }
    if (divertedCount > 0) {
       fill(divertedColor);
       float divertedAngle = map(divertedCount, 0, totalFlights, 0, TWO_PI);
       float endAngle = lastAngle + divertedAngle;
       // Use a small tolerance for floating point comparison to close the circle
        if (abs(endAngle - (TWO_PI - HALF_PI)) < 0.01 || abs(endAngle - (-HALF_PI)) < 0.01 && divertedCount+cancelledCount+completedCount == totalFlights) {
             arc(pieCenterX, pieCenterY, pieDiameter, pieDiameter, lastAngle, -HALF_PI + TWO_PI); // End precisely at the start
        } else {
            arc(pieCenterX, pieCenterY, pieDiameter, pieDiameter, lastAngle, endAngle);
        }
    }

    // 5. Draw Legend (Detailed View Only, Right Side)
    // *** REQUIREMENT #3: Legend position updated ***
    if (isDetailView) {
      textSize(max(12, h * 0.025)); // Adjust legend text size
      textAlign(LEFT, CENTER);

      // Completed Legend Item
      fill(completedColor);
      rect(legendX, legendY, legendBoxSize, legendBoxSize);
      fill(0);
      float completedPercent = totalFlights > 0 ? (completedCount / (float)totalFlights) * 100 : 0;
      text("Completed: " + completedCount + " (" + nf(completedPercent,1,1) + "%)", legendX + legendTextOffsetX, legendY + legendBoxSize/2);

      // Cancelled Legend Item
      fill(cancelledColor);
      rect(legendX, legendY + legendSpacingY, legendBoxSize, legendBoxSize);
      fill(0);
      float cancelledPercent = totalFlights > 0 ? (cancelledCount / (float)totalFlights) * 100 : 0;
      text("Cancelled: " + cancelledCount + " (" + nf(cancelledPercent,1,1) + "%)", legendX + legendTextOffsetX, legendY + legendSpacingY + legendBoxSize/2);

      // Diverted Legend Item
      fill(divertedColor);
      rect(legendX, legendY + 2 * legendSpacingY, legendBoxSize, legendBoxSize);
      fill(0);
      float divertedPercent = totalFlights > 0 ? (divertedCount / (float)totalFlights) * 100 : 0;
      text("Diverted: " + divertedCount + " (" + nf(divertedPercent,1,1) + "%)", legendX + legendTextOffsetX, legendY + 2 * legendSpacingY + legendBoxSize/2);
    }
 }

} // End of GraphScreen class
