// GroupedBarChartScreen.pde
// A class for drawing the grouped bar chart (Airline Performance) screen.

class GroupedBarChartScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  GroupedBarChartScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    float marginLeft = 120, marginRight = 120;
    float marginTop = 100, marginBottom = 80;
    float plotX = x + marginLeft;
    float plotY = y + marginTop;
    float plotW = w - marginLeft - marginRight;
    float plotH = h - marginTop - marginBottom;
    
    // Gather airline stats from data.
    HashMap<String, float[]> airlineStats = new HashMap<>();
    if (data.table != null) {
      for (TableRow row : data.table.rows()) {
        if (!data.rowMatchesFilter(row, airport)) continue;
        String airline = row.getString("airline_name").trim();
        if (airline.equals("")) airline = "Unknown";
        float[] st = airlineStats.getOrDefault(airline, new float[]{0, 0, 0});
        if (row.getString("cancelled").equalsIgnoreCase("true")) {
          st[2]++;
        } else {
          try {
            int delay = row.getInt("minutes_late");
            if (delay < 0) delay = 0;
            st[0] += delay;
            st[1]++;
          } catch(Exception e) {}
        }
        airlineStats.put(airline, st);
      }
    }
    
    // Sort by number of flights, then by airline name.
    ArrayList<Map.Entry<String, float[]>> list = new ArrayList<>(airlineStats.entrySet());
    Collections.sort(list, (a, b) -> Float.compare(b.getValue()[1], a.getValue()[1]));
    int itemsToShow = min(10, list.size());
    list = new ArrayList<>(list.subList(0, itemsToShow));
    Collections.sort(list, (a, b) -> a.getKey().compareToIgnoreCase(b.getKey()));
    
    // Prepare arrays.
    ArrayList<String> airlines = new ArrayList<>();
    ArrayList<Float> avgDelays = new ArrayList<>();
    ArrayList<Float> cancelRates = new ArrayList<>();
    float maxAvgDelay = 1, maxCancelRate = 1;
    
    for (Map.Entry<String, float[]> e : list) {
      String airline = e.getKey();
      float[] st = e.getValue();
      float avgDelay = (st[1] > 0) ? st[0] / st[1] : 0;
      float cancelRate = (st[1] > 0) ? st[2] / st[1] : 0;
      airlines.add(airline);
      avgDelays.add(avgDelay);
      cancelRates.add(cancelRate);
      if (avgDelay > maxAvgDelay) maxAvgDelay = avgDelay;
      if (cancelRate > maxCancelRate) maxCancelRate = cancelRate;
    }
    
    // Draw left Y-axis (Avg Delay).
    stroke(0);
    line(plotX, plotY, plotX, plotY+plotH);
    textSize(16);
    textAlign(RIGHT, CENTER);
    int yTicks = 5;
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxAvgDelay);
      float ypos = map(i, 0, yTicks, plotY+plotH, plotY);
      line(plotX-5, ypos, plotX, ypos);
      text(nf(val, 0, 1), plotX-10, ypos);
    }
    
    // Add left y-axis label.
    pushMatrix();
    textSize(20);
    translate(plotX - 80, plotY + plotH/2);
    rotate(-HALF_PI);
    textAlign(CENTER, CENTER);
    text("Average Delay (minutes)", 0, 0);
    popMatrix();
    
    // Draw right Y-axis (Cancellation Rate).
    float rightX = plotX + plotW;
    stroke(0);
    line(rightX, plotY, rightX, plotY+plotH);
    textAlign(LEFT, CENTER);
    for (int i = 0; i <= yTicks; i++) {
      float val = map(i, 0, yTicks, 0, maxCancelRate);
      float ypos = map(i, 0, yTicks, plotY+plotH, plotY);
      line(rightX, ypos, rightX+5, ypos);
      text(nf(val*100, 0, 1)+"%", rightX+10, ypos);
    }
    
    // Add right y-axis label.
    pushMatrix();
    textSize(20);
    translate(rightX + 100, plotY + plotH/2);
    rotate(HALF_PI);
    textAlign(CENTER, CENTER);
    text("Cancellation Rate (%)", 0, 0);
    popMatrix();
    
    // Draw X-axis.
    stroke(0);
    line(plotX, plotY+plotH, plotX+plotW, plotY+plotH);
    textAlign(CENTER, TOP);
    
    // Calculate group width and barWidth.
    float groupWidth = plotW / itemsToShow;
    float barWidth = groupWidth / 3;
    
    // We'll draw the grouped bars first, so we can compute their boundaries to restrict text.
    for (int i = 0; i < itemsToShow; i++) {
      float groupX = plotX + i * groupWidth;
      float d = avgDelays.get(i);
      float c = cancelRates.get(i);
      float delayH = map(d, 0, maxAvgDelay, 0, plotH) * animationProgress;
      float cancelH = map(c, 0, maxCancelRate, 0, plotH) * animationProgress;
      
      float bx1 = groupX + groupWidth/2 - barWidth - 4; // left (blue) bar
      float by1 = plotY + plotH - delayH;
      fill(0, 0, 200);
      rect(bx1, by1, barWidth, delayH);
      fill(0);
      textAlign(CENTER, BOTTOM);
      textSize(14);
      text(nf(d, 0, 1), bx1 + barWidth/2, by1 - 2);
      
      float bx2 = groupX + groupWidth/2 + 4; // right (red) bar
      float by2 = plotY + plotH - cancelH;
      fill(200, 0, 0);
      rect(bx2, by2, barWidth, cancelH);
      fill(0);
      text(nf(c*100, 0, 1)+"%", bx2 + barWidth/2, by2 - 2);
    }
    
    // Now draw x-axis labels, restricting them between the bars.
    for (int i = 0; i < itemsToShow; i++) {
      float groupX = plotX + i * groupWidth;
      float tickX = groupX + groupWidth/2;
      // Draw tick mark on x-axis.
      line(tickX, plotY+plotH, tickX, plotY+plotH+5);
      
      // Identify boundaries:
      float blueLeft   = groupX + groupWidth/2 - barWidth - 4;   // left edge of blue bar
      float redLeft    = groupX + groupWidth/2 + 4;              // left edge of red bar
      float redRight   = redLeft + barWidth;                     // right edge of red bar
      
      // The total space available for the label is between blueLeft and redRight.
      float labelSpaceLeft  = blueLeft;
      float labelSpaceRight = redRight;
      float availableWidth  = labelSpaceRight - labelSpaceLeft;
      
      // Get the original airline label.
      String label = airlines.get(i);
      
      // Wrap the label so that no line exceeds 'availableWidth'.
      textSize(16);
      String wrappedLabel = wrapText(label, availableWidth);
      
      // Measure the widest line in the wrapped label to see how to center it.
      String[] labelLines = split(wrappedLabel, '\n');
      float widestLine = 0;
      for (String ln : labelLines) {
        float wLine = textWidth(ln);
        if (wLine > widestLine) {
          widestLine = wLine;
        }
      }
      
      // We'll attempt to center the label at tickX.
      float labelX = tickX;
      // But if it extends beyond the left boundary, we shift it right.
      if (labelX - widestLine/2 < labelSpaceLeft) {
        labelX = labelSpaceLeft + widestLine/2;
      }
      // Or if it extends beyond the right boundary, we shift it left.
      if (labelX + widestLine/2 > labelSpaceRight) {
        labelX = labelSpaceRight - widestLine/2;
      }
      
      // Draw the wrapped text line by line, top-aligned at (labelX, plotY+plotH+8).
      float textLineHeight = textAscent() + textDescent();
      float startY = plotY + plotH + 8;
      for (int lineIndex = 0; lineIndex < labelLines.length; lineIndex++) {
        float lineW = textWidth(labelLines[lineIndex]);
        // We'll center each line around labelX so it looks neat, 
        // or you could left-align if you prefer.
        float lineX = labelX;
        textAlign(CENTER, TOP);
        text(labelLines[lineIndex], lineX, startY + lineIndex * textLineHeight);
      }
    }
    
    // Draw legend.
    float legendX = plotX + 10;
    float legendY = plotY - 80;
    float boxSize = 20;
    noStroke();
    fill(0, 0, 200);
    rect(legendX, legendY, boxSize, boxSize);
    fill(0);
    textSize(16);
    textAlign(LEFT, CENTER);
    text("Avg Delay (min)", legendX + boxSize + 8, legendY + boxSize/2);
    fill(200, 0, 0);
    rect(legendX, legendY+25, boxSize, boxSize);
    fill(0);
    text("Cancellation Rate (%)", legendX + boxSize + 8, legendY + 25 + boxSize/2);
    
    // Chart titles.
    textAlign(CENTER, BOTTOM);
    textSize(20);
    text("Airlines", plotX + plotW/2, y + h - 8);
    textAlign(CENTER, TOP);
    textSize(24);
    text("Airline Performance", x + w/2, y - 20);
  }
  
  // Helper function to wrap text into multiple lines if its width exceeds maxWidth.
  // This ensures no single line in 'wrappedLabel' is wider than maxWidth.
  String wrapText(String txt, float maxWidth) {
    // Split the text into words.
    String[] words = splitTokens(txt, " ");
    String currentLine = "";
    String result = "";
    
    textSize(16); // Make sure textSize is set before measuring widths
    
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (currentLine.equals("")) {
        // First word on a line
        currentLine = word;
      } else {
        // Check if we can add another word without exceeding maxWidth
        String testLine = currentLine + " " + word;
        if (textWidth(testLine) > maxWidth) {
          // If adding the new word exceeds the maximum width, start a new line.
          if (result.equals("")) {
            result = currentLine;
          } else {
            result += "\n" + currentLine;
          }
          currentLine = word;  // this word goes on the new line
        } else {
          currentLine = testLine;
        }
      }
    }
    // Append any remaining words in currentLine.
    if (!currentLine.equals("")) {
      if (result.equals("")) {
        result = currentLine;
      } else {
        result += "\n" + currentLine;
      }
    }
    return result;
  }
}
