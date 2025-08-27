import 'package:equatable/equatable.dart';

enum ConnectionState {
  disconnected,
  connecting,
  connected,
  stopping,
  error,
}

class ConnectionStatus extends Equatable {
  final ConnectionState state;
  final int? httpProxyPort;
  final int? socksProxyPort;
  final List<String> availableRegions;
  final String? clientRegion;
  final String? connectedServerRegion; // <-- Add this new field
  final String? errorMessage;

  const ConnectionStatus({
    this.state = ConnectionState.disconnected,
    this.httpProxyPort,
    this.socksProxyPort,
    this.availableRegions = const [],
    this.clientRegion,
    this.connectedServerRegion, // <-- Add to constructor
    this.errorMessage,
  });

  ConnectionStatus copyWith({
    ConnectionState? state,
    int? httpProxyPort,
    int? socksProxyPort,
    List<String>? availableRegions,
    String? clientRegion,
    String? connectedServerRegion, // <-- Add to copyWith
    String? errorMessage,
    bool clearError = false,
  }) {
    return ConnectionStatus(
      state: state ?? this.state,
      httpProxyPort: httpProxyPort ?? this.httpProxyPort,
      socksProxyPort: socksProxyPort ?? this.socksProxyPort,
      availableRegions: availableRegions ?? this.availableRegions,
      clientRegion: clientRegion ?? this.clientRegion,
      connectedServerRegion: connectedServerRegion ?? this.connectedServerRegion, // <--
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
    connectedServerRegion, // <-- Add to props
    errorMessage,
  ];
}