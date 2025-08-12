import 'package:flutter/material.dart';
import 'package:oasis/views/home.dart';
import 'package:oasis/views/cadastro.dart';
import 'package:oasis/user_model.dart';
class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  String _initialRoute = '/loading';

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final user = await UserModel.buscar();
    setState(() {
      _initialRoute = user == null ? '/cadastro' : '/home';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    if (_initialRoute == '/loading') {
      page = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (_initialRoute == '/cadastro') {
      page = const CadastroView();
    } else {
      page = const Home();
    }

    return MaterialApp(
      title: 'Oasis',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: false,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
      home: page,
      routes: {
        '/home': (context) => const Home(),
        '/cadastro': (context) => const CadastroView(),
      },
    );
  }
}