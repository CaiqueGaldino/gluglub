import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oasis/app_widget.dart';
import 'package:oasis/controllers/agua_controller.dart';
import 'package:oasis/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar serviço de notificações
  final notificationService = NotificationService();
  await notificationService.init();

  // Solicitar permissão antes de agendar notificações
  await _requestNotificationPermission();
  await solicitarPermissaoAlarme();

  // Agendar notificações
  try {
    await notificationService.scheduleHourlyNotifications();
  } catch (e) {
    print('Erro ao agendar notificações: $e');
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AguaController()),
    ],
    child: const AppWidget(),
  ));
}

Future<void> _requestNotificationPermission() async {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isAndroid) {
    // Para Android 13+ (API 33+)
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // iOS: Solicitar permissão
  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}


Future<void> solicitarPermissaoAlarme() async {
  if (Platform.isAndroid) {
    await Permission.scheduleExactAlarm.request();
  }
}
