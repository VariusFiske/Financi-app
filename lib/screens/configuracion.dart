import 'package:flutter/material.dart';
import 'package:testapp/screens/form_configuracion/editar_perfil.dart';
import 'package:testapp/screens/form_configuracion/cambiar_contrasena.dart';


class ConfiguracionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
        backgroundColor: Colors.black, // Color del AppBar
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Editar Perfil'),
            onTap: () {
              // Navega a la pantalla de edición de perfil
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditarPerfilScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Cambiar Contraseña'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CambiarContrasenaScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notificaciones'),
            onTap: () {
              // Acciones relacionadas con notificaciones
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Notificaciones'),
                  content: Text('Aquí puedes configurar tus notificaciones.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Idioma'),
            onTap: () {
              // Muestra un cuadro de selección de idioma
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Seleccionar Idioma'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text('Español'),
                        onTap: () {
                          // Cambiar idioma a español
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text('Inglés'),
                        onTap: () {
                          // Cambiar idioma a inglés
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacidad'),
            onTap: () {
              // Navega a una pantalla de privacidad
              Navigator.pushNamed(context, '/privacidad');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Acerca de'),
            onTap: () {
              // Muestra información de la aplicación
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Acerca de'),
                  content: Text('Versión 1.0.0\nDesarrollado por TILIN'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
