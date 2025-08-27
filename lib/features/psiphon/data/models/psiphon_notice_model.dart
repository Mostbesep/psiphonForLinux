import 'package:equatable/equatable.dart';

/// A base class for all notices coming from the Psiphon process.
/// Using a sealed-like structure with a factory constructor helps in parsing.
abstract class PsiphonNotice extends Equatable {
  const PsiphonNotice();

  /// Factory constructor to parse the incoming JSON and create the correct
  /// notice object based on the 'noticeType' field.
  factory PsiphonNotice.fromJson(Map<String, dynamic> json) {
    final noticeType = json['noticeType'] as String?;
    final data = json['data'] as Map<String, dynamic>? ?? {};

    switch (noticeType) {
    // ... (other cases remain the same) ...
      case 'ListeningHttpProxyPort':
        return ListeningHttpProxyPortNotice.fromData(data);
      case 'ListeningSocksProxyPort':
        return ListeningSocksProxyPortNotice.fromData(data);
      case 'Tunnels':
        return TunnelsNotice.fromData(data);
      case 'AvailableEgressRegions':
        return AvailableEgressRegionsNotice.fromData(data);
      case 'ClientRegion':
        return ClientRegionNotice.fromData(data);
      case 'SkipServerEntry':
        return SkipServerEntryNotice.fromData(data);
    // Add the new case
      case 'ConnectedServerRegion':
        return ConnectedServerRegionNotice.fromData(data);
      case 'Exiting':
        return const ExitingNotice();
      default:
        return GenericNotice(noticeType: noticeType ?? 'Unknown', data: data);
    }
  }

  @override
  List<Object?> get props => [];
}

// --- Specific Notice Models ---


class ConnectedServerRegionNotice extends PsiphonNotice {
  final String region;
  const ConnectedServerRegionNotice({required this.region});

  factory ConnectedServerRegionNotice.fromData(Map<String, dynamic> data) {
    return ConnectedServerRegionNotice(region: data['serverRegion'] as String);
  }
  @override
  List<Object?> get props => [region];
}

class ListeningHttpProxyPortNotice extends PsiphonNotice {
  final int port;
  const ListeningHttpProxyPortNotice({required this.port});

  factory ListeningHttpProxyPortNotice.fromData(Map<String, dynamic> data) {
    return ListeningHttpProxyPortNotice(port: data['port'] as int);
  }

  @override
  List<Object?> get props => [port];
}

class ListeningSocksProxyPortNotice extends PsiphonNotice {
  final int port;
  const ListeningSocksProxyPortNotice({required this.port});

  factory ListeningSocksProxyPortNotice.fromData(Map<String, dynamic> data) {
    return ListeningSocksProxyPortNotice(port: data['port'] as int);
  }

  @override
  List<Object?> get props => [port];
}

class TunnelsNotice extends PsiphonNotice {
  final int count;
  const TunnelsNotice({required this.count});

  factory TunnelsNotice.fromData(Map<String, dynamic> data) {
    return TunnelsNotice(count: data['count'] as int);
  }

  @override
  List<Object?> get props => [count];
}

class AvailableEgressRegionsNotice extends PsiphonNotice {
  final List<String> regions;
  const AvailableEgressRegionsNotice({required this.regions});

  factory AvailableEgressRegionsNotice.fromData(Map<String, dynamic> data) {
    final regionsList = (data['regions'] as List).cast<String>();
    return AvailableEgressRegionsNotice(regions: regionsList);
  }

  @override
  List<Object?> get props => [regions];
}

class ClientRegionNotice extends PsiphonNotice {
  final String region;
  const ClientRegionNotice({required this.region});

  factory ClientRegionNotice.fromData(Map<String, dynamic> data) {
    return ClientRegionNotice(region: data['region'] as String);
  }
  @override
  List<Object?> get props => [region];
}

class SkipServerEntryNotice extends PsiphonNotice {
  final String reason;
  const SkipServerEntryNotice({required this.reason});

  factory SkipServerEntryNotice.fromData(Map<String, dynamic> data) {
    return SkipServerEntryNotice(reason: data['reason'] as String);
  }
  @override
  List<Object?> get props => [reason];
}

class ExitingNotice extends PsiphonNotice {
  const ExitingNotice();
}

/// A fallback for any notice types we don't explicitly handle.
class GenericNotice extends PsiphonNotice {
  final String noticeType;
  final Map<String, dynamic> data;
  const GenericNotice({required this.noticeType, required this.data});

  @override
  List<Object?> get props => [noticeType, data];
}
