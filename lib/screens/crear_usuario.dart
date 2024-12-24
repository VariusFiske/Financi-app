import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore

class CrearUsuario extends StatefulWidget {
  @override
  _CrearUsuarioState createState() => _CrearUsuarioState();
}

class _CrearUsuarioState extends State<CrearUsuario> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _trabajoController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _guardarUsuario() async {
    String nombre = _nombreController.text.trim();
    String apellido = _apellidoController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String trabajo = _trabajoController.text.trim();

    // Valida que todos los campos estén completos
    if (nombre.isEmpty || apellido.isEmpty || email.isEmpty || password.isEmpty || trabajo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Por favor, completa todos los campos."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Crea el usuario con correo y contraseña en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guarda los datos adicionales en Firestore
      await _firestore.collection('usuarios').doc(userCredential.user?.uid).set({
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'trabajo': trabajo,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Usuario creado exitosamente."),
          backgroundColor: Colors.green,
        ),
      );

      // Regresa a la pantalla de inicio de sesión
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Ocurrió un error al crear el usuario.";
      if (e.code == 'email-already-in-use') {
        errorMessage = "El correo ya está registrado.";
      } else if (e.code == 'weak-password') {
        errorMessage = "La contraseña es demasiado débil.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Usuario'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _trabajoController,
                decoration: const InputDecoration(
                  labelText: 'Trabajo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _guardarUsuario,
                child: const Text('Guardar Usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
