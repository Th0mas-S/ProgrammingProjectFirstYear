import java.util.Collections;
import java.util.Comparator;
import java.util.List;
ArrayList<Flight> flData;
ArrayList<Integer> sortOrder, currentSortOrder, dateRange;
ArrayList<String> airportCode, airportName, airlineCode, airlineName;
int currentScreen;
String inputText;
boolean entered, lowHigh;
Screen screen1, screen2;
Flight currentFlight;
Graphs newGraph;

void setup(){
  size(1280, 720);
  String[] lines = loadStrings("flights.csv");
  flData = new ArrayList<Flight>();
  initializeArray(flData, lines);
  println("flights loaded");
  lowHigh=true;
  setLateness();
  screen1 = new Screen(1);
  screen2 = new Screen(2);
  currentScreen = 1;
  initializeDictionary();
  
  newGraph = new Graphs(); 
}

void initializeDictionary(){
  airportCode = new ArrayList<String>();
  airportName = new ArrayList<String>();
  String[] readIn = loadStrings("L_AIRPORT.csv");
  for(int i=1; i<readIn.length; i++){
    String[] row = split(readIn[i], ",");
    airportCode.add(removeFirstLast(row[0]));
    airportName.add(removeFirst(row[1]));
  }
  
  airlineCode = new ArrayList<String>();
  airlineName = new ArrayList<String>();
  readIn = loadStrings("L_CARRIER_HISTORY.csv");
  for(int i=1; i<readIn.length; i++){
    String[] row = split(readIn[i], ",");
    airlineCode.add(removeFirstLast(row[0]));
    airlineName.add(removeFirstLast(row[1]));
  }
  println("dictionaries loaded");
}

String removeFirstLast(String str) {
  return (str.length() > 1) ? str.substring(1, str.length() - 1) : "";
}

String removeFirst(String str) {
  return (str.length() > 1) ? str.substring(1, str.length()) : "";
}

String getInput(){
  return(inputText);
}

void clearInput(){
  inputText="";
}

void keyPressed() {
  entered=false;
  if(key == ENTER || key == RETURN) {
    println("Final input: " + inputText);
    entered=true;
  } 
  else if(key == BACKSPACE && inputText.length() > 0) {
    inputText = inputText.substring(0, inputText.length()-1);
  } 
  else if(keyCode != SHIFT){
    inputText += key;
  }
}

void initializeArray(ArrayList<Flight> flData, String[] lines){
  for(int i=1; i<lines.length; i++){
     flData.add(new Flight()); 
     String[] list = split(lines[i], ',');
     
     String[] dateCut=split(list[0], " ");
     flData.get(i-1).date = dateCut[0];
     flData.get(i-1).carrier = list[1];
     flData.get(i-1).flNumber = int(list[2]);
     flData.get(i-1).origin = list[3];
     flData.get(i-1).orCity = removeFirstLast(list[4]+list[5]);
     flData.get(i-1).orCode = list[6];
     flData.get(i-1).orWAC = int(list[7]);
     flData.get(i-1).destination = list[8];
     flData.get(i-1).destCity = removeFirstLast(list[9]+" "+list[10]);
     flData.get(i-1).destCode = list[11];
     flData.get(i-1).destWAC = int(list[12]);
     
     if(int(list[17])==0) flData.get(i-1).cancelled=false;
     else flData.get(i-1).cancelled = true;
     if(int(list[18])==0) flData.get(i-1).diverted=false;
     else flData.get(i-1).diverted = true;
     flData.get(i-1).flDistance = int(list[19]);
     
     flData.get(i-1).depTimeE = getTime(list[13], flData.get(i-1).cancelled);
     flData.get(i-1).depTime = getTime(list[14], flData.get(i-1).cancelled);
     flData.get(i-1).arrTimeE = getTime(list[15], flData.get(i-1).cancelled);
     flData.get(i-1).arrTime = getTime(list[16], flData.get(i-1).cancelled);
     
  }
}

