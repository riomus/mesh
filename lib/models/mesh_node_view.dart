import 'package:equatable/equatable.dart';
import '../meshtastic/model/meshtastic_models.dart';

class MeshNodeView extends Equatable {
  final NodeNum? num;
  final UserDto? user;
  final PositionDto? position;
  final double? snr;
  final int? lastHeard;
  final DeviceMetricsDto? deviceMetrics;
  final int? hopsAway;
  final bool? isFavorite;
  final bool? isIgnored;
  final bool? viaMqtt;
  final Map<String, List<String>> tags;

  const MeshNodeView({
    this.num,
    this.user,
    this.position,
    this.snr,
    this.lastHeard,
    this.deviceMetrics,
    this.hopsAway,
    this.isFavorite,
    this.isIgnored,
    this.viaMqtt,
    this.tags = const {},
  });

  String get displayName {
    if (user?.longName != null && user!.longName!.isNotEmpty) {
      return user!.longName!;
    }
    if (user?.shortName != null && user!.shortName!.isNotEmpty) {
      return user!.shortName!;
    }
    if (num != null) {
      return '0x${num!.toRadixString(16).toLowerCase()}';
    }
    return 'Unknown';
  }

  @override
  List<Object?> get props => [
    num,
    user,
    position,
    snr,
    lastHeard,
    deviceMetrics,
    hopsAway,
    isFavorite,
    isIgnored,
    viaMqtt,
    tags,
  ];
}
