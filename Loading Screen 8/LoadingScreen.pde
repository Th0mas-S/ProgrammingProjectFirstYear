float[][] cloudLayer;
float[][] cloudDensity;
int cols, rows;
int scl = 20;
int w, h;

float flying = 0;
float progress = 0;

PImage cockpit;
PGraphics skyBG;

void setup() {
  fullScreen(P3D);
  skyBG = createGraphics(width, height, P2D);

  w = width;
  h = height;
  cols = w / scl;
  rows = h / scl;
  cloudLayer = new float[cols][rows];
  cloudDensity = new float[cols][rows];

  cockpit = loadImage("cockpit.png");
}

void draw() {
  // --- Sky Gradient and Loading Bar ---
  skyBG.beginDraw();
  skyBG.background(0, 0);
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    int c = lerpColor(color(135, 206, 235), color(255), inter);
    skyBG.stroke(c);
    skyBG.line(0, y, width, y);
  }

  int textY = height / 3 - 40;
  int barY = height / 3;
  int barWidth = 300;
  int barHeight = 20;
  int barX = (width - barWidth) / 2;

  skyBG.textAlign(CENTER, CENTER);
  skyBG.textSize(48);
  skyBG.fill(255);
  skyBG.text("Loading", width / 2, textY);

  skyBG.noFill();
  skyBG.stroke(255);
  skyBG.strokeWeight(2);
  skyBG.rect(barX, barY, barWidth, barHeight);

  skyBG.noStroke();
  skyBG.fill(255);
  skyBG.rect(barX, barY, progress * barWidth, barHeight);
  skyBG.endDraw();

  if (progress < 1) progress += 0.002;
  image(skyBG, 0, 0);

  // --- Cloud Height + Density Fields ---
  flying -= 0.002;
  float yoff = flying;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      float n1 = noise(xoff, yoff);
      float n2 = noise(xoff * 2.0, yoff * 2.0) * 0.5;
      float n3 = noise(xoff * 4.0, yoff * 4.0) * 0.25;
      float combined = (n1 + n2 + n3) / (1.0 + 0.5 + 0.25);

      float ripple = sin((x + frameCount * 0.03) * 0.1) * 1.5 + cos((y + frameCount * 0.02) * 0.1) * 1;
      float baseHeight = map(combined, 0, 1, 40, 120);
      cloudLayer[x][y] = baseHeight + ripple;

      // Density: additional large-scale noise
      float d = noise(xoff * 0.25, yoff * 0.25 + 100);
      cloudDensity[x][y] = constrain(map(d, 0.4, 0.8, 0, 1), 0, 1); // creates patches and holes

      xoff += 0.15;
    }
    yoff += 0.15;
  }

  // --- Cloud Rendering with Gaps ---
  hint(ENABLE_DEPTH_TEST);
  pushMatrix();
  translate(width / 2, height / 2 + 150);
  rotateX(PI / 2.3);
  scale(2, 1, 2);
  translate(-width / 2, -height / 2);

  noStroke();
  for (int y = 0; y < rows - 1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      float d1 = cloudDensity[x][y];
      float d2 = cloudDensity[x][y + 1];

      if (d1 < 0.02 && d2 < 0.02) continue; // skip near-transparent sections

      float z1 = cloudLayer[x][y];
      float z2 = cloudLayer[x][y + 1];

      float alpha = map((d1 + d2) * 0.5, 0, 1, 0, 160);
      float brightness = map((z1 + z2) * 0.5, 40, 120, 240, 255);
      int c = int(brightness);
      fill(c, c, c, alpha);

      vertex(x * scl, y * scl * 1.5, z1);
      vertex(x * scl, (y + 1) * scl * 1.5, z2);
    }
    endShape();
  }

  popMatrix();

  // --- Cockpit Overlay ---
  hint(DISABLE_DEPTH_TEST);
  imageMode(CORNER);
  image(cockpit, 0, 0, width, height);
  hint(ENABLE_DEPTH_TEST);
}
