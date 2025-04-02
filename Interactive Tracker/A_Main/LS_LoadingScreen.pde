class LoadingScreen extends Screen {
float[][] terrain;
int cols, rows;
int scl = 20;
int w, h;

float flying = 0;
PImage cockpit;

Cloud[] clouds;
int numClouds = 10;

// Global cloud color (light pink)
color globalCloudColor = color(255, 182, 193);

// Loading progress (0 to 1)
float loadingProgress = 0;

void setup() {
  size(1920, 1055, P3D);
  w = width;
  h = height;
  cols = w / scl;
  rows = h / scl;
  terrain = new float[cols][rows];

  cockpit = loadImage("cockpit.png");

  clouds = new Cloud[numClouds];
  for (int i = 0; i < numClouds; i++) {
    float x = random(width);
    float y = random(height / 4);
    float size = random(80, 150);
    clouds[i] = new Cloud(x, y, size, globalCloudColor);
  }
}

void draw() {
  background(135, 206, 235);  // Sky blue

  // Gradient sky
  pushMatrix();
  resetMatrix();
  hint(DISABLE_DEPTH_TEST);
  color topColor = color(135, 206, 235);    // SkyBlue
  color bottomColor = color(70, 130, 180);    // SteelBlue
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    stroke(lerpColor(topColor, bottomColor, inter));
    line(0, y, width, y);
  }
  hint(ENABLE_DEPTH_TEST);
  popMatrix();

  // Draw clouds
  pushMatrix();
  resetMatrix();
  for (int i = 0; i < clouds.length; i++) {
    clouds[i].update();
    clouds[i].display();
  }
  popMatrix();

  // Update terrain
  flying -= 0.1;
  float yoff = flying;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map(noise(xoff, yoff), 0, 1, -100, 100);
      xoff += 0.2;
    }
    yoff += 0.2;
  }
  
  // Draw 3D terrain
  pushMatrix();
  translate(width/2, height/2);
  rotateX(PI/2.3);
  scale(2, 1, 2);
  translate(-width/2, -height/2);
  fill(200, 200, 200, 150);
  for (int y = 0; y < rows - 1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      vertex(x * scl, y * scl * 1.5, terrain[x][y]);
      vertex(x * scl, (y + 1) * scl * 1.5, terrain[x][y + 1]);
    }
    endShape();
  }
  popMatrix();

  // Draw cockpit (full brightness)
  hint(DISABLE_DEPTH_TEST);
  imageMode(CORNER);
  image(cockpit, 0, 0, width, height+300);
  hint(ENABLE_DEPTH_TEST);
  
  // For demonstration, gradually increase loadingProgress until it reaches 1.
  if (loadingProgress < 1) {
    loadingProgress = min(1, loadingProgress + 0.005);
  }
  
// --- Display Loading Bar ---
hint(DISABLE_DEPTH_TEST);
int barWidth = 250;
int barHeight = 20;
float filledWidth = loadingProgress * barWidth;

// Draw bar outline (Y adjusted: 970 - 80 = 890)
rectMode(CENTER);
stroke(12, 190, 12);
noFill();
rect(960, 890, barWidth - 8, barHeight);

// Draw filled part of the bar
rectMode(CORNER);
noStroke();
fill(12, 190, 12);
rect(839, 880, filledWidth - 8, barHeight);
hint(ENABLE_DEPTH_TEST);

// --- Display Loading Text ---
hint(DISABLE_DEPTH_TEST);
fill(12, 190, 12);
textSize(40);

// Draw the stationary "Loading" text
textAlign(CENTER, CENTER);
text("Loading", 960, 850);

// Draw the animated dots next to "Loading"
textAlign(LEFT, CENTER);
int loadingIndex = int((millis() / 500) % 3);
String[] dots = { ".", "..", "..." };
float loadingTextWidth = textWidth("Loading");
text(dots[loadingIndex], 950 + loadingTextWidth / 2 + 10, 850);
hint(ENABLE_DEPTH_TEST);

}

// Method to externally set the loading bar's progress (0 to 1)
void setLoadingProgress(float p) {
  loadingProgress = constrain(p, 0, 1);
}

// Change cloud color with 'c' key
void keyPressed() {
  if (key == 'c' || key == 'C') {
    globalCloudColor = color(random(255), random(255), random(255));
    for (int i = 0; i < numClouds; i++) {
      clouds[i].setColor(globalCloudColor);
    }
  }
}

}
