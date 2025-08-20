import 'package:flutter/material.dart';
import 'package:oasis/user_model.dart';
import 'package:oasis/constantes.dart';
import 'package:oasis/services/notification_service.dart';

class CadastroView extends StatefulWidget {
	const CadastroView({Key? key}) : super(key: key);

	@override
	State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
	final _formKey = GlobalKey<FormState>();
	double? _peso;
	String? _clima;
	String? _atividadeFisica;
	TimeOfDay? _horadeDormir;
	TimeOfDay? _horadeAcordar;

		double _calcularMeta(double peso, String clima, String atividadeFisica) {
			// Fórmula simples: meta = peso * 35 (ml) por dia
			double baseMeta = peso * 35;

			// Ajustes baseados no clima
			if (clima == "Quente") {
				baseMeta *= 1.1; // Aumenta 10% para clima quente
			}

			// Ajustes baseados na atividade física
			if (atividadeFisica == "Frequentemente") {
				baseMeta *= 1.2; // Aumenta 20% para atividade física frequente
			}

			return baseMeta;
		}

		Future<void> _submit(context) async {
			if (_formKey.currentState!.validate()) {
				_formKey.currentState!.save();
				double meta = _calcularMeta(_peso ?? 0, _clima ?? '', _atividadeFisica ?? '');
				UserModel user = UserModel(
					genero: '',
					peso: _peso ?? 0,
					clima: _clima == "Quente" ? 1 : 0,
					atividadeFisica: _atividadeFisica == "Raramente" ? 0 : _atividadeFisica == "As vezes" ? 1 : 2,
					meta: meta,
					horadeDormir: _horadeDormir,
					horadeAcordar: _horadeAcordar,
				);
				await user.salvar();
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('Cadastro realizado com sucesso!'), backgroundColor: Colors.green,),

				);

				// Agendar notificações
				await NotificationService().scheduleCustomNotifications(
				  horaAcorda: _horadeAcordar!.hour ?? 7,
				  horaDormir: _horadeDormir!.hour ?? 23,
				);
			}

      Navigator.of(context).pushReplacementNamed('/home');
		}

	Future<void> _pickTime(BuildContext context, bool dormir) async {
		final TimeOfDay? picked = await showTimePicker(
			context: context,
			initialTime: TimeOfDay.now(),
		);
		if (picked != null) {
			setState(() {
				if (dormir) {
					_horadeDormir = picked;
				} else {
					_horadeAcordar = picked;
				}
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: HydroPalette.pureWater,
			appBar: AppBar(
				title: Text('Cadastro'),
				backgroundColor: HydroPalette.deepOcean,
			),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Form(
					key: _formKey,
					child: ListView(
									children: [
										TextFormField(
											decoration: InputDecoration(labelText: 'Peso (kg)'),
											keyboardType: TextInputType.number,
											onSaved: (val) => _peso = double.tryParse(val ?? ''),
											validator: (val) => (val == null || double.tryParse(val) == null)
													? 'Informe o peso'
													: null,
										),
										DropdownButtonFormField<String>(
											decoration: InputDecoration(labelText: 'Clima'),
											items: ['Quente', 'Frio']
													.map((c) => DropdownMenuItem(value: c, child: Text(c)))
													.toList(),
											onChanged: (val) => setState(() => _clima = val),
											validator: (val) => val == null ? 'Selecione o clima' : null,
										),
										DropdownButtonFormField<String>(
											decoration: InputDecoration(labelText: 'Atividade Física'),
											items: ['Raramente', 'As vezes', 'Frequentimente']
													.map((a) => DropdownMenuItem(value: a, child: Text(a)))
													.toList(),
											onChanged: (val) => setState(() => _atividadeFisica = val),
											validator: (val) => val == null ? 'Selecione o nível de atividade física' : null,
										),
							ListTile(
								title: Text(_horadeDormir == null
										? 'Hora de Dormir'
										: 'Dormir: ${_horadeDormir!.format(context)}'),
								trailing: Icon(Icons.bedtime),
								onTap: () => _pickTime(context, true),
							),
							ListTile(
								title: Text(_horadeAcordar == null
										? 'Hora de Acordar'
										: 'Acordar: ${_horadeAcordar!.format(context)}'),
								trailing: Icon(Icons.wb_sunny),
								onTap: () => _pickTime(context, false),
							),
							SizedBox(height: 24),
							ElevatedButton(
								style: ElevatedButton.styleFrom(
									backgroundColor: HydroPalette.vitalGreen,
									foregroundColor: Colors.white,
									minimumSize: Size(double.infinity, 48),
								),
								onPressed: () => _submit(context),
								child: Text('Cadastrar'),
							),
						],
					),
				),
			),
		);
	}
}
