import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class AwesomeNotificationService {
  static final AwesomeNotificationService _instance = AwesomeNotificationService._internal();
  factory AwesomeNotificationService() => _instance;
  AwesomeNotificationService._internal();

  Future<void> init() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/ic_notification.png',
      [
        NotificationChannel(
          channelKey: 'water_reminder',
          channelName: 'Lembretes de Água',
          channelDescription: 'Notificações para lembrar de beber água',
          defaultColor: const Color(0xFF2196f3),
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          enableVibration: true,
          
        ),
      ],
      debug: false,
    );
  }

  Future<void> requestPermission() async {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  Future<void> scheduleWaterReminders({
    required int horaAcorda,
    required int horaDormir,
  }) async {
    await AwesomeNotifications().cancelAll();
    final messages = [
      "Hora de se hidratar! 💧 Seu corpo agradece",
      "Não esqueça da sua água! 💦 Está na hora",
      "Um gole agora vai te ajudar a manter o foco!",
      "Água = Energia! ⚡ Beba agora",
      "Seu lembrete amigável: hora da água!",
      "Manter-se hidratado é cuidar da saúde! 💙"
    ];
    final now = DateTime.now();
    for (int hour = horaAcorda; hour <= horaDormir; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
        final selectedMessage = messages[Random().nextInt(messages.length)];
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: hour * 100 + minute,
            channelKey: 'water_reminder',
            title: 'Hora da Água!',
            body: selectedMessage,
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar(
            year: scheduledDate.year,
            month: scheduledDate.month,
            day: scheduledDate.day,
            hour: scheduledDate.hour,
            minute: scheduledDate.minute,
            second: 0,
            repeats: true,
          ),
        );
      }
    }
  }
}
