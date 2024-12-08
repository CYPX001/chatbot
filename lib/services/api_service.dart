import 'dart:convert'; // Librería para codificar y decodificar datos JSON.
import 'package:flutter/material.dart'; // Librería para utilidades de Flutter.
import 'package:http/http.dart' as http; // Librería para realizar solicitudes HTTP.

// Función que envía un historial de chat a la API y obtiene una respuesta generada.
Future<String?> getAnswer(List<Map<String, dynamic>> chatHistory) async {
  // URL de la API, incluyendo la clave de acceso.
  final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyA5HwigYC743gDL1tr132Lqa3jXTqdcE6s';
  final uri = Uri.parse(url); // Convierte la cadena de texto de la URL a un objeto URI.

  // Procesa el historial de chat en el formato requerido por la API.
  List<Map<String, dynamic>> contents = chatHistory.map((msg) {
    return {
      "role": msg["isSender"] ? "user" : "model", // Define el rol (usuario o modelo).
      "parts": [{"text": msg["message"] ?? ""}] // Define el mensaje enviado.
    };
  }).toList();

  // Cuerpo de la solicitud en formato JSON.
  Map<String, dynamic> request = {
    "contents": contents, // Incluye el historial de mensajes procesados.
    "generationConfig": {
      "temperature": 0.25, // Controla la creatividad de las respuestas generadas.
      "topK": 1,           // Define cuántas palabras con mayor probabilidad se consideran.
      "topP": 1,           // Controla la diversidad de las respuestas generadas.
      "candidateCount": 1, // Número de respuestas candidatas a generar.
    }
  };

  try {
    // Envía la solicitud HTTP POST a la API.
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'}, // Define el tipo de contenido como JSON.
      body: jsonEncode(request), // Convierte el cuerpo de la solicitud a formato JSON.
    );

    // Verifica si la respuesta de la API es exitosa (código 200).
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // Decodifica el cuerpo de la respuesta JSON.
      // Extrae y devuelve el texto generado desde los datos de la respuesta.
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      // Muestra un mensaje de error si la respuesta no es exitosa.
      debugPrint('Error en la solicitud: ${response.statusCode}');
      debugPrint('Respuesta: ${response.body}');
      return null;
    }
  } catch (e) {
    // Captura y muestra errores durante la conexión o solicitud.
    debugPrint('Error al conectar con la API: $e');
    return null;
  }
}
