import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Necesario para formatear los números.

class PieChartWidget extends StatelessWidget {
  final double ingresos;
  final double gastosComunes;
  final double gastosServicios;
  final double gastosHormiga;

  const PieChartWidget({
    Key? key,
    required this.ingresos,
    required this.gastosComunes,
    required this.gastosServicios,
    required this.gastosHormiga,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalGastos = gastosComunes + gastosServicios + gastosHormiga;
    final restante = ingresos.toInt() - totalGastos.toInt(); // Calcula el restante como entero.

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Distribución de Ingresos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // Altura del gráfico
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Total Restante:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${_formatearNumero(restante)}', // Muestra el dinero restante con puntos.
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final totalGastos = gastosComunes + gastosServicios + gastosHormiga;
    final restante = ingresos - totalGastos; // Calcula el monto restante.

    if (ingresos == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: '', // Ocultar título del segmento
          radius: 50,
        ),
      ];
    }

    return [
      PieChartSectionData(
        color: Colors.green,
        value: restante > 0 ? restante : 0, // Si el restante es negativo, se muestra como 0.
        title: '', // Ocultar título del segmento
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.red,
        value: gastosComunes,
        title: '', // Ocultar título del segmento
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: gastosServicios,
        title: '', // Ocultar título del segmento
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: gastosHormiga,
        title: '', // Ocultar título del segmento
        radius: 50,
      ),
    ];
  }

  // Función para formatear números con separador de miles.
  String _formatearNumero(int numero) {
    final formatter = NumberFormat.decimalPattern('es'); // Configura el formato para español.
    return formatter.format(numero);
  }
}
