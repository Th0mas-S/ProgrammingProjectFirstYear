class PieChartScreen {
  String airport;
  ProcessData data;
  float animationProgress;
  
  PieChartScreen(String airport, ProcessData data, float animationProgress) {
    this.airport = airport;
    this.data = data;
    this.animationProgress = animationProgress;
  }
  
  void display(float x, float y, float w, float h) {
    float cx = x + w / 2;
    float cy = y + h / 2;
    float dia = min(w, h) * 0.9;
    
    int onTime    = data.onTimeFlights;
    int delayed   = data.delayedFlights;
    int cancelled = data.cancelledFlights;
    int total     = max(1, onTime + delayed + cancelled);
    
    float angleOnTime    = TWO_PI * onTime / total;
    float angleDelayed   = TWO_PI * delayed / total;
    float angleCancelled = TWO_PI - angleOnTime - angleDelayed;
    
    float anim = animationProgress;
    float startAngle = -HALF_PI;
    stroke(255);
    strokeWeight(2);
    
    fill(0, 200, 0);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleOnTime * anim);
    startAngle += angleOnTime * anim;
    
    fill(0, 0, 255);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleDelayed * anim);
    startAngle += angleDelayed * anim;
    
    fill(255, 0, 0);
    arc(cx, cy, dia, dia, startAngle, startAngle + angleCancelled * anim);
    
    float spacing = 10;       // Vertical spacing between legend rows
    float legendX = x + 40;   // Position the legend a bit away from the left
    float legendY = y + 40;   // Position the legend a bit away from the top
    float boxSize = 40;       // Legend box size
    textSize(20);             // Legend text size
    textAlign(LEFT, CENTER);
    noStroke();
    
    // Legend for "On Time"
    fill(0, 200, 0);
    rect(legendX, legendY, boxSize, boxSize);
    fill(0);
    text("On Time: " + onTime, legendX + boxSize + 8, legendY + boxSize/2);
    
    // Legend for "Delayed"
    fill(0, 0, 255);
    rect(legendX, legendY + boxSize + spacing, boxSize, boxSize);
    fill(0);
    text("Delayed: " + delayed, legendX + boxSize + 8, legendY + boxSize + spacing + boxSize/2);
    
    // Legend for "Cancelled"
    fill(255, 0, 0);
    rect(legendX, legendY + 2*(boxSize + spacing), boxSize, boxSize);
    fill(0);
    text("Cancelled: " + cancelled, legendX + boxSize + 8, legendY + 2*(boxSize + spacing) + boxSize/2);
  }
}
