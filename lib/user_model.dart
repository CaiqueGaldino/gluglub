import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  String genero;
  double peso;
  double? clima;
  double? atividadeFisica;
  num meta;
  TimeOfDay? horadeDormir;
  TimeOfDay? horadeAcordar;

  UserModel({
    required this.genero,
    required this.peso,
    required this.clima,
    required this.atividadeFisica,
    required this.meta,
    this.horadeDormir,
    this.horadeAcordar,
  });

  get getMeta => meta ?? 3000;

  /// Retorna o incremento do fill ao beber um copo de água (100ml)
  double incrementoCopo() {
    if (meta <= 0) return 0;
    return 100 / meta;
  }

  /// Retorna o incremento do fill ao beber uma garrafa de água (1000ml)
  double incrementoGarrafa() {
    if (meta <= 0) return 0;
    return 1000 / meta;
  }

  Map<String, dynamic> toMap() {
    return {
      'genero': genero,
      'peso': peso,
      'clima': clima,
      'atividadeFisica': atividadeFisica,
      'meta': meta,
      'horadeDormir': horadeDormir != null ? '${horadeDormir!.hour}:${horadeDormir!.minute}' : null,
      'horadeAcordar': horadeAcordar != null ? '${horadeAcordar!.hour}:${horadeAcordar!.minute}' : null,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    TimeOfDay? parseTime(String? value) {
      if (value == null) return null;
      final parts = value.split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return UserModel(
      genero: map['genero'],
      peso: map['peso'],
      clima: map['clima'],
      atividadeFisica: map['atividadeFisica'],
      meta: map['meta'] ?? 3000,
      horadeDormir: parseTime(map['horadeDormir']),
      horadeAcordar: parseTime(map['horadeAcordar']),
    );
  }

  Future<void> salvar() async {
    final prefs = await SharedPreferences.getInstance();
    final map = toMap();
    await prefs.setString('genero', map['genero']);
    await prefs.setDouble('peso', map['peso']);
    if (map['clima'] != null) await prefs.setDouble('clima', map['clima']);
    if (map['atividadeFisica'] != null) await prefs.setDouble('atividadeFisica', map['atividadeFisica']);
    await prefs.setDouble('meta', map['meta']);
    if (map['horadeDormir'] != null) await prefs.setString('horadeDormir', map['horadeDormir']);
    if (map['horadeAcordar'] != null) await prefs.setString('horadeAcordar', map['horadeAcordar']);
  }

  static Future<UserModel?> buscar() async {
    final prefs = await SharedPreferences.getInstance();
    final genero = prefs.getString('genero');
    final peso = prefs.getDouble('peso');
    final clima = prefs.getDouble('clima');
    final atividadeFisica = prefs.getDouble('atividadeFisica');
    final meta = prefs.getDouble('meta');
    final horadeDormir = prefs.getString('horadeDormir');
    final horadeAcordar = prefs.getString('horadeAcordar');
    if (genero == null || peso == null || meta == null) return null;
    return UserModel(
      genero: genero,
      peso: peso,
      clima: clima,
      atividadeFisica: atividadeFisica,
      meta: meta,
      horadeDormir: horadeDormir != null ? TimeOfDay(hour: int.parse(horadeDormir.split(':')[0]), minute: int.parse(horadeDormir.split(':')[1])) : null,
      horadeAcordar: horadeAcordar != null ? TimeOfDay(hour: int.parse(horadeAcordar.split(':')[0]), minute: int.parse(horadeAcordar.split(':')[1])) : null,
    );
  }
}