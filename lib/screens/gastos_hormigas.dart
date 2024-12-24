import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GastosHormiga extends StatefulWidget {
  const GastosHormiga({super.key});

  @override
  _GastosHormigaState createState() => _GastosHormigaState();
}

class _GastosHormigaState extends State<GastosHormiga> {
  final List<Map<String, dynamic>> _camposDinamicos = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _cargarDatosGuardados();
  }

  void _agregarCampoDinamico() {
    if (_camposDinamicos.isNotEmpty) {
      final ultimoCampo = _camposDinamicos.last;
      if (ultimoCampo['titulo'].isEmpty || ultimoCampo['controller'].text.isEmpty) {
        _mostrarMensaje("Completa el último campo antes de agregar otro.");
        return;
      }
    }
    setState(() {
      _camposDinamicos.add({
        "titulo": "",
        "controller": TextEditingController(),
        "editable": true,
        "habilitado": false,
      });
    });
  }

  void _eliminarUltimoCampo() {
    if (_camposDinamicos.isNotEmpty) {
      setState(() {
        _camposDinamicos.removeLast();
      });
    } else {
      _mostrarMensaje("No hay campos para eliminar.");
    }
  }

  Future<void> _guardarDatos() async {
    final User? usuarioActual = _auth.currentUser;

    if (usuarioActual == null) {
      _mostrarMensaje("No se pudo guardar. Usuario no autenticado.");
      return;
    }

    for (var campo in _camposDinamicos) {
      if (campo['titulo'].isEmpty || campo['controller'].text.isEmpty) {
        _mostrarMensaje("Todos los campos de gastos deben estar llenos.");
        return;
      }
    }

    try {
      final CollectionReference gastosHormigaRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioActual.uid)
          .collection('gastos_hormiga');

      final QuerySnapshot snapshot = await gastosHormigaRef.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      for (var campo in _camposDinamicos) {
        await gastosHormigaRef.add({
          'titulo': campo['titulo'],
          'monto': int.parse(campo['controller'].text.replaceAll('.', '')),
          'fecha': Timestamp.now(),
        });
      }

      _mostrarMensaje("Datos guardados con éxito.");
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      _mostrarMensaje("Error al guardar los datos: $e");
    }
  }

  Future<void> _cargarDatosGuardados() async {
    final User? usuarioActual = _auth.currentUser;

    if (usuarioActual == null) {
      _mostrarMensaje("Usuario no autenticado.");
      return;
    }

    try {
      final CollectionReference gastosHormigaRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioActual.uid)
          .collection('gastos_hormiga');

      final QuerySnapshot snapshot = await gastosHormigaRef.get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _camposDinamicos.clear();
          for (var doc in snapshot.docs) {
            _camposDinamicos.add({
              "titulo": doc['titulo'],
              "controller": TextEditingController(text: _formatearNumero(doc['monto'].toString())),
              "editable": false,
              "habilitado": true,
            });
          }
        });
      }
    } catch (e) {
      _mostrarMensaje("Error al cargar los datos: $e");
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
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
        title: const Text('Gastos Hormiga'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gastos adicionales:',
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
                              hintText: 'Título del gasto ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                setState(() {
                                  campo['titulo'] = value.trim();
                                  campo['editable'] = false;
                                  campo['habilitado'] = true;
                                });
                              } else {
                                _mostrarMensaje("El título no puede estar vacío.");
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      enabled: campo['habilitado'],
                      decoration: const InputDecoration(
                        hintText: 'Monto del gasto',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          campo['controller'].text = _formatearNumero(value);
                          campo['controller'].selection = TextSelection.fromPosition(
                            TextPosition(offset: campo['controller'].text.length),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _agregarCampoDinamico,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _eliminarUltimoCampo,
                  ),
                ],
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
