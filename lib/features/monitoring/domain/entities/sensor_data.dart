class SensorData {
  final double ph;
  final double tds;
  final double ec; // Electrical Conductivity (Kepekatan pupuk)
  final double waterTemperature; // Suhu air
  final double waterVolume; // Volume tandon
  final NpkData npk; // Nitrogen, Fosfor, Kalium
  final DateTime timestamp;

  const SensorData({
    required this.ph,
    required this.tds,
    required this.ec,
    required this.waterTemperature,
    required this.waterVolume,
    required this.npk,
    required this.timestamp,
  });
}

class NpkData {
  final double nitrogen;
  final double phosphorus;
  final double potassium;

  const NpkData({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
  });
}