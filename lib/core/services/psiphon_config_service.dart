import 'dart:convert';
import 'dart:io';

class PsiphonConfigService {
  /// Reads the config file and returns the value of 'EgressRegion'.
  /// Returns null if the file or key doesn't exist.
  Future<String?> readEgressRegion(String configPath) async {
    try {
      final file = File(configPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return json['EgressRegion'] as String?;
      }
    } catch (e) {
      print('Error reading config file: $e');
    }
    return null;
  }

  /// Updates the 'EgressRegion' in the config file.
  Future<void> updateEgressRegion(String configPath, String regionCode) async {
    try {
      final file = File(configPath);
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      // Update the value
      json['EgressRegion'] = regionCode;

      // Write the updated JSON back to the file
      // Use an encoder for pretty printing the JSON
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(json));
    } catch (e) {
      print('Error updating config file: $e');
      rethrow;
    }
  }
}