class TrainTime {
  // Attributes
  int id;
  DateTime arrivalTime;
  DateTime departureTime;
  int trainId;
  String stationName;
  String dayType;

  // Constructor
  TrainTime({
    required this.id,
    required this.arrivalTime,
    required this.departureTime,
    required this.trainId,
    required this.stationName,
    required this.dayType,
  });

  // Methods
  bool isPeakHour() {
    // Logic hne (mathalan bin el 7 w el 9 mte3 sbe7)
    return arrivalTime.hour >= 7 && arrivalTime.hour <= 9;
  }

  String getDelayStatus() {
    // Logic mte3 e-retard hne
    return "On Time";
  }

  bool isLastTrain() {
    // Logic kenou ekher train wala le
    return false;
  }
}
