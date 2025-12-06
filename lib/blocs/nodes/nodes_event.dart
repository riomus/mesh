import 'package:equatable/equatable.dart';
import '../../services/device_communication_event_service.dart'
    as service_event;

abstract class NodesEvent extends Equatable {
  const NodesEvent();

  @override
  List<Object?> get props => [];
}

class NodesEventReceived extends NodesEvent {
  final service_event.DeviceEvent event;

  const NodesEventReceived(this.event);

  @override
  List<Object?> get props => [event];
}

class NodesDistanceReferenceUpdated extends NodesEvent {
  final double? lat;
  final double? lon;

  const NodesDistanceReferenceUpdated({this.lat, this.lon});

  @override
  List<Object?> get props => [lat, lon];
}
