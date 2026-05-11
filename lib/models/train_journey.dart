class TrainJourney {
  final int trainId;
  final String lineId;

  final String fromStation;
  final String toStation;

  final String departureTime;
  final String arrivalTime;

  final int fromStopOrder;
  final int toStopOrder;

  // ✅ DATE
  final DateTime? travelDate;

  // ✅ PRICE
  final double ticketPrice;

  const TrainJourney({
    required this.trainId,
    required this.lineId,

    required this.fromStation,
    required this.toStation,

    required this.departureTime,
    required this.arrivalTime,

    required this.fromStopOrder,
    required this.toStopOrder,

    this.travelDate,

    // ✅ PRICE
    required this.ticketPrice,
  });
}
