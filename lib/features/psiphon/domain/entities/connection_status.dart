import 'package:equatable/equatable.dart';

enum ConnectionState {
  disconnected,
  connecting,
  connected,
  stopping,
  error,
}

class ConnectionStatus extends Equatable {
  // A default list of regions to ensure the UI is never empty.
  static const List<String> defaultRegions = [
    "AT", "AU", "BE", "BR", "CA", "CH", "CZ", "DE", "DK", "ES",
    "FI", "FR", "GB", "ID", "IE", "IN", "IT", "JP", "LT", "NL",
    "NO", "PL", "RO", "RS", "SE", "SG", "US"
  ];

  final ConnectionState state;
  final int? httpProxyPort;
  final int? socksProxyPort;
  final List<String> availableRegions;
  final String? clientRegion;
  final String? connectedServerRegion;
  final String? selectedEgressRegion;
  final String? errorMessage;

  const ConnectionStatus({
    this.state = ConnectionState.disconnected,
    this.httpProxyPort,
    this.socksProxyPort,
    this.availableRegions = defaultRegions,
    this.clientRegion,
    this.connectedServerRegion,
    this.selectedEgressRegion,
    this.errorMessage,
  });

  ConnectionStatus copyWith({
    ConnectionState? state,
    int? httpProxyPort,
    int? socksProxyPort,
    List<String>? availableRegions,
    String? clientRegion,
    String? connectedServerRegion,
    String? selectedEgressRegion,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ConnectionStatus(
      state: state ?? this.state,
      httpProxyPort: httpProxyPort ?? this.httpProxyPort,
      socksProxyPort: socksProxyPort ?? this.socksProxyPort,
      availableRegions: availableRegions ?? this.availableRegions,
      clientRegion: clientRegion ?? this.clientRegion,
      connectedServerRegion:
      connectedServerRegion ?? this.connectedServerRegion,
      selectedEgressRegion: selectedEgressRegion ?? this.selectedEgressRegion,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    state,
    httpProxyPort,
    socksProxyPort,
    availableRegions,
    clientRegion,
    connectedServerRegion,
    selectedEgressRegion,
    errorMessage,
  ];
}