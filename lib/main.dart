import 'package:flutter/material.dart';
import 'package:mesh/services/notification_service.dart';
import 'package:mesh/services/message_routing_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  // Initialize MessageRoutingService to start listening for messages globally
  // ignore: unnecessary_statements
  MessageRoutingService.instance;

  runApp(const MyApp());
}
