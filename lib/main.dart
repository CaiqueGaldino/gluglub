import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oasis/app_widget.dart';
import 'package:oasis/controllers/agua_controller.dart';
import 'package:oasis/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar AdMob
  await MobileAds.instance.initialize();

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
    child: const AdMobAppWidget(),
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

// Widget principal com AdMob
class AdMobAppWidget extends StatefulWidget {
  const AdMobAppWidget({Key? key}) : super(key: key);

  @override
  State<AdMobAppWidget> createState() => _AdMobAppWidgetState();
}

class _AdMobAppWidgetState extends State<AdMobAppWidget> {
  late BannerAd _bannerAd;
  bool _isBannerLoaded = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
  adUnitId: admobBannerId, // ID de teste oficial
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
  adUnitId: admobInterstitialId, 
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd?.show(); // Exibe ao abrir o app (exemplo)
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            const AppWidget(),
            if (_isBannerLoaded)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> solicitarPermissaoAlarme() async {
  if (Platform.isAndroid) {
    await Permission.scheduleExactAlarm.request();
  }
}