String getTime(String input, boolean cancelled){
  if(cancelled==true || input==null || input=="") return("n/a");
  char[] time = input.toCharArray();
  if(time.length==0) return("n/a");
  else if(time.length==3) return("0"+time[0]+":"+time[1]+""+time[2]);
  else if(time.length==2) return("00"+":"+time[0]+""+time[1]);
  else if(time.length==1) return("00"+":"+"0"+time[0]);
  return(time[0]+""+time[1]+":"+time[2]+""+time[3]);
}

void mousePressed(){
   if(currentScreen==1){
     screen1.screenMousePressed();
   }
   else if(currentScreen==2){
     screen2.screenMousePressed();
   }
   println("x:"+mouseX);
   println("y:"+mouseY);
}
  
void mouseMoved(){
   if(currentScreen==1){
     screen1.screenMouseMoved();
   }
   if(currentScreen==2){
     screen2.screenMouseMoved();
   }
}

void mouseReleased(){
  if(currentScreen==1){
      screen1.slider.SliderMouseReleased();
  }
}
  
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(currentScreen==1){
     screen1.slider.scroll(e);
  }
}

int convertTime(String timeIn){
  if(timeIn.equals("n/a")) return(0);
  String[] num = timeIn.split(":");
  int time = (int(num[0])*60)+int(num[1]);
  return(time);
}

void dateSort(String date1In, String date2In){
  dateRange = new ArrayList<Integer>();
  String[] date1 = split(date1In, "/");
  String[] date2 = split(date2In, "/");
  int[] dates = {int(date1[0]), int(date1[1]), int(date1[2]), int(date2[0]), int(date2[1]), int(date2[2])};
  //for(int k=0; k<6; k++) println(dates[k]);
  for(int i=0; i<flData.size(); i++){
    String[] dateIn = split(flData.get(i).date, "/");
    int[] date = {int(dateIn[1]), int(dateIn[0]), int(dateIn[2])};
    //println(date[1]+">="+dates[1]+"  "+date[1]+"<="+dates[4]);
    //println(date[0]+">="+dates[0]+"  "+date[0]+"<="+dates[3]);
    if(date[2]>=dates[2] && date[2]<=dates[5] && date[1]>=dates[1] && date[1]<=dates[4] && date[0]>=dates[0] && date[0]<=dates[3]){
      dateRange.add(i);
    }
  }
  println("sorted");
}

void setLateness(){
  sortOrder= new ArrayList<Integer>();
  for(int i=0; i<flData.size(); i++){
    int arrE=convertTime(flData.get(i).arrTimeE);
    int arr=convertTime(flData.get(i).arrTime);
    int depE=convertTime(flData.get(i).depTimeE);
    int dep=convertTime(flData.get(i).depTime);
    if(arr<dep) arr+=60*24;
    if(arrE<depE) arrE+=60*24;
    if(arr>arrE){
      flData.get(i).minsLate=arr-arrE;
      sortOrder.add(i);
    }
    else flData.get(i).minsLate=0;    
  }
  println("loaded(1)");
  
  Collections.sort(sortOrder, Comparator.comparingInt(index -> flData.get(index).minsLate));
  
  currentSortOrder = sortOrder;
  println("loaded(2)");
}

void resort(){
  if(lowHigh) currentSortOrder=sortOrder;
  else currentSortOrder = reverseArray(sortOrder);
}

ArrayList<Integer> reverseArray(ArrayList<Integer> array){
  ArrayList<Integer> sortedArray = new ArrayList<Integer>();
  for(int i=array.size()-1; i>=0; i--){
    sortedArray.add(array.get(i));
  }
  return sortedArray;
}

void draw(){
  if(currentScreen==1) screen1.draw();
  else if(currentScreen==2) screen2.draw();
  
  newGraph.drawButton(); 
  if (newGraph.screen2)
  {
   newGraph.graphScreen(); 
  }
  newGraph.checkButtonPressed(mouseX, mouseY);
}
