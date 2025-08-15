// notification_service.dart
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:random_string/random_string.dart';

class NotificationService {

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notificationsPlugin.initialize(settings);
  }

  Future<void> scheduleHourlyNotifications() async {
    // Mensagens aleatórias
    final messages = [
      "Hora de se hidratar! 💧 Seu corpo agradece",
      "Não esqueça da sua água! 💦 Está na hora",
      "Um gole agora vai te ajudar a manter o foco!",
      "Água = Energia! ⚡ Beba agora",
      "Seu lembrete amigável: hora da água!",
      "Manter-se hidratado é cuidar da saúde! 💙"
    ];

    // Configurar para disparar a cada hora
    for (int i = 0; i < 24; i++) {
      final selectedMessage = randomItem(messages);
      
      await notificationsPlugin.zonedSchedule(
        androidScheduleMode: AndroidScheduleMode.exact,
        i, // ID único para cada notificação
        'Hora da Água!',
        selectedMessage,
        _nextHour(DateTime.now().add(Duration(hours: i))),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminder',
            'Lembretes de Água',
            channelDescription: 'Notificações para lembrar de beber água',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    await notificationsPlugin.show(
      0,
      'Teste',
      'Notificação de teste',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder',
          'Lembretes de Água',
          channelDescription: 'Notificações para lembrar de beber água',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  tz.TZDateTime _nextHour(DateTime date) {
    final now = tz.TZDateTime.from(date, tz.local);
    return tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      now.hour,
      0, // Minuto zero
    );
  }

  T randomItem<T>(List<T> list) {
    final random = Random();
    return list[random.nextInt(list.length)];
  }
}