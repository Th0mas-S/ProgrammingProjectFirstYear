// HistogramScreen.pde
// A class for drawing the histogram (Delay Distribution) screen.

class HistogramScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  HistogramScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    ArrayList<Integer> delays = new ArrayList<Integer>();
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        if (row.getString("cancelled").equalsIgnoreCase("true")) continue;
        int d = row.getInt("minutes_late");
        if (d < 0) d = 0;
        delays.add(d);
      }
    }
    
    if (delays.size() == 0) {
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(30);
      text("No delay data for histogram", x + w/2, y + h/2);
      return;
    }
    
    int maxDelay = 0;
    for (int d : delays) maxDelay = max(maxDelay, d);
    
    int binSize = 10;
    int numBins = ceil(maxDelay / float(binSize)) + 1;
    int[] bins = new int[numBins];
    for (int d : delays) {
      int binIndex = d / binSize;
      binIndex = constrain(binIndex, 0, numBins-1);
      bins[binIndex]++;
    }
    
    int maxCount = 0;
    for (int c : bins) maxCount = max(maxCount, c);
    
    float marginLeft = 60, marginRight = 30, marginTop = 40, marginBottom = 60;
    float plotX = x + marginLeft, plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight, plotH = h - marginTop - marginBottom;
    
    // Draw axes.
    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    line(plotX, plotY, plotX, plotY + plotH);
    
    float barWidth = plotW / numBins;
    textAlign(CENTER, BOTTOM);
    textSize(14);
    for (int i = 0; i < numBins; i++) {
      float barHeight = map(bins[i], 0, maxCount, 0, plotH) * animationProgress;
      float bx = plotX + i * barWidth;
      float by = plotY + plotH - barHeight;
      fill(100, 150, 255);
      noStroke();
      rect(bx, by, barWidth - 1, barHeight);
      fill(0);
      text(bins[i], bx + barWidth/2, by - 2);
    }
    
    // X-axis ticks and labels.
    textAlign(CENTER, TOP);
    for (int i = 0; i <= numBins; i++) {
      float bx = plotX + i * barWidth;
      line(bx, plotY + plotH, bx, plotY + plotH + 5);
      int rangeStart = i * binSize;
      text(rangeStart, bx, plotY + plotH + 8);
    }
    
    // Y-axis ticks.
    int yTicks = 5;
    textAlign(RIGHT, CENTER);
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCount);
      float ty = map(i, 0, yTicks, plotY + plotH, plotY);
      line(plotX - 5, ty, plotX, ty);
      text(int(val), plotX - 8, ty);
    }
    
    // Titles.
    textAlign(CENTER, TOP);
    textSize(22);
    text("Delay Distribution Histogram", x + w/2, y);
    textAlign(CENTER, BOTTOM);
    textSize(16);
    text("Minutes Late (binned)", plotX + plotW/2, y + h - 5);
    pushMatrix();
    translate(x + 15, plotY + plotH/2);
    rotate(-HALF_PI);
    text("Flight Count", 0, 0);
    popMatrix();
  }
}
