import 'package:bonsoir_platform_interface/src/service/service.dart';

/// Represents a resolved Bonsoir service.
class ResolvedBonsoirService extends BonsoirService {
  /// The service host.
  final String? host;

  /// Creates a new resolved Bonsoir service.
  const ResolvedBonsoirService({
    required super.name,
    required super.type,
    required super.port,
    super.attributes,
    required this.host,
  });

  /// Creates a new resolved Bonsoir service instance from the given JSON map.
  ResolvedBonsoirService.fromJson(
    Map<String, dynamic> json, {
    String prefix = 'service.',
  }) : this(
          name: json['${prefix}name'],
          type: _filterType(json['${prefix}type']),
          port: json['${prefix}port'],
          attributes: Map<String, String>.from(json['${prefix}attributes']),
          host: json['${prefix}host'],
        );

  @override
  Map<String, dynamic> toJson({String prefix = 'service.'}) => super.toJson(prefix: prefix)..['${prefix}host'] = host;

  @override
  bool operator ==(dynamic other) {
    if (other is! ResolvedBonsoirService) {
      return false;
    }
    return super == other && host == other.host;
  }

  @override
  int get hashCode => super.hashCode + (host?.hashCode ?? -1);

  /// Filters a service type (because problems can occur when running a broadcast and a discovery on the same device).
  static String _filterType(String type) {
    if (type.startsWith('._')) {
      type = type.substring(1);
    }
    if (type.endsWith('_tcp.') || type.endsWith('_udp.')) {
      type = type.substring(0, type.length - 1);
    }
    return type;
  }
}
