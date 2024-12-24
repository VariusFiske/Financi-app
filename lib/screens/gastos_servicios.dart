import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GastosServicios extends StatefulWidget {
  const GastosServicios({super.key});

  @override
  _GastosServiciosState createState() => _GastosServiciosState();
}

class _GastosServiciosState extends State<GastosServicios> {
  final TextEditingController _internetController = TextEditingController();
  final List<Map<String, dynamic>> _camposDinamicos = [];
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
      final CollectionReference gastosServiciosRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioActual.uid)
          .collection('gastos_servicios');

      final QuerySnapshot snapshot = await gastosServiciosRef.get();

      setState(() {
        _camposDinamicos.clear(); // Limpiar campos existentes
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['titulo'] == 'Internet') {
            _internetController.text =
                _formatearNumero(data['monto'].toString());
          } else {
            _camposDinamicos.add({
              'titulo': data['titulo'],
              'controller': TextEditingController(
                text: _formatearNumero(data['monto'].toString()),
              ),
              'editable': false,
              'habilitarMonto': true,
            });
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

    // Sumar el gasto de Internet
    if (_internetController.text.isNotEmpty) {
      total += int.parse(_internetController.text.replaceAll('.', ''));
    }

    // Sumar los gastos de servicios adicionales
    for (var campo in _camposDinamicos) {
      if (campo['controller'].text.isNotEmpty) {
        total += int.parse(campo['controller'].text.replaceAll('.', ''));
      }
    }

    setState(() {
      _totalGastos = total;
    });
  }

  void _agregarCampoDinamico() {
    setState(() {
      _camposDinamicos.add({
        "titulo": "",
        "controller": TextEditingController(),
        "editable": true,
        "habilitarMonto": false,
      });
    });
  }

  void _eliminarUltimoCampoDinamico() {
    if (_camposDinamicos.isNotEmpty) {
      setState(() {
        _camposDinamicos.removeLast();
        _calcularTotal(); // Recalcular total al eliminar un campo
      });
    }
  }

  Future<void> _guardarDatos() async {
    final User? usuarioActual = _auth.currentUser;

    if (usuarioActual == null) {
      _mostrarMensaje("No se pudo guardar. Usuario no autenticado.");
      return;
    }

    if (_internetController.text.isEmpty) {
      _mostrarMensaje("El campo de Internet no puede estar vacío.");
      return;
    }

    for (var campo in _camposDinamicos) {
      if (campo['titulo'].isEmpty || campo['controller'].text.isEmpty) {
        _mostrarMensaje(
            "Todos los campos de servicios adicionales deben estar llenos.");
        return;
      }
    }

    try {
      final CollectionReference gastosServiciosRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioActual.uid)
          .collection('gastos_servicios');

      // Limpiar los datos existentes
      final QuerySnapshot snapshot = await gastosServiciosRef.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Guardar los nuevos datos
      await gastosServiciosRef.add({
        'titulo': 'Internet',
        'monto': int.parse(_internetController.text.replaceAll('.', '')),
        'fecha': Timestamp.now(),
      });

      for (var campo in _camposDinamicos) {
        await gastosServiciosRef.add({
          'titulo': campo['titulo'],
          'monto': int.parse(campo['controller'].text.replaceAll('.', '')),
          'fecha': Timestamp.now(),
        });
      }

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

  bool _camposCompletos() {
    return _camposDinamicos.isEmpty ||
        (_camposDinamicos.last['titulo'].isNotEmpty &&
            _camposDinamicos.last['controller'].text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos de Servicios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Internet:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _internetController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'Ingresa el gasto de Internet',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _internetController.text = _formatearNumero(value);
                    _internetController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _internetController.text.length),
                    );
                    _calcularTotal(); // Calcular total al cambiar el valor
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Servicios adicionales:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._camposDinamicos.map((campo) {
                int index = _camposDinamicos.indexOf(campo);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    campo['editable']
                        ? TextField(
                            decoration: InputDecoration(
                              hintText: 'Título del servicio ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                setState(() {
                                  campo['titulo'] = value.trim();
                                  campo['editable'] = false;
                                  campo['habilitarMonto'] = true;
                                });
                              } else {
                                _mostrarMensaje(
                                    "El título no puede estar vacío.");
                              }
                            },
                          )
                        : Text(
                            campo['titulo'],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: campo['controller'],
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'Gasto del servicio',
                        border: OutlineInputBorder(),
                      ),
                      enabled: campo['habilitarMonto'],
                      onChanged: (value) {
                        setState(() {
                          campo['controller'].text = _formatearNumero(value);
                          campo['controller'].selection =
                              TextSelection.fromPosition(
                            TextPosition(
                                offset: campo['controller'].text.length),
                          );
                          _calcularTotal(); // Calcular total al cambiar el valor
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _camposCompletos()
                          ? _agregarCampoDinamico
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _eliminarUltimoCampoDinamico,
                    ),
                  ],
                ),
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



