class Location {
  float lat;
  float lon;
  
  Location(float lat, float lon) {
    this.lat = lat;
    this.lon = lon;
  }
  
  Location toRadians() {
    return new Location(radians(this.lat), radians(this.lon));
  }
  
}
