import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/login_form.dart';
import 'screens/ingresos_usuario.dart';
import 'screens/gastos_comunes.dart';
import 'screens/gastos_servicios.dart';
import 'screens/gastos_hormigas.dart';
import 'screens/crear_usuario.dart';
import 'screens/configuracion.dart'; // Importar la pantalla de configuración

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginForm(),
        '/crear-usuario': (context) => CrearUsuario(),
        '/ingreso-usuario': (context) => IngresosUsuario(),
        '/gastos-comunes': (context) => GastosComunes(),
        '/gastos-servicios': (context) => GastosServicios(),
        '/gastos-hormiga': (context) => GastosHormiga(),
        '/configuracion': (context) => ConfiguracionScreen(), // Registrar configuración
      },
    );
  }
}



