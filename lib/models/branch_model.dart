class Branch {
  const Branch(
      {required this.name,
      required this.latitude,
      required this.longitude,
      required this.radius});

  final String name;
  final double latitude;
  final double longitude;
  final int radius;

  List<double> get coordinates {
    return [latitude, longitude];
  }
}
