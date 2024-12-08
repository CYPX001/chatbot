import 'package:flutter/material.dart';
import 'chat.dart'; // Asegúrate de que el archivo está importado correctamente

class HomePage extends StatelessWidget {
  static const routeName = '/home';
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat bot using gemini API"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navegar a ChatPage directamente desde el botón
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatPage()),
            );
          },
          child: const Text('Start Chat'),
        ),
      ),
    );
  }
}
