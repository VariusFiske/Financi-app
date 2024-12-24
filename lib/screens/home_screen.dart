import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../widgets/navbar.dart';
import '../utils/pie_chart_widget.dart'; // Importa el widget del gráfico

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalIngresosUsuario = 0;
  int _totalGastosComunes = 0;
  int _totalGastosServicios = 0;
  int _totalGastosHormiga = 0;

  bool _isLoading = true;
  String _errorMessage = '';

  final _currencyFormat = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchTotals();
  }

  Future<void> _fetchTotals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado.');
      }

      final userId = user.uid;

      final ingresosSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('ingresos_usuario')
          .get();

      final gastosComunesSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('gastos_comunes')
          .get();

      final gastosServiciosSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('gastos_servicios')
          .get();

      final gastosHormigaSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('gastos_hormiga')
          .get();

      int ingresosTotal = 0;
      int comunesTotal = 0;
      int serviciosTotal = 0;
      int hormigaTotal = 0;

      for (var doc in ingresosSnapshot.docs) {
        if (doc.data().containsKey('monto')) {
          ingresosTotal += _parseMonto(doc.data()['monto']).toInt();
        }
      }
      for (var doc in gastosComunesSnapshot.docs) {
        if (doc.data().containsKey('monto')) {
          comunesTotal += _parseMonto(doc.data()['monto']).toInt();
        }
      }
      for (var doc in gastosServiciosSnapshot.docs) {
        if (doc.data().containsKey('monto')) {
          serviciosTotal += _parseMonto(doc.data()['monto']).toInt();
        }
      }
      for (var doc in gastosHormigaSnapshot.docs) {
        if (doc.data().containsKey('monto')) {
          hormigaTotal += _parseMonto(doc.data()['monto']).toInt();
        }
      }

      setState(() {
        _totalIngresosUsuario = ingresosTotal;
        _totalGastosComunes = comunesTotal;
        _totalGastosServicios = serviciosTotal;
        _totalGastosHormiga = hormigaTotal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al obtener los datos: $e';
      });
    }
  }

  double _parseMonto(dynamic monto) {
    if (monto == null) return 0.0;
    try {
      if (monto is int) {
        return monto.toDouble();
      } else if (monto is double) {
        return monto;
      } else if (monto is String) {
        return double.parse(monto);
      }
      return 0.0;
    } catch (e) {
      print('Error al convertir monto: $monto - $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Gastos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      ),
      drawer: Navbar(),
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSection(
                        context,
                        title: 'Ingresos Usuario',
                        icon: Icons.monetization_on,
                        color: Colors.green,
                        total: _totalIngresosUsuario,
                        routeName: '/ingreso-usuario',
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        title: 'Gastos Comunes',
                        icon: Icons.home,
                        color: Colors.red,
                        total: _totalGastosComunes,
                        routeName: '/gastos-comunes',
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        title: 'Gastos Servicios',
                        icon: Icons.wifi,
                        color: Colors.blue,
                        total: _totalGastosServicios,
                        routeName: '/gastos-servicios',
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        title: 'Gastos Hormiga',
                        icon: Icons.shopping_cart,
                        color: Colors.orange,
                        total: _totalGastosHormiga,
                        routeName: '/gastos-hormiga',
                      ),
                      const SizedBox(height: 24),
                      // Aquí usamos el PieChartWidget
                      PieChartWidget(
                        ingresos: _totalIngresosUsuario.toDouble(),
                        gastosComunes: _totalGastosComunes.toDouble(),
                        gastosServicios: _totalGastosServicios.toDouble(),
                        gastosHormiga: _totalGastosHormiga.toDouble(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required int total,
    required String routeName,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title),
          trailing: Text(
            _currencyFormat.format(total),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
