class FlightData {
  String originCode;
  String destCode;
  String dateStr;
  int minutes;
  int duration;

  String originCityCountry;
  String destCityCountry;
  String departureTimeStr;
  String arrivalTimeStr;
  String airlineName;
  String airlineCode;
  String flightNumber;

  FlightData(String originCode, String destCode, String dateStr, int minutes, int duration,
             String originCityCountry, String destCityCountry,
             String departureTimeStr, String arrivalTimeStr,
             String airlineName, String airlineCode, String flightNumber) {
    this.originCode = originCode;
    this.destCode = destCode;
    this.dateStr = dateStr;
    this.minutes = minutes;
    this.duration = duration;

    this.originCityCountry = originCityCountry;
    this.destCityCountry = destCityCountry;
    this.departureTimeStr = departureTimeStr;
    this.arrivalTimeStr = arrivalTimeStr;
    this.airlineName = airlineName;
    this.airlineCode = airlineCode;
    this.flightNumber = flightNumber;
  }
}
