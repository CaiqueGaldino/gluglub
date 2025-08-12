import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:oasis/constantes.dart';

class Historico extends StatelessWidget {
  
  final Map<DateTime, double> consumoDiario;
  final double meta;

  const Historico({required this.consumoDiario, required this.meta, super.key});

  @override
  Widget build(BuildContext context){
    return Container(
      child: HeatMapCalendar(
        defaultColor: HydroPalette.cloudWhite,
        flexible: true,
        showColorTip: true,
        colorMode: ColorMode.color,
        datasets: _gerarDatasets(consumoDiario, meta),
        colorsets: {
        0: HydroPalette.blueUltraLight,
        1: HydroPalette.blueExtraLight,
        2: HydroPalette.blueLight,
        3: HydroPalette.blueMid,
        4: HydroPalette.blueSoft,
      },),
    );
  }
}

Map<DateTime, int> _gerarDatasets(Map<DateTime, double> consumoDiario, double meta) {
    Map<DateTime, int> datasets = {};
    consumoDiario.forEach((data, consumo) {
      double porcentagem = (consumo / meta) * 100;
      int valor;
      if (porcentagem <= 20) {
        valor = 0;
      } else if (porcentagem <= 40) {
        valor = 1;
      } else if (porcentagem <= 60) {
        valor = 2;
      } else if (porcentagem <= 80) {
        valor = 3;
      } else {
        valor = 4;
      }
      datasets[data] = valor;
    });
    return datasets;}