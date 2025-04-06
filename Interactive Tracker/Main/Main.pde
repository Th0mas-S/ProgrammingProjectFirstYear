import java.util.HashSet;

CalendarDisplay calendar;
TimeSlider timeSlider;

ScreenManager  screenManager;
EarthScreenDirectory  earthScreenDirectory;
EarthScreenTracker  earthScreenTracker;
MainMenuScreen mainMenuScreen;
ScreenBetweenScreens screenBetweenScreens;
CreditsScreen creditsScreen;

HeatMapScreen heatMapScreen;
DirectoryScreen directoryScreen;

LoadingScreen loadingScreen;

Earth earth;
Airport airportOrigin;
Airport airportDest;
Airplane airplane;
Assets assets;

Location origin = new Location(-25.5, 9.6);
Location destination = new Location(-51.2, 90.2);

boolean showFlightInfo = false;
float sphereRadius = 650;

ArrayList<Airport> airports = new ArrayList<Airport>();
HashMap<String, Airport> airportMap = new HashMap<String, Airport>();
ArrayList<Flight> todaysFlights = new ArrayList<Flight>();
ArrayList<Airplane> activePlanes = new ArrayList<Airplane>();
PImage airplaneImg;
PImage airplaneModel;
PImage flightHubLogoCredits;
HashSet<String> spawnedFlights = new HashSet<String>();
HashMap<String, String> airportLocations = new HashMap<String, String>();

HashMap<String, Location> airportCoordinates = new HashMap<String, Location>();

String lastCheckedDate = "";
Airplane selectedPlane = null;

SoundFile audio;

// ========================
// setup()
// ========================
void setup() {
  size(1920, 1055, P3D); // ben added this >:( (i know you can't hide from me);
  
  //fullScreen(P3D);
  
  audio = new SoundFile(this, "audio3.mp3");

  

  //loadAirportMetadata();
  //loadAirportsFromCSV();
  //loadFlightsFromCSV();
  
  assets = new Assets();
  
  
  calendar = new CalendarDisplay();
  
  timeSlider = new TimeSlider(width / 4, 60, width / 2, 30);
  timeSlider.value = 0;
  
  screenManager = new ScreenManager();

  initGlobalVariables();
  
  // this is all the stuff that will happen in the background while the loading screen is being shown
  Thread loadingThread = new Thread( () -> {
    float loadingStart = millis();
    float start = millis();
    
    loadingScreen.setLoadingProgress(0.001);
    
    airplaneImg = loadImage("Airplane.png");
    // Use the airplane image as the airplane model
    airplaneModel = airplaneImg;
    


    flightHubLogo = loadImage("Flighthub Logo.png");
    flightHubLogoCredits = loadImage("FlightHubLogoCredits.png");
    println("Loading Airplane and FlightHub image took " +  (millis() - start) + "ms");
    loadingScreen.setLoadingProgress(0.02);
    start = millis();

    
    // Initialize near stars (300 - 500 units away)
    // Initialize stars (300 - 500 units away)
    for (int i = 0; i < numStars; i++) {
      stars[i] = new Star(1000, 2500);
    }
    for (int i = 0; i < numMoreStars; i++) {
      moreStars[i] = new Star(1500, 3000);
    }
    for (int i = 0; i < numEvenMoreStars; i++) {
      evenMoreStars[i] = new Star(2000, 3500);
    }
    
    earth = new Earth("Earth.obj", "Surface2k.png", this, assets);
    airportOrigin = new Airport(origin, sphereRadius, 5);
    airportDest = new Airport(destination, sphereRadius, 5);
    
    println("Loading Earth took " + (millis() - start) + "ms");
    start = millis();
    
    loadAllAssets();
    
    println("Loading csv files took: " + (millis() - start) + "ms"); // around here should be 50%
    start = millis();
    
    earthScreenTracker = new EarthScreenTracker(earth);
    println("Creating EarthScreen Tracker " + (millis() - start) + "ms");
    start = millis();

    mainMenuScreen = new MainMenuScreen(this);
    creditsScreen = new CreditsScreen(this, audio);

    screenBetweenScreens = new ScreenBetweenScreens(this);
    println("Creating MainMenuScreen Tracker " + (millis() - start) + "ms");
    start = millis();
    loadingScreen.setLoadingProgress(loadingScreen.loadingDone + 0.05);

    
    directoryScreen = new DirectoryScreen();
    println("Creating Directory Tracker " + (millis() - start) + "ms");
    start = millis();
    loadingScreen.setLoadingProgress(loadingScreen.loadingDone + 0.01);


    heatMapScreen = new HeatMapScreen();
    println("Creating HeatMap Tracker " + (millis() - start) + "ms");
    start = millis();
    loadingScreen.setLoadingProgress(1);

    println("Total loading took approx " + (millis() - loadingStart) + "ms");
  });
  
  loadingScreen = new LoadingScreen(loadingThread);
  loadingThread.start(); // start loading the data  
  screenManager.switchScreen(loadingScreen);
  
  
  noStroke();
}

