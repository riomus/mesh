import 'package:flutter/material.dart';
import '../meshtastic/model/meshtastic_models.dart';
import '../services/telemetry_service.dart';
import '../l10n/app_localizations.dart';

class TelemetryWidget extends StatelessWidget {
  final int nodeId;

  const TelemetryWidget({super.key, required this.nodeId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TelemetryPayloadDto>>(
      stream: TelemetryService.instance.historyStream(nodeId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(AppLocalizations.of(context).telemetryTitle),
              subtitle: Text(AppLocalizations.of(context).noTelemetryData),
            ),
          );
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
                  AppLocalizations.of(context).telemetryTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (latest.deviceMetrics != null) ...[
                  _buildMetricRow(
                    context,
                    AppLocalizations.of(context).telemetryBattery,
                    '${latest.deviceMetrics!.batteryLevel}%',
                  ),
                  _buildMetricRow(
                    context,
                    AppLocalizations.of(context).telemetryVoltage,
                    '${latest.deviceMetrics!.voltage?.toStringAsFixed(2)} V',
                  ),
                  _buildMetricRow(
                    context,
                    AppLocalizations.of(context).telemetryChannelUtil,
                    '${latest.deviceMetrics!.channelUtilization?.toStringAsFixed(1)}%',
                  ),
                  _buildMetricRow(
                    context,
                    AppLocalizations.of(context).telemetryAirUtilTx,
                    '${latest.deviceMetrics!.airUtilTx?.toStringAsFixed(1)}%',
                  ),
                ],
                if (latest.environmentMetrics != null) ...[
                  if (latest.environmentMetrics!.temperature != null)
                    _buildMetricRow(
                      context,
                      AppLocalizations.of(context).telemetryTemperature,
                      '${latest.environmentMetrics!.temperature?.toStringAsFixed(1)} °C',
                    ),
                  if (latest.environmentMetrics!.relativeHumidity != null)
                    _buildMetricRow(
                      context,
                      AppLocalizations.of(context).telemetryHumidity,
                      '${latest.environmentMetrics!.relativeHumidity?.toStringAsFixed(1)}%',
                    ),
                  if (latest.environmentMetrics!.barometricPressure != null)
                    _buildMetricRow(
                      context,
                      AppLocalizations.of(context).telemetryPressure,
                      '${latest.environmentMetrics!.barometricPressure?.toStringAsFixed(1)} hPa',
                    ),
                ],
                if (latest.airQualityMetrics != null) ...[
                  if (latest.airQualityMetrics!.pm25Standard != null)
                    _buildMetricRow(
                      context,
                      AppLocalizations.of(context).telemetryPm25,
                      '${latest.airQualityMetrics!.pm25Standard}',
                    ),
                  if (latest.airQualityMetrics!.co2 != null)
                    _buildMetricRow(
                      context,
                      AppLocalizations.of(context).telemetryCo2,
                      '${latest.airQualityMetrics!.co2} ppm',
                    ),
                ],
                if (latest.powerMetrics != null) ...[
                  if (latest.powerMetrics!.ch1Voltage != null)
                    _buildMetricRow(
                      context,
                      AppLocalizations.of(context).telemetryChVoltage(1),
                      '${latest.powerMetrics!.ch1Voltage?.toStringAsFixed(2)} V',
                    ),
                ],
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).telemetryHistory(history.length),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
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
