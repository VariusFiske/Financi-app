import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GastosComunes extends StatefulWidget {
  const GastosComunes({super.key});

  @override
  _GastosComunesState createState() => _GastosComunesState();
}

class _GastosComunesState extends State<GastosComunes> {
  final TextEditingController _luzController = TextEditingController();
  final TextEditingController _aguaController = TextEditingController();
  final TextEditingController _gasController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _totalGastos = 0; // Variable para el total de gastos

  @override
  void initState() {
    super.initState();
    _cargarDatosGuardados();
  }

  void _cargarDatosGuardados() async {
    final User? usuarioActual = _auth.currentUser;

    if (usuarioActual == null) return;

    try {
      final CollectionReference gastosComunesRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioActual.uid)
          .collection('gastos_comunes');

      final QuerySnapshot snapshot = await gastosComunesRef.get();

      setState(() {
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          switch (data['titulo']) {
            case 'Luz':
              _luzController.text = _formatearNumero(data['monto'].toString());
              break;
            case 'Agua':
              _aguaController.text = _formatearNumero(data['monto'].toString());
              break;
            case 'Gas':
              _gasController.text = _formatearNumero(data['monto'].toString());
              break;
          }
        }
        _calcularTotal(); // Calcular total al cargar datos
      });
    } catch (e) {
      _mostrarMensaje("Error al cargar los datos: $e");
    }
  }

  void _calcularTotal() {
    int total = 0;

    // Sumar los gastos de Luz, Agua y Gas
    if (_luzController.text.isNotEmpty) {
      total += int.parse(_luzController.text.replaceAll('.', ''));
    }
    if (_aguaController.text.isNotEmpty) {
      total += int.parse(_aguaController.text.replaceAll('.', ''));
    }
    if (_gasController.text.isNotEmpty) {
      total += int.parse(_gasController.text.replaceAll('.', ''));
    }

    setState(() {
      _totalGastos = total;
    });
  }

  Future<void> _guardarDatos() async {
    final User? usuarioActual = _auth.currentUser;

    if (usuarioActual == null) {
      _mostrarMensaje("No se pudo guardar. Usuario no autenticado.");
      return;
    }

    try {
      final CollectionReference gastosComunesRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioActual.uid)
          .collection('gastos_comunes');

      // Limpiar los datos existentes
      final QuerySnapshot snapshot = await gastosComunesRef.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Guardar los nuevos datos
      await gastosComunesRef.add({
        'titulo': 'Luz',
        'monto': int.parse(_luzController.text.replaceAll('.', '')),
        'fecha': Timestamp.now(),
      });
      await gastosComunesRef.add({
        'titulo': 'Agua',
        'monto': int.parse(_aguaController.text.replaceAll('.', '')),
        'fecha': Timestamp.now(),
      });
      await gastosComunesRef.add({
        'titulo': 'Gas',
        'monto': int.parse(_gasController.text.replaceAll('.', '')),
        'fecha': Timestamp.now(),
      });

      _mostrarMensaje("Datos guardados con éxito.");

      // Redirigir al Home después de guardar
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      _mostrarMensaje("Error al guardar los datos: $e");
    }
  }

  void _mostrarMensaje(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Mensaje"),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  String _formatearNumero(String valor) {
    if (valor.isEmpty) return valor;
    final numero = int.tryParse(valor.replaceAll('.', '')) ?? 0;
    return numero.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos Comunes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Luz:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _luzController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'Ingresa el gasto de Luz',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _luzController.text = _formatearNumero(value);
                    _luzController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _luzController.text.length),
                    );
                    _calcularTotal(); // Calcular total al cambiar el valor
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Agua:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _aguaController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'Ingresa el gasto de Agua',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _aguaController.text = _formatearNumero(value);
                    _aguaController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _aguaController.text.length),
                    );
                    _calcularTotal(); // Calcular total al cambiar el valor
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Gas:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _gasController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'Ingresa el gasto de Gas',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _gasController.text = _formatearNumero(value);
                    _gasController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _gasController.text.length),
                    );
                    _calcularTotal(); // Calcular total al cambiar el valor
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Total Gastos: ${_formatearNumero(_totalGastos.toString())}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Volver'),
                  ),
                  ElevatedButton(
                    onPressed: _guardarDatos,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
