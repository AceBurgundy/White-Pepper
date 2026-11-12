import 'package:flutter/foundation.dart';

enum ScannerConnectionType {
  wifi(label: 'Wi-Fi'),
  usb(label: 'USB');

  const ScannerConnectionType({required this.label});

  final String label;

  static ScannerConnectionType fromString(String value) {
    if (value.toLowerCase().trim() == 'usb') {
      return ScannerConnectionType.usb;
    }
    return ScannerConnectionType.wifi;
  }
}

@immutable
class ScannerDeviceModel {
  const ScannerDeviceModel({
    required this.id,
    required this.name,
    required this.connectionType,
    this.host = '',
    this.port = 0,
    this.deviceId = '',
    this.isOnline = true,
  });

  final String id;
  final String name;
  final ScannerConnectionType connectionType;
  final String host;
  final int port;
  final String deviceId;
  final bool isOnline;

  String get connectionLabel => connectionType.label;

  factory ScannerDeviceModel.fromJson(Map<String, dynamic> json) {
    final String transportStr = (json['transport'] as String?) ?? 'wifi';
    return ScannerDeviceModel(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? 'Scanner',
      connectionType: ScannerConnectionType.fromString(transportStr),
      host: (json['host'] as String?) ?? '',
      port: (json['port'] as num?)?.toInt() ?? 0,
      deviceId: (json['device_id'] as String?) ?? '',
      isOnline: (json['reachable'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'transport': connectionType == ScannerConnectionType.usb ? 'usb' : 'wifi',
      'host': host,
      'port': port,
      'device_id': deviceId,
      'reachable': isOnline,
    };
  }

  ScannerDeviceModel copyWith({
    String? id,
    String? name,
    ScannerConnectionType? connectionType,
    String? host,
    int? port,
    String? deviceId,
    bool? isOnline,
  }) {
    return ScannerDeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      connectionType: connectionType ?? this.connectionType,
      host: host ?? this.host,
      port: port ?? this.port,
      deviceId: deviceId ?? this.deviceId,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScannerDeviceModel &&
        other.id == id &&
        other.name == name &&
        other.connectionType == connectionType &&
        other.host == host &&
        other.port == port &&
        other.deviceId == deviceId &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        connectionType,
        host,
        port,
        deviceId,
        isOnline,
      );

  @override
  String toString() =>
      'ScannerDeviceModel(id: $id, name: $name, type: ${connectionType.label}, online: $isOnline)';
}
