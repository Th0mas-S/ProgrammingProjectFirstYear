//==================================================
// ProccessData class: handles CSV loading and processing.
class ProccessData {
  Table table;
  int totalFlights, departedOnTime, delayedFlights, cancelledFlights;
  
  ProccessData(String csvFile) {
    // Ensure your CSV file is in the sketch's "data" folder.
    table = loadTable(csvFile, "header,csv");
  }
  
  // Process the data for the given airport.
  void process(String airport) {
    totalFlights = 0;
    departedOnTime = 0;
    delayedFlights = 0;
    cancelledFlights = 0;
    
    for (TableRow row : table.rows()) {
      String origin = row.getString("origin").trim();
      if (!origin.equalsIgnoreCase(airport)) {
        continue;
      }
      
      totalFlights++;
      String cancelledStr = row.getString("cancelled").trim().toLowerCase();
      if (cancelledStr.equals("true") || cancelledStr.equals("1")) {
        cancelledFlights++;
      } else {
        int minutesLate = row.getInt("minutes_late");
        if (minutesLate > 0) {
          delayedFlights++;
        } else {
          departedOnTime++;
        }
      }
    }
    
    println("Processed data for " + airport);
    println("Total: " + totalFlights + " On Time: " + departedOnTime +
            " Delayed: " + delayedFlights + " Cancelled: " + cancelledFlights);
  }
}
