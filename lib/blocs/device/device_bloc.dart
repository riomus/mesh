import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/device_state.dart';
import '../../services/device_state_service.dart';
import '../../services/logging_service.dart';
import 'device_event.dart';
import 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DevicesState> {
  StreamSubscription? _subscription;

  DeviceBloc() : super(const DevicesState()) {
    on<DeviceStateUpdated>(_onDeviceStateUpdated);

    _init();
  }

  void _init() {
    // Initialize with any existing states from the service
    final existingStates = DeviceStateService.instance.allStates;
    if (existingStates.isNotEmpty) {
      LoggingService.instance.push(
        tags: {'class': 'DeviceBloc'},
        level: 'info',
        message:
            'Initializing DeviceBloc with ${existingStates.length} existing device state(s)',
      );
      // Add events for all existing device states
      for (final deviceState in existingStates.values) {
        add(DeviceStateUpdated(deviceState));
      }
    }

    // Then subscribe to future updates
    _subscription = DeviceStateService.instance.streamAll.listen(
      (state) => add(DeviceStateUpdated(state)),
      onError: (e, s) {
        LoggingService.instance.push(
          tags: {'class': 'DeviceBloc'},
          level: 'error',
          message: 'Error in DeviceBloc subscription: $e',
        );
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void _onDeviceStateUpdated(
    DeviceStateUpdated event,
    Emitter<DevicesState> emit,
  ) {
    final newDeviceStates = Map<String, DeviceState>.from(state.deviceStates);
    newDeviceStates[event.state.deviceId] = event.state;
    emit(state.copyWith(deviceStates: newDeviceStates));
  }
}
