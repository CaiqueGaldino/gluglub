import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oasis/app_widget.dart';
import 'package:oasis/controllers/agua_controller.dart';
import 'package:oasis/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar serviço de notificações
  final notificationService = NotificationService();
  await notificationService.init();


  await AndroidAlarmManager.initialize();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AguaController()),
    ],
    child: const AppWidget(),
  ));

  // Agendar notificações (verificar permissão primeiro)
  await _requestNotificationPermission();
  await notificationService.scheduleHourlyNotifications();


}
  Future<void> _requestNotificationPermission() async {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
      
  // Android: Não precisa de permissão explícita (API < 33)
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

