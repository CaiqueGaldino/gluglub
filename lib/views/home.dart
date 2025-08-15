import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:oasis/constantes.dart';
import 'package:oasis/views/historico.dart';
import 'package:provider/provider.dart';
import 'package:water_animation/water_animation.dart';
import '../controllers/agua_controller.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

Size resolution = Size.zero;

_showHistorico(context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: SizedBox(
          width: double.infinity,
          height: 400,
          child: Consumer<AguaController>(
            builder: (context, agua, child) => Historico(
              consumoDiario: agua.consumoDiario,
              meta: agua.usuario!.meta.toDouble(),
            ),
          ),
        ),
      );
    },
  );
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.microtask(
      () =>
          Provider.of<AguaController>(context, listen: false).carregarUsuario(),
    );
  }

  @override
  Widget build(BuildContext context) {
    resolution = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: HydroPalette.freshBlue,
      body: Consumer<AguaController>(
        builder: (context, agua, child) {
          if (agua.usuario == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              SizedBox(
                width: resolution.width,
                height: resolution.height,
                child: WaterAnimation(
                  width: resolution.width,
                  height: resolution.height,
                  waterFillFraction: agua.fill,
                  fillTransitionDuration: Duration(seconds: 1),
                  fillTransitionCurve: Curves.easeInOut,
                  amplitude: 20,
                  frequency: 1,
                  speed: 3,
                  waterColor: Colors.blue,
                  gradientColors: [Colors.blue, Colors.lightBlueAccent],
                  enableRipple: true,
                  enableShader: false,
                  enableSecondWave: true,
                  secondWaveColor: Colors.blueAccent,
                  secondWaveAmplitude: 10.0,
                  secondWaveFrequency: 1.5,
                  secondWaveSpeed: 1.0,
                  realisticWave: true,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${((agua.consumo * 100) / agua.usuario!.meta).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.3),
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${agua.consumo.toStringAsFixed(0)} ml',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.3),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        fanAngle: 100,

        pos: ExpandableFabPos.center,
        margin: EdgeInsets.all(24),
        children: [
          FloatingActionButton(
            backgroundColor: HydroPalette.freshBlue,
            heroTag: 'fab_copo',
            child: const Icon(Icons.water_drop),
            onPressed: () =>
                Provider.of<AguaController>(context, listen: false).beberCopo(),
          ),
          FloatingActionButton(
            backgroundColor: HydroPalette.freshBlue,
            heroTag: 'fab_garrafa',
            child: const Icon(Icons.water),
            onPressed: () => Provider.of<AguaController>(
              context,
              listen: false,
            ).beberGarrafa(),
          ),
          FloatingActionButton(
            backgroundColor: HydroPalette.freshBlue,

            onPressed: () => _showHistorico(context),
            child: const Icon(Icons.history),
          ),
        ],
      ),
    );
  }
}
