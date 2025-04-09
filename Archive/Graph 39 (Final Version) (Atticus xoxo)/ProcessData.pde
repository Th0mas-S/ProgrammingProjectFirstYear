// ProcessData.pde
// Loads and processes flight_data_2017.csv

import java.util.ArrayList;
import java.util.Collections;

class ProcessData {
  Table table;
  
  // Summary stats for the pie chart.
  int totalFlights, onTimeFlights, delayedFlights, cancelledFlights;
  
  // If set, filter the data to only include rows matching this date ("YYYY-MM-DD")
  String filterDate = null;
  
  ProcessData(String csvFile) {
    try {
      table = loadTable(csvFile, "header,csv");
      println("Loaded " + table.getRowCount() + " rows from " + csvFile);
    } catch(Exception e) {
      println("Error loading CSV: " + e.getMessage());
    }
  }
  
  void process(String airport) {
    if (table == null) {
      println("No table loaded, cannot process data.");
      return;
    }
    totalFlights = 0;
    onTimeFlights = 0;
    delayedFlights = 0;
    cancelledFlights = 0;
    for (TableRow row : table.rows()) {
      if (!rowMatchesFilter(row, airport)) continue;
      totalFlights++;
      String cancelledStr = row.getString("cancelled").trim().toLowerCase();
      if (cancelledStr.equals("true")) {
        cancelledFlights++;
      } else {
        try {
          int delay = row.getInt("minutes_late");
          if (delay > 0) {
            delayedFlights++;
          } else {
            onTimeFlights++;
          }
        } catch(Exception e) { }
      }
    }
    println("Processed data for airport: " + airport + " on " + (filterDate != null ? filterDate : "all dates"));
    println("  Total Flights: " + totalFlights);
    println("  On Time: " + onTimeFlights);
    println("  Delayed: " + delayedFlights);
    println("  Cancelled: " + cancelledFlights);
    println("---------------------------------------");
  }
  
  // Helper method: Returns true if the row matches the specified airport and (if set) the filterDate.
  boolean rowMatchesFilter(TableRow row, String airport) {
    if (!row.getString("origin").equalsIgnoreCase(airport)) return false;
    if (filterDate != null) {
      String sched = row.getString("scheduled_departure");
      if (sched == null || !sched.substring(0, 10).equals(filterDate)) return false;
    }
    return true;
  }
  
  String[] getUniqueAirports() {
    if (table == null) return new String[0];
    ArrayList<String> unique = new ArrayList<String>();
    for (TableRow row : table.rows()) {
      String orig = row.getString("origin").trim();
      if (!unique.contains(orig)) {
        unique.add(orig);
      }
    }
    Collections.sort(unique);
    return unique.toArray(new String[unique.size()]);
  }
}
