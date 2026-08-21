import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/storage/session_service.dart';
import '../models/chat_message.dart';

class SocketService {
  // ========================================
  // SERVICIOS
  // ========================================

  final SessionService sessionService = SessionService();

  // ========================================
  // SOCKET
  // ========================================

  io.Socket? _socket;

  // ========================================
  // GETTERS
  // ========================================

  bool get isConnected => _socket?.connected ?? false;

  // ========================================
  // CONECTAR
  // ========================================

  Future<void> connect({
    required void Function(List<ChatMessage> messages) onHistory,
    required void Function(ChatMessage message) onNewMessage,
    required void Function(String message) onError,
    void Function()? onConnected,
    void Function()? onDisconnected,
  }) async {
    // ========================================
    // OBTENER JWT
    // ========================================

    final token = await sessionService.getToken();

    if (token == null || token.isEmpty) {
      onError('No existe una sesión válida');
      return;
    }

    // ========================================
    // EVITAR CONEXIONES DUPLICADAS
    // ========================================

    disconnect();

    // ========================================
    // CREAR SOCKET
    // ========================================

    _socket = io.io(
      'http://localhost:3000',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    // ========================================
    // CONEXIÓN EXITOSA
    // ========================================

    _socket!.onConnect((_) {
      debugPrint('SOCKET CONECTADO: ${_socket!.id}');

      onConnected?.call();
    });

    // ========================================
    // ERROR DE CONEXIÓN
    // ========================================

    _socket!.onConnectError((error) {
      debugPrint('ERROR DE CONEXIÓN SOCKET: $error');

      onError(error?.toString() ?? 'Error conectando al chat');
    });

    // ========================================
    // HISTORIAL DE MENSAJES
    // ========================================

    _socket!.on('message-history', (data) {
      try {
        final List<dynamic> history = List<dynamic>.from(data as List);

        final messages = history
            .map(
              (message) => ChatMessage.fromJson(
                Map<String, dynamic>.from(message as Map),
              ),
            )
            .toList();

        onHistory(messages);
      } catch (error) {
        debugPrint('ERROR PROCESANDO HISTORIAL: $error');

        onError('Error procesando el historial del chat');
      }
    });

    // ========================================
    // NUEVO MENSAJE
    // ========================================

    _socket!.on('new-message', (data) {
      try {
        final message = ChatMessage.fromJson(
          Map<String, dynamic>.from(data as Map),
        );

        onNewMessage(message);
      } catch (error) {
        debugPrint('ERROR PROCESANDO MENSAJE: $error');

        onError('Error procesando un mensaje recibido');
      }
    });

    // ========================================
    // ERROR DE MENSAJE
    // ========================================

    _socket!.on('message-error', (data) {
      if (data is Map) {
        final errorData = Map<String, dynamic>.from(data);

        onError(
          errorData['message']?.toString() ?? 'Error enviando el mensaje',
        );

        return;
      }

      onError(data?.toString() ?? 'Error enviando el mensaje');
    });

    // ========================================
    // DESCONEXIÓN
    // ========================================

    _socket!.onDisconnect((_) {
      debugPrint('SOCKET DESCONECTADO');

      onDisconnected?.call();
    });

    // ========================================
    // INICIAR CONEXIÓN
    // ========================================

    _socket!.connect();
  }

  // ========================================
  // ENVIAR MENSAJE
  // ========================================

  void sendMessage(String text) {
    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      return;
    }

    if (_socket == null || !_socket!.connected) {
      throw Exception('No existe conexión con el chat');
    }

    _socket!.emit('new-message', {'text': cleanText});
  }

  // ========================================
  // DESCONECTAR
  // ========================================

  void disconnect() {
    if (_socket == null) {
      return;
    }

    _socket!.off('message-history');

    _socket!.off('new-message');

    _socket!.off('message-error');

    _socket!.disconnect();
    _socket!.dispose();

    _socket = null;
  }
}
