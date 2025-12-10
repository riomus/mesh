import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../meshtastic/config_resources.dart';
import 'config_help_button.dart';

/// Helper functions for building form fields for configuration editing
class ConfigFormHelpers {
  /// Creates a text field for String values
  static Widget buildTextField({
    required String label,
    required String? value,
    required ValueChanged<String> onChanged,
    String? hint,
    int? maxLines,
    bool obscureText = false,
    String? configKey,
  }) {
    final description = configKey != null
        ? ConfigResources.getDescription(configKey)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value ?? '',
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixIcon: description != null
              ? ConfigHelpButton(description: description)
              : null,
        ),
        maxLines: obscureText ? 1 : (maxLines ?? 1),
        obscureText: obscureText,
        onChanged: onChanged,
      ),
    );
  }

  /// Creates a text field for integer values
  static Widget buildIntField({
    required String label,
    required int? value,
    required ValueChanged<int?> onChanged,
    int? min,
    int? max,
    String? hint,
    String? configKey,
  }) {
    final description = configKey != null
        ? ConfigResources.getDescription(configKey)
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value?.toString() ?? '',
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          helperText: min != null && max != null
              ? 'Range: $min - $max'
              : min != null
              ? 'Min: $min'
              : max != null
              ? 'Max: $max'
              : null,
          suffixIcon: description != null
              ? ConfigHelpButton(description: description)
              : null,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (val) {
          if (val.isEmpty) {
            onChanged(null);
            return;
          }
          final parsed = int.tryParse(val);
          if (parsed != null) {
            if ((min == null || parsed >= min) &&
                (max == null || parsed <= max)) {
              onChanged(parsed);
            }
          }
        },
      ),
    );
  }

  /// Creates a text field for double values
  static Widget buildDoubleField({
    required String label,
    required double? value,
    required ValueChanged<double?> onChanged,
    double? min,
    double? max,
    String? hint,
    String? configKey,
  }) {
    final description = configKey != null
        ? ConfigResources.getDescription(configKey)
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value?.toString() ?? '',
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          helperText: min != null && max != null
              ? 'Range: $min - $max'
              : min != null
              ? 'Min: $min'
              : max != null
              ? 'Max: $max'
              : null,
          suffixIcon: description != null
              ? ConfigHelpButton(description: description)
              : null,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        onChanged: (val) {
          if (val.isEmpty) {
            onChanged(null);
            return;
          }
          final parsed = double.tryParse(val);
          if (parsed != null) {
            if ((min == null || parsed >= min) &&
                (max == null || parsed <= max)) {
              onChanged(parsed);
            }
          }
        },
      ),
    );
  }

  /// Creates a checkbox for boolean values
  static Widget buildCheckbox({
    required String label,
    required bool? value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
    String? configKey,
  }) {
    final description = configKey != null
        ? ConfigResources.getDescription(configKey)
        : null;

    return CheckboxListTile(
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value ?? false,
      onChanged: (val) => onChanged(val ?? false),
      secondary: description != null
          ? ConfigHelpButton(description: description)
          : null,
    );
  }

  /// Creates a dropdown for enum values (string-based)
  static Widget buildEnumDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String? hint,
    String? configKey,
  }) {
    final description = configKey != null
        ? ConfigResources.getDescription(configKey)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value != null && options.contains(value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixIcon: description != null
              ? ConfigHelpButton(description: description)
              : null,
        ),
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  /// Creates a section header
  static Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Creates a divider
  static Widget buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(),
    );
  }
}
