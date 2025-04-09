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

String[] flightRows;

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

boolean backspaceHeld = false;
int backspaceHoldStart = 0;
int backspaceLastDelete = 0;
int initialDelay = 300;
int repeatRate = 50;

boolean ctrlBackspaceHeld = false;
int ctrlBackspaceHoldStart = 0;
int ctrlBackspaceLastRepeat = 0;
int ctrlBackspaceInitialDelay = 300;
int ctrlBackspaceRepeatRate = 50;

char heldKey = 0;
boolean keyBeingHeld = false;
int keyHoldStart = 0;
int keyLastRepeat = 0;

boolean arrowLeftHeld = false;
boolean arrowRightHeld = false;
int arrowHoldStart = 0;
int arrowLastRepeat = 0;
int arrowInitialDelay = 300;
int arrowRepeatRate = 50;

boolean enterHeld = false;
int enterHoldStart = 0;
int enterLastRepeat = 0;
int enterInitialDelay = 300;
int enterRepeatRate = 300; // slower than text keys

int SCREEN_SELECTION = 0;
int SCREEN_OVERVIEW = 1;
int screenMode = SCREEN_SELECTION;

int lastKeyTime = 0;
char lastKey = 0;

Utility util;
AirportSelectorMenu airportSelector;
GraphSelectorMenu graphScreen;
ProcessData processData;
String[] uniqueAirports;
PFont unicodeFont;
PImage flighthubLogo;
HashMap<String, String> airportLookup = new HashMap<String, String>();

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
  
  //// this is all the stuff that will happen in the background while the loading screen is being shown
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

void draw() {
  screenManager.drawScreen();
  
  if (screenMode == SCREEN_SELECTION && airportSelector != null && airportSelector.searchFocused) {
    int now = millis();

    if (backspaceHeld && now - backspaceHoldStart > initialDelay && now - backspaceLastDelete > repeatRate) {
      handleBackspace();
      backspaceLastDelete = now;
    }

    if (ctrlBackspaceHeld && now - ctrlBackspaceHoldStart > ctrlBackspaceInitialDelay &&
        now - ctrlBackspaceLastRepeat > ctrlBackspaceRepeatRate) {
      handleCtrlBackspace();
      ctrlBackspaceLastRepeat = now;
    }

    if (arrowLeftHeld && now - arrowHoldStart > arrowInitialDelay &&
        now - arrowLastRepeat > arrowRepeatRate) {
      airportSelector.setCaretIndex(airportSelector.caretIndex - 1);
      airportSelector.clearSelection();
      arrowLastRepeat = now;
    }

    if (arrowRightHeld && now - arrowHoldStart > arrowInitialDelay &&
        now - arrowLastRepeat > arrowRepeatRate) {
      airportSelector.setCaretIndex(airportSelector.caretIndex + 1);
      airportSelector.clearSelection();
      arrowLastRepeat = now;
    }

    if (enterHeld && now - enterHoldStart > enterInitialDelay &&
        now - enterLastRepeat > enterRepeatRate) {
      String[] filteredAirports = airportSelector.getFilteredAirports();
      if (filteredAirports.length == 1) {
        String selected = filteredAirports[0];
        processData.filterDate = null;
        if (graphScreen != null) graphScreen.lastSelectedDate = null;
        processData.process(selected);
        graphScreen = new GraphSelectorMenu(selected, processData);
        screenMode = SCREEN_OVERVIEW;
      }
      enterLastRepeat = now;
    }

    if (keyBeingHeld && heldKey != 0 &&
        heldKey != BACKSPACE && heldKey != DELETE &&
        heldKey != ENTER && heldKey != RETURN) {
      if (now - keyHoldStart > initialDelay && now - keyLastRepeat > repeatRate) {
        insertKeyChar(heldKey);
        keyLastRepeat = now;
      }
    }
  }
}

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
  
  if (key == BACKSPACE && graphScreen != null) {
    if (!graphScreen.inMenu) {
      graphScreen.inMenu = true;
      return;
    }
    else {
      screenManager.switchScreen(airportSelector);
      graphScreen = null;
      return;
    }
  }
    screenManager.handleKeyPressed();
  
  if (screenMode == SCREEN_SELECTION && airportSelector != null && airportSelector.searchFocused) {
    processAirportSelectorKey(key, keyCode, keyEvent);
  }
}

void keyReleased() {
  backspaceHeld = false;
  ctrlBackspaceHeld = false;
  arrowLeftHeld = false;
  arrowRightHeld = false;
  enterHeld = false;
  keyBeingHeld = false;
  heldKey = 0;
}


