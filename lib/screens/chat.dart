import 'package:flutter/material.dart'; // Librería principal de Flutter.
import '../services/api_service.dart'; // Importa la lógica de interacción con la API.

class ChatPage extends StatefulWidget {
  const ChatPage({super.key}); // Constructor de la página de chat.

  @override
  State<ChatPage> createState() => _ChatPageState(); // Crea el estado asociado al widget.
}

class _ChatPageState extends State<ChatPage> {
  // Controlador para el campo de texto del mensaje.
  final TextEditingController _chatController = TextEditingController();
  
  // Controlador para desplazar la lista de mensajes.
  final ScrollController _scrollController = ScrollController();
  
  // Historial de mensajes (almacena el texto y su origen: usuario o modelo).
  List<Map<String, dynamic>> _chatHistory = [];

  // Función para enviar un mensaje.
  void sendMessage() async {
    if (_chatController.text.isNotEmpty) { // Verifica que el campo no esté vacío.
      final userMessage = _chatController.text; // Obtiene el texto ingresado.
      _chatController.clear(); // Limpia el campo de texto.

      setState(() {
        // Agrega el mensaje del usuario al historial.
        _chatHistory.add({
          "time": DateTime.now(), // Marca de tiempo.
          "message": userMessage, // Texto del mensaje.
          "isSender": true, // Indica que fue enviado por el usuario.
        });
      });

      // Desplaza automáticamente la lista para mostrar el último mensaje.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });

      // Solicita una respuesta de la API.
      final response = await getAnswer(_chatHistory);
      if (response != null) {
        setState(() {
          // Agrega la respuesta de la IA al historial.
          _chatHistory.add({
            "time": DateTime.now(),
            "message": response,
            "isSender": false, // Indica que fue enviado por el modelo.
          });
        });

        // Desplaza la lista para mostrar la respuesta.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      } else {
        // Muestra un mensaje de error si la solicitud falla.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al obtener respuesta del chat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat", style: TextStyle(fontWeight: FontWeight.bold)), // Título de la página.
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Controlador de desplazamiento.
              itemCount: _chatHistory.length, // Número de mensajes en el historial.
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              itemBuilder: (context, index) {
                final message = _chatHistory[index]; // Mensaje actual.
                final isSender = message["isSender"] ?? false; // Identifica al remitente.
                return Align(
                  alignment: isSender ? Alignment.topRight : Alignment.topLeft, // Alinea el mensaje.
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10), // Espaciado inferior.
                    padding: const EdgeInsets.all(12), // Relleno interno del contenedor.
                    decoration: BoxDecoration(
                      color: isSender ? const Color(0xFFF69170) : Colors.white, // Color según el remitente.
                      borderRadius: BorderRadius.circular(20), // Bordes redondeados.
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2), // Sombra del contenedor.
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      message["message"] ?? "", // Texto del mensaje.
                      style: TextStyle(
                        color: isSender ? Colors.white : Colors.black, // Color del texto según el remitente.
                        fontSize: 16, // Tamaño de fuente.
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0), // Relleno externo del campo de entrada.
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController, // Controlador del campo de texto.
                    onSubmitted: (_) => sendMessage(), // Envía el mensaje al presionar "Enter".
                    decoration: InputDecoration(
                      hintText: "Type a message", // Texto de marcador de posición.
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // Bordes redondeados.
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Espaciado entre el campo de texto y el botón.
                IconButton(
                  onPressed: sendMessage, // Acción al presionar el botón.
                  icon: const Icon(Icons.send, color: Color(0xFFF69170)), // Ícono del botón.
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
