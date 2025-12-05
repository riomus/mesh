import 'package:flutter/material.dart';
import '../meshtastic/model/meshtastic_models.dart';
import '../services/telemetry_service.dart';

class TelemetryWidget extends StatelessWidget {
  final int nodeId;

  const TelemetryWidget({super.key, required this.nodeId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TelemetryPayloadDto>>(
      stream: TelemetryService.instance.historyStream(nodeId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final history = snapshot.data!;
        final latest = history.last;

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Telemetry',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (latest.deviceMetrics != null) ...[
                  _buildMetricRow(
                    'Battery',
                    '${latest.deviceMetrics!.batteryLevel}%',
                  ),
                  _buildMetricRow(
                    'Voltage',
                    '${latest.deviceMetrics!.voltage?.toStringAsFixed(2)} V',
                  ),
                  _buildMetricRow(
                    'Channel Util',
                    '${latest.deviceMetrics!.channelUtilization?.toStringAsFixed(1)}%',
                  ),
                  _buildMetricRow(
                    'Air Util Tx',
                    '${latest.deviceMetrics!.airUtilTx?.toStringAsFixed(1)}%',
                  ),
                ],
                if (latest.environmentMetrics != null) ...[
                  if (latest.environmentMetrics!.temperature != null)
                    _buildMetricRow(
                      'Temperature',
                      '${latest.environmentMetrics!.temperature?.toStringAsFixed(1)} °C',
                    ),
                  if (latest.environmentMetrics!.relativeHumidity != null)
                    _buildMetricRow(
                      'Humidity',
                      '${latest.environmentMetrics!.relativeHumidity?.toStringAsFixed(1)}%',
                    ),
                  if (latest.environmentMetrics!.barometricPressure != null)
                    _buildMetricRow(
                      'Pressure',
                      '${latest.environmentMetrics!.barometricPressure?.toStringAsFixed(1)} hPa',
                    ),
                ],
                if (latest.airQualityMetrics != null) ...[
                  if (latest.airQualityMetrics!.pm25Standard != null)
                    _buildMetricRow(
                      'PM2.5',
                      '${latest.airQualityMetrics!.pm25Standard}',
                    ),
                  if (latest.airQualityMetrics!.co2 != null)
                    _buildMetricRow(
                      'CO2',
                      '${latest.airQualityMetrics!.co2} ppm',
                    ),
                ],
                if (latest.powerMetrics != null) ...[
                  if (latest.powerMetrics!.ch1Voltage != null)
                    _buildMetricRow(
                      'Ch1 Voltage',
                      '${latest.powerMetrics!.ch1Voltage?.toStringAsFixed(2)} V',
                    ),
                ],
                const SizedBox(height: 8),
                Text(
                  'History: ${history.length} points',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
