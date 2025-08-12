import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oasis/user_model.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

class AguaController extends ChangeNotifier {
  double fill = 0.0;
  double consumo = 0.0;
  UserModel? usuario;
  Map<DateTime, double> consumoDiario = {};

  Future<void> carregarUsuario() async {
    usuario = await UserModel.buscar();
    await carregarConsumoDiario();
    notifyListeners();
  }

  void beberCopo() async {
    if (usuario == null) return;
    consumo += 100;
    fill = consumo / usuario!.meta;
    if (fill > 1) fill = 1;
    _atualizarConsumoDiario(100);
    await _salvarConsumoAtualDoDia();
    notifyListeners();
  }

  void beberGarrafa() async {
    if (usuario == null) return;
    consumo += 1000;
    fill = consumo / usuario!.meta;
    if (fill > 1) fill = 1;
    _atualizarConsumoDiario(1000);
    await _salvarConsumoAtualDoDia();
    notifyListeners();
  }

  // Renomeado para salvar o histórico diário completo (para o alarme)
  Future<void> _salvarHistoricoConsumoParaAlarme() async {
    final prefs = await SharedPreferences.getInstance();
    final hoje = DateTime.now();
    final dataKey = "${hoje.year}-${hoje.month}-${hoje.day}";
    final meta = usuario?.meta ?? 0.0;

    // Recupera lista existente ou cria nova
    final historico = prefs.getStringList('historico') ?? [];

    // Cria registro do dia: [data, consumo, meta]
    final registro = [
      DateTime(hoje.year, hoje.month, hoje.day).toIso8601String(),
      consumo.toString(),
      meta.toString(),
    ];

    // Adiciona registro à lista
    historico.add(registro.join(','));

    // Salva lista atualizada
    await prefs.setStringList('historico', historico);

    // Zera o consumo e fill para o novo dia
    consumo = 0.0;
    fill = 0.0;
    notifyListeners();
  }

  Future<List<List<String>>> carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final historico = prefs.getStringList('historico') ?? [];
    // Converte cada registro em lista [data, consumo, meta]
    return historico.map((e) => e.split(',')).toList();
  }

  Future<void> agendarConsumoDiario() async {
    final now = DateTime.now();
    final proximaMeiaNoite = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    final duration = proximaMeiaNoite.difference(now);

    await AndroidAlarmManager.oneShot(
      duration,
      // ID único para o alarm
      1, // Usar um ID diferente para este alarme
      _salvarHistoricoConsumoParaAlarme,
      exact: true,
      wakeup: true,
    );
  }

  Future<void> carregarConsumoDiario() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    // Filtrar chaves para pegar apenas as que começam com 'consumoDiario_'
    final consumoKeys = keys.where((key) => key.startsWith('consumoDiario_')).toList();

    for (var key in consumoKeys) {
      // Extrair a data da chave
      final dataString = key.substring('consumoDiario_'.length);
      final data = DateTime.tryParse(dataString);

      if (data != null) {
        // Normaliza a data para apenas ano, mês e dia para a chave do mapa
        final normalizedData = DateTime(data.year, data.month, data.day);
        consumoDiario[normalizedData] = prefs.getDouble(key) ?? 0.0;
      }
    }
    // Carrega o consumo do dia atual se existir
    final hoje = DateTime.now();
    final hojeNormalizado = DateTime(hoje.year, hoje.month, hoje.day);
    consumo = consumoDiario[hojeNormalizado] ?? 0.0;
    notifyListeners();
  }

  // Salva o consumo atual do dia no SharedPreferences
  Future<void> _salvarConsumoAtualDoDia() async {
    final prefs = await SharedPreferences.getInstance();
    final hoje = DateTime.now();
    final hojeNormalizado = DateTime(hoje.year, hoje.month, hoje.day);
    await prefs.setDouble('consumoDiario_${hojeNormalizado.toIso8601String().split('T').first}', consumoDiario[hojeNormalizado] ?? 0.0);
  }

  // Atualiza o mapa de consumo diário
  void _atualizarConsumoDiario(double quantidade) {
    final hoje = DateTime.now();
    final hojeNormalizado = DateTime(hoje.year, hoje.month, hoje.day);
    consumoDiario[hojeNormalizado] = (consumoDiario[hojeNormalizado] ?? 0.0) + quantidade;
  }

  // Limpa todos os dados de consumo diário persistidos (para testes ou redefinição)
  Future<void> limparConsumoDiario() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final consumoKeys = keys.where((key) => key.startsWith('consumoDiario_')).toList();
    for (var key in consumoKeys) {
      await prefs.remove(key);
    }
    consumoDiario.clear();
    consumo = 0.0;
    fill = 0.0;
  }
}
  

