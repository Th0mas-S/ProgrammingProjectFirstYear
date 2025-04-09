class BarChartScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  BarChartScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    float marginLeft = 60, marginRight = 30;
    float marginTop = 80, marginBottom = 100;
    HashMap<String, Integer> destCounts = new HashMap<>();
    
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        String dest = row.getString("destination").trim();
        if (!dest.equals("")) {
          destCounts.put(dest, destCounts.getOrDefault(dest, 0) + 1);
        }
      }
    }
    ArrayList<Map.Entry<String, Integer>> destList = new ArrayList<>(destCounts.entrySet());
    Collections.sort(destList, (a, b) -> b.getValue().compareTo(a.getValue()));
    int itemsAvailable = destList.size();
    int itemsToShow = min(5, itemsAvailable);
    destList = new ArrayList<>(destList.subList(0, itemsToShow));
    
    // Sort alphabetically by full airport name (using a lookup if available).
    Collections.sort(destList, (a, b) -> {
      String nameA = airportLookup.getOrDefault(a.getKey(), a.getKey());
      String nameB = airportLookup.getOrDefault(b.getKey(), b.getKey());
      return nameA.compareToIgnoreCase(nameB);
    });
    
    float gap = 10;
    float plotW = w - marginLeft - marginRight;
    float plotH = h - marginTop - marginBottom;
    float barWidth = (plotW - gap*6) / 5.0;
    float plotX = x + marginLeft;
    float plotY = y + marginTop;
    
    // Draw axes.
    stroke(0);
    line(plotX, plotY + plotH, plotX + plotW, plotY + plotH);
    line(plotX, plotY, plotX, plotY + plotH);
    
    if (itemsAvailable < 5) {
      fill(255, 0, 0);
      textAlign(CENTER);
      textSize(18);
      text("Not enough destinations for a full top 5 list.", x + w / 2, y + 20);
    }
    
    int maxCount = 1;
    for (int i = 0; i < itemsToShow; i++) {
      maxCount = max(maxCount, destList.get(i).getValue());
    }
    
    float totalBarWidth = itemsToShow * barWidth + (itemsToShow - 1) * gap;
    float offsetX = (plotW - totalBarWidth) / 2;
    
    for (int i = 0; i < itemsToShow; i++) {
      Map.Entry<String, Integer> entry = destList.get(i);
      String code = entry.getKey();
      String fullLabel = airportLookup.get(code);
      if (fullLabel == null) fullLabel = code;
      int count = entry.getValue();
      
      float barHeight = map(count, 0, maxCount, 0, plotH) * animationProgress;
      float bx = plotX + offsetX + i*(barWidth + gap);
      float by = plotY + plotH - barHeight;
      
      fill(100, 150, 255);
      noStroke();
      rect(bx, by, barWidth, barHeight);
      
      fill(0);
      textSize(18);
      textAlign(CENTER, BOTTOM);
      text(count, bx + barWidth/2, by - 6);
      
      // Break the fullLabel into parts if needed.
      String line1 = fullLabel.contains("(")
          ? fullLabel.substring(0, fullLabel.indexOf("(")).trim()
          : fullLabel;
      String line2 = fullLabel.contains("(")
          ? fullLabel.substring(fullLabel.indexOf("("), fullLabel.indexOf(")") + 1).trim()
          : "";
      String[] labelLines = {line1, line2, code};
      float maxLabelWidth = barWidth + gap*2;
      float fitted = util.getFittedTextSize(labelLines, maxLabelWidth, 26);
      fitted = min(fitted, 24);
      textSize(fitted);
      textAlign(CENTER, TOP);
      for (int j = 0; j < labelLines.length; j++) {
        text(labelLines[j], bx + barWidth/2, plotY + plotH + 6 + j*(fitted + 2));
      }
    }
    
    // Draw Y-axis tick labels.
    textSize(16);
    textAlign(RIGHT, CENTER);
    int yTicks = 5;
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCount);
      float ypos = map(i, 0, yTicks, plotY + plotH, plotY);
      text(nf(round(val), 0), plotX - 8, ypos);
    }
    
    // Add chart titles.
    textAlign(CENTER, BOTTOM);
    textSize(22);
    text("Destination Airports", plotX + plotW/2, y + h);
    
    pushMatrix();
    translate(x + 5, plotY + plotH/2);
    rotate(-HALF_PI);
    textAlign(CENTER, TOP);
    text("Flight Count", 0, 0);
    popMatrix();
    
    textAlign(CENTER, TOP);
    textSize(22);
    text("Top 5 Destination Airports", x + w/2, y - 20);
  }
}