// ========================
// draw()
// ========================
void draw() {
  screenManager.drawScreen();
}

// ========================
// Mouse & Keyboard Handlers
// ========================
void mousePressed() {
  screenManager.handleMousePressed();
}

void mouseDragged() {
  screenManager.handleMouseDragged();
}

void mouseReleased() {
  screenManager.handleMouseReleased();
}

void mouseWheel(MouseEvent event) {
  screenManager.handleMouseWheel(event);
}

void mouseMoved() {
  screenManager.handleMouseMoved();
}

void keyPressed() {
  screenManager.handleKeyPressed();
}


// ========================
// Helper Functions
// ========================
PMatrix3D getRotationMatrix(float angle, PVector axis) {
  float c = cos(angle);
  float s = sin(angle);
  float t = 1 - c;
  float x = axis.x, y = axis.y, z = axis.z;
  return new PMatrix3D(
    t * x * x + c,      t * x * y - s * z,  t * x * z + s * y, 0,
    t * x * y + s * z,   t * y * y + c,      t * y * z - s * x, 0,
    t * x * z - s * y,   t * y * z + s * x,  t * z * z + c,     0,
    0,                  0,                  0,                 1
  );
}

PVector getArcballVector(float x, float y) {
  float radius = min(width, height) / 2;
  float dx = (x - width/2) / radius;
  float dy = (y - height/2) / radius;
  PVector v = new PVector(dx, dy, 0);
  float mag = v.mag();
  if (mag > 1.0) {
    v.normalize();
  } else {
    v.z = sqrt(1.0 - mag * mag);
  }
  return v;
}

PVector slerp(float t, PVector v0, PVector v1) {
  float dot = constrain(v0.dot(v1), -1, 1);
  float theta = acos(dot);
  if (theta < 0.001) return v0.copy();
  float sinTheta = sin(theta);
  float w1 = sin((1 - t) * theta) / sinTheta;
  float w2 = sin(t * theta) / sinTheta;
  return PVector.add(v0.copy().mult(w1), v1.copy().mult(w2));
}

void multiplyP3DMatrixScalar(PMatrix3D mat, float s) {
  mat.m00 *= s;  mat.m01 *= s;  mat.m02 *= s;  mat.m03 *= s;
  mat.m10 *= s;  mat.m11 *= s;  mat.m12 *= s;  mat.m13 *= s;
  mat.m20 *= s;  mat.m21 *= s;  mat.m22 *= s;  mat.m23 *= s;
  mat.m30 *= s;  mat.m31 *= s;  mat.m32 *= s;  mat.m33 *= s;
}



void loadAllAssets() {
  String[] rows = loadStrings("airport_data.csv");
  float start = millis();
  for(int i=1; i<rows.length; i++){
      String[] data = split(rows[i], ',');
      
      String iata = data[2];
      String city = data[3];
      String country = data[4];
      float lat = parseFloat(data[6]);
      float lon = parseFloat(data[7]);
      
      // heatmap
      airportCoordinates.put(iata, new Location(lat, lon));
      
      if (iata != null && city != null && country != null) {
        String location = city + ", " + country;
        airportLocations.put(iata.trim(), location);
      }
      
      float relLat = -lat + 0.2617;
      float relLon = 1.0071 * lon + 90.35;
      Location loc = new Location(relLat, relLon);
      Airport airport = new Airport(loc, sphereRadius, 5);
      airports.add(airport);
      airportMap.put(iata, airport);
  } 
  println("Loading Airport Data took " +  (millis() - start) + "ms");
  
  start = millis();
  initializeDictionary(rows); // this can be optimised, good enough for now!
  println("Initialising dictionary took" +  (millis() - start) + "ms");
  
  start = millis();
  initializeFlights();
  println("Initialising flights took " +  (millis() - start) + "ms");

  
  clearIndex();

}