void insertKeyChar(char c) {
  if (airportSelector.searchQuery.length() >= SEARCH_CHAR_LIMIT) return;
  
  int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
  int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
  
  if (airportSelector.hasSelection()) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                    c +
                                    airportSelector.searchQuery.substring(selEnd);
    airportSelector.caretIndex = selStart + 1;
    airportSelector.clearSelection();
  } else {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, airportSelector.caretIndex) +
                                    c +
                                    airportSelector.searchQuery.substring(airportSelector.caretIndex);
    airportSelector.caretIndex++;
    airportSelector.clearSelection();
  }
  airportSelector.resetScroll();
}

void handleBackspace() {
  int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
  int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
  if (airportSelector.hasSelection()) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                    airportSelector.searchQuery.substring(selEnd);
    airportSelector.caretIndex = selStart;
    airportSelector.clearSelection();
    airportSelector.resetScroll();
  } else if (airportSelector.caretIndex > 0) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, airportSelector.caretIndex - 1) +
                                    airportSelector.searchQuery.substring(airportSelector.caretIndex);
    airportSelector.caretIndex--;
    airportSelector.clearSelection();
    airportSelector.resetScroll();
  }
}

void handleCtrlBackspace() {
  if (airportSelector.searchQuery.length() == 0) {
    ctrlBackspaceHeld = false;
    return;
  }
  int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
  int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);
  if (selStart != selEnd) {
    airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                    airportSelector.searchQuery.substring(selEnd);
    airportSelector.setCaretIndex(selStart);
    airportSelector.clearSelection();
    airportSelector.resetScroll();
    return;
  }
  
  String text = airportSelector.searchQuery;
  int caret = airportSelector.caretIndex;
  if (caret == 0) return;
  int left = caret;
  while (left > 0 && text.charAt(left - 1) == ' ') { left--; }
  while (left > 0 && isSpecialChar(text.charAt(left - 1))) { left--; }
  while (left > 0 && isWordChar(text.charAt(left - 1))) { left--; }
  while (left > 0 && text.charAt(left - 1) == ' ') { left--; }
  
  airportSelector.searchQuery = text.substring(0, left) + text.substring(caret);
  airportSelector.setCaretIndex(left);
  airportSelector.clearSelection();
  airportSelector.resetScroll();
}

boolean isWordChar(char c) {
  return Character.isLetterOrDigit(c);
}
boolean isSpecialChar(char c) {
  return !Character.isLetterOrDigit(c) && c != ' ';
}

void processAirportSelectorKey(char key, int keyCode, KeyEvent evt) {
  int selStart = min(airportSelector.selectionStart, airportSelector.selectionEnd);
  int selEnd = max(airportSelector.selectionStart, airportSelector.selectionEnd);

  if (key == BACKSPACE) {
    if (evt.isControlDown() || evt.isMetaDown()) {
      ctrlBackspaceHeld = true;
      ctrlBackspaceHoldStart = millis();
      ctrlBackspaceLastRepeat = millis();
    } else {
      backspaceHeld = true;
      backspaceHoldStart = millis();
      backspaceLastDelete = millis();
    }
  } else if (key == DELETE) {
    if (airportSelector.hasSelection()) {
      airportSelector.searchQuery = airportSelector.searchQuery.substring(0, selStart) +
                                      airportSelector.searchQuery.substring(selEnd);
      airportSelector.setCaretIndex(selStart);
      airportSelector.clearSelection();
      airportSelector.resetScroll();
    } else if (airportSelector.caretIndex < airportSelector.searchQuery.length()) {
      airportSelector.searchQuery = airportSelector.searchQuery.substring(0, airportSelector.caretIndex) +
                                      airportSelector.searchQuery.substring(airportSelector.caretIndex + 1);
      airportSelector.clearSelection();
      airportSelector.resetScroll();
    }
  } else if (key == CODED) {
    if (keyCode == LEFT) {
      arrowLeftHeld = true;
      arrowHoldStart = millis();
      arrowLastRepeat = millis();
    } else if (keyCode == RIGHT) {
      arrowRightHeld = true;
      arrowHoldStart = millis();
      arrowLastRepeat = millis();
    }
  } else if (key == ENTER || key == RETURN) {
    enterHeld = true;
    enterHoldStart = millis();
    enterLastRepeat = millis();
  } else {
    heldKey = key;
    keyBeingHeld = true;
    keyHoldStart = millis();
    keyLastRepeat = millis();
  }
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
  flightRows = loadStrings(currentDataset);

  initializeFlights(flightRows);
  println("Initialising flights took " +  (millis() - start) + "ms");

  clearIndex();

  
  // graph loading
  loadAirportDictionary(rows);
  initGraphGlobVariables();


}
