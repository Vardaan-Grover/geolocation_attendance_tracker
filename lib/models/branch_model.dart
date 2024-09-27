class Branch {
  const Branch(
      {required this.name,
      required this.address,
      required this.latitude,
      required this.longitude,
      required this.radius});

  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int radius;

  List<double> get coordinates {
    return [latitude, longitude];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }
}
