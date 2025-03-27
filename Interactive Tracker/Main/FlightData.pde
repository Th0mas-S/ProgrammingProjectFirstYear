class FlightData {
  String originCode;
  String destCode;
  String dateStr;
  int departureMinutes;
  int arrivalMinutes;
  int durationMinutes;

  FlightData(String origin, String dest, String dateStr, int departureMinutes, int arrivalMinutes) {
    this.originCode = origin;
    this.destCode = dest;
    this.dateStr = dateStr;
    this.departureMinutes = departureMinutes;
    this.arrivalMinutes = arrivalMinutes;
    this.durationMinutes = arrivalMinutes - departureMinutes;
    if (this.durationMinutes <= 0) this.durationMinutes += 1440; // Handle overnight flights
  }
}
