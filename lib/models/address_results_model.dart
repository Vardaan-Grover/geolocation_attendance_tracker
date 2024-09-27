class AddressResult {
  final List<String>? addresses;
  final String? error;

  AddressResult({this.addresses, this.error});

  /// Returns:
  /// - `true`: If there is no error, and `addresses` is not null. `addresses` may still be empty.
  /// - `false`: If there was an error while fetching addresses from API.
  bool get isSuccess => addresses != null;
}