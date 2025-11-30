import 'package:flutter/material.dart';

import '../widgets/logs_viewer.dart';

/// Logs page that hosts the reusable LogsViewer component.
class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logs')),
      body: const LogsViewer(),
    );
  }
}