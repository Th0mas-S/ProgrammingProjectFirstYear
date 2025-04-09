class BubbleChartScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  BubbleChartScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    int[] counts = new int[24];
    int[] sumDelays = new int[24];
    
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        if (row.getString("cancelled").equalsIgnoreCase("true")) continue;
        String sched = row.getString("scheduled_departure");
        if (sched != null && sched.length() >= 13) {
          int hr = parseInt(sched.substring(11, 13));
          hr = constrain(hr, 0, 23);
          int d = row.getInt("minutes_late");
          if (d < 0) d = 0;
          counts[hr]++;
          sumDelays[hr] += d;
        }
      }
    }
    
    float[] avgDelay = new float[24];
    float maxDelay = 1;
    int maxCount = 0;
    for (int hr = 0; hr < 24; hr++) {
      if (counts[hr] > 0) {
        avgDelay[hr] = sumDelays[hr] / (float) counts[hr];
        maxDelay = max(maxDelay, avgDelay[hr]);
      }
      maxCount = max(maxCount, counts[hr]);
    }
    
    float marginLeft = 60, marginRight = 50, marginTop = 100, marginBottom = 70;
    float plotX = x + marginLeft, plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight, plotH = h - marginTop - marginBottom;
    
    // Draw axes.
    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    line(plotX, plotY, plotX, plotY + plotH);
    
    // X-axis labels.
    textSize(14);
    textAlign(CENTER, TOP);
    for (int hr = 0; hr <= 23; hr++) {
      float xx = map(hr, 0, 23, plotX, plotX + plotW);
      line(xx, plotY + plotH, xx, plotY + plotH + 5);
      text(hr, xx, plotY + plotH + 8);
    }
    
    // Y-axis ticks.
    int yTicks = 5;
    textAlign(RIGHT, CENTER);
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxDelay);
      float yy = map(i, 0, yTicks, plotY + plotH, plotY);
      line(plotX - 5, yy, plotX, yy);
      text(int(val), plotX - 8, yy);
    }
    
    // Titles.
    textAlign(CENTER, TOP);
    textSize(22);
    text("Bubble Chart: Hour vs. Avg Delay vs. Flight Count", x + w/2, y);
    textAlign(CENTER, BOTTOM);
    textSize(16);
    text("Scheduled Departure Hour", plotX + plotW/2, y + h - 5);
    pushMatrix();
    translate(x + 20, plotY + plotH/2);
    rotate(-HALF_PI);
    text("Avg Delay (minutes)", 0, 0);
    popMatrix();
    
    // Draw bubbles.
    noStroke();
    fill(100, 150, 255, 180);
    float maxBubbleRadius = 40;
    for (int hr = 0; hr < 24; hr++) {
      if (counts[hr] == 0) continue;
      float xx = map(hr, 0, 23, plotX, plotX + plotW);
      float yy = map(avgDelay[hr], 0, maxDelay, plotY + plotH, plotY);
      float bubbleR = map(counts[hr], 0, maxCount, 0, maxBubbleRadius) * animationProgress;
      ellipse(xx, yy, bubbleR * 2, bubbleR * 2);
      
      fill(0);
      textAlign(CENTER, CENTER);
      text(counts[hr], xx, yy);
      fill(100, 150, 255, 180);
    }
  }
}
