import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:oasis/app_widget.dart';
import 'package:oasis/controllers/agua_controller.dart';
import 'package:oasis/services/awesome_notification_service.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'keys.dart';

// Funções para obtenção dos horários do usuário
Future<int> obterHoraAcordaDoUsuario() async {
  final prefs = await SharedPreferences.getInstance();
  final hora = prefs.getInt('horaAcorda');
  return hora ?? 7;
}

Future<int> obterHoraDormirDoUsuario() async {
  final prefs = await SharedPreferences.getInstance();
  final hora = prefs.getInt('horaDormir');
  return hora ?? 22;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar AdMob
  await MobileAds.instance.initialize();

  // Inicializar serviço de notificações
  final awesomeNotificationService = AwesomeNotificationService();
  await awesomeNotificationService.init();
  await awesomeNotificationService.requestPermission();
  int horaAcorda = await obterHoraAcordaDoUsuario();
  int horaDormir = await obterHoraDormirDoUsuario();
  await awesomeNotificationService.scheduleWaterReminders(horaAcorda: horaAcorda, horaDormir: horaDormir);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AguaController()),
      ],
      child: const AdMobAppWidget(),
    ),
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
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                _interstitialAd = null;
                // Aqui você pode liberar os botões de ação
              });
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              setState(() {
                _interstitialAd = null;
              });
            },
          );
          _interstitialAd = ad;
          _interstitialAd?.show();
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


