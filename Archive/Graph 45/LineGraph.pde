
class LineGraphScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  LineGraphScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    // Margins around the plot area
    float marginLeft = 60, marginRight = 30, marginTop = 80, marginBottom = 50;
    
    // Compute the plotting region
    float plotX = x + marginLeft;
    float plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight;
    float plotH = h - marginTop - marginBottom;
    
    // Build hourly counts from data
    int[] hourCounts = new int[24];
    int maxCount = 1;
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        String sched = row.getString("scheduled_departure");
        if (sched != null && sched.length() >= 16) {
          String[] parts = split(sched, ' ');
          if (parts.length == 2) {
            int hr = constrain(parseInt(parts[1].substring(0, 2)), 0, 23);
            hourCounts[hr]++;
            if (hourCounts[hr] > maxCount) {
              maxCount = hourCounts[hr];
            }
          }
        }
      }
    }
    
    // Draw axes
    stroke(0);
    // X-axis
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    // Y-axis
    line(plotX, plotY, plotX, plotY + plotH);
    
    // Y-axis ticks and numeric labels
    textSize(16);
    textAlign(RIGHT, CENTER);
    int yTicks = (maxCount <= 5) ? maxCount : 5;
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCount);
      float ypos = map(i, 0, yTicks, plotY + plotH, plotY);
      // Tick mark
      line(plotX - 5, ypos, plotX, ypos);
      // Numeric label
      text(int(val), plotX - 8, ypos);
    }
    
    // X-axis ticks and numeric labels
    textAlign(CENTER, TOP);
    for (int hr = 0; hr < 24; hr++) {
      float xpos = map(hr, 0, 23, plotX, plotX + plotW);
      line(xpos, plotY + plotH, xpos, plotY + plotH + 5);
      text(nf(hr, 2), xpos, plotY + plotH + 8);
    }
    
    // Extra spacing for the x-axis label
    textSize(20);
    textAlign(CENTER, TOP);
    text("Hour of Day", plotX + plotW / 2, plotY + plotH + 40);
    
    // Draw the y-axis label (rotated), moved farther left.
    pushMatrix();
      translate(x, y + h / 2);  // increased x-offset from 15 to 30
      rotate(-HALF_PI);
      textAlign(CENTER, CENTER);
      textSize(18);
      text("Number of Flights", 0, 0);
    popMatrix();
    
    // Determine how many data points to show based on animation progress
    int visiblePoints = int(24 * animationProgress);
    visiblePoints = max(1, visiblePoints);
    
    // Compute x,y coordinates for each visible data point
    float[] xPoints = new float[visiblePoints];
    float[] yPoints = new float[visiblePoints];
    for (int i = 0; i < visiblePoints; i++) {
      xPoints[i] = map(i, 0, 23, plotX, plotX + plotW);
      yPoints[i] = map(hourCounts[i], 0, maxCount, plotY + plotH, plotY);
    }
    
    // Draw the two-tone fill under the line
    noStroke();
    for (int i = 0; i < visiblePoints - 1; i++) {
      // Alternate fill colors
      fill((i % 2 == 0) ? color(160, 190, 255) : color(100, 150, 255));
      beginShape();
        vertex(xPoints[i],   yPoints[i]);
        vertex(xPoints[i+1], yPoints[i+1]);
        vertex(xPoints[i+1], plotY + plotH);
        vertex(xPoints[i],   plotY + plotH);
      endShape(CLOSE);
    }
    
    // Draw the line on top
    noFill();
    stroke(0, 0, 255);
    strokeWeight(2);
    beginShape();
      for (int i = 0; i < visiblePoints; i++) {
        vertex(xPoints[i], yPoints[i]);
      }
    endShape();
    
    // Draw the data points with numeric labels.
    textSize(14);
    textAlign(CENTER, BOTTOM);
    for (int i = 0; i < visiblePoints; i++) {
      fill(0, 0, 255);
      noStroke();
      ellipse(xPoints[i], yPoints[i], 6, 6);
      fill(0);
      textSize(14); // Ensure text size is explicitly set for each point.
      if (i == 0) {
        text(hourCounts[i], xPoints[i] + 15, yPoints[i] - 8);
      } else {
        text(hourCounts[i], xPoints[i], yPoints[i] - 8);
      }
    }
    
    // Graph Title at the top
    textAlign(CENTER, TOP);
    textSize(24);
    text("Hourly Flight Counts", x + w / 2, y);
  }
}
