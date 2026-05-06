import 'package:tuni_train/data/stations_data.dart';

class Train {
  int? id;
  String? currentPosition;
  String? lineId;
  int? capacity;
  bool? trainStatus; 
  double? currentSpeed;

  Train({
    this.id,
    this.currentPosition,
    this.lineId,
    this.capacity,
    this.trainStatus,
    this.currentSpeed,
  });

  void updatePosition() {
    // logic
  }

  StationsData? getNextStation() {
    return null;
  }

  int calculateDelay() {
    return 0;
  }

  bool isFull() {
    return false;
  }
}
